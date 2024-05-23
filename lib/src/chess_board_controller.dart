import 'package:chess/chess.dart';
import 'package:flutter/material.dart';

import 'constants.dart';

class ChessController extends ValueNotifier<Chess> {
  late Chess game;

  factory ChessController() => ChessController._(Chess());

  factory ChessController.fromGame(Chess game) => ChessController._(game);

  factory ChessController.fromFEN(String fen) =>
      ChessController._(Chess.fromFEN(fen));

  ChessController._(Chess game)
      : game = game,
        super(game);

  void makeMove({required String from, required String to}) {
    game.move({"from": from, "to": to});
    notifyListeners();
  }

  void makeMoveWithPromotion(
      {required String from,
      required String to,
      required String pieceToPromoteTo}) {
    game.move({"from": from, "to": to, "promotion": pieceToPromoteTo});
    notifyListeners();
  }

  void makeMoveWithNormalNotation(String move) {
    game.move(move);
    notifyListeners();
  }

  void undoMove() {
    if (game.half_moves == 0) {
      return;
    }
    game.undo_move();
    notifyListeners();
  }

  void resetBoard() {
    game.reset();
    notifyListeners();
  }

  void clearBoard() {
    game.clear();
    notifyListeners();
  }

  void putPiece(BoardPieceType piece, String square, PlayerColor color) {
    game.put(_getPiece(piece, color), square);
    notifyListeners();
  }

  void loadPGN(String pgn) {
    game.load_pgn(pgn);
    notifyListeners();
  }

  void loadFen(String fen) {
    game.load(fen);
    notifyListeners();
  }

  bool isInCheck() {
    return game.in_check;
  }

  bool isCheckMate() {
    return game.in_checkmate;
  }

  bool isDraw() {
    return game.in_draw;
  }

  bool isStaleMate() {
    return game.in_stalemate;
  }

  bool isThreefoldRepetition() {
    return game.in_threefold_repetition;
  }

  bool isInsufficientMaterial() {
    return game.insufficient_material;
  }

  bool isGameOver() {
    return game.game_over;
  }

  String getAscii() {
    return game.ascii;
  }

  String getFen() {
    return game.fen;
  }

  List<String?> getSan() {
    return game.san_moves();
  }

  List<Piece?> getBoard() {
    return game.board;
  }

  List<Move> getPossibleMoves() {
    return game.moves({'asObjects': true}) as List<Move>;
  }

  int getMoveCount() {
    return game.move_number;
  }

  int getHalfMoveCount() {
    return game.half_moves;
  }

  Piece _getPiece(BoardPieceType piece, PlayerColor color) {
    var convertedColor = color == PlayerColor.white ? Color.WHITE : Color.BLACK;

    switch (piece) {
      case BoardPieceType.Bishop:
        return Piece(PieceType.BISHOP, convertedColor);
      case BoardPieceType.Queen:
        return Piece(PieceType.QUEEN, convertedColor);
      case BoardPieceType.King:
        return Piece(PieceType.KING, convertedColor);
      case BoardPieceType.Knight:
        return Piece(PieceType.KNIGHT, convertedColor);
      case BoardPieceType.Pawn:
        return Piece(PieceType.PAWN, convertedColor);
      case BoardPieceType.Rook:
        return Piece(PieceType.ROOK, convertedColor);
    }
  }

  Map<String, List<String>> getPiecePosition(
    PieceType pieceType,
    PlayerColor pieceColor,
  ) {
    Map<String, List<String>> positions = {};

    var convertedColor =
        pieceColor == PlayerColor.white ? Color.WHITE : Color.BLACK;

    List<String> rows = game
        .generate_fen()
        .split('/')
        .map((element) => element.split(' ')[0])
        .toList();

    for (int rank = 7; rank >= 0; rank--) {
      String row = rows[7 - rank];
      int file = 0;

      for (int i = 0; i < row.length; i++) {
        String char = row[i];
        if (RegExp(r'\d').hasMatch(char)) {
          file += int.parse(char);
        } else {
          Color pieceColorInSquare =
              char.toUpperCase() == char ? Color.WHITE : Color.BLACK;
          if ((char.toUpperCase() == pieceType.toUpperCase() ||
                  char.toLowerCase() == pieceType.toLowerCase()) &&
              pieceColorInSquare == convertedColor) {
            String square = '${files[file]}${rank + 1}';
            positions.putIfAbsent(char, () => []).add(square);
          }
          file++;
        }
      }
    }

    return positions;
  }

  String findPiece(String correctMove, String targetSquare) {
    List<String> possiblePieces = [];

    List<Move> possibleMoves = getPossibleMoves();

    PieceType pieceType = PieceType.PAWN;

    if (correctMove.length > 2) {
      if (correctMove.startsWith("K")) {
        pieceType = PieceType.KING;
      }
      if (correctMove.startsWith("Q")) {
        pieceType = PieceType.QUEEN;
      }
      if (correctMove.startsWith("N")) {
        pieceType = PieceType.KNIGHT;
      }
      if (correctMove.startsWith("R")) {
        pieceType = PieceType.ROOK;
      }
      if (correctMove.startsWith("B")) {
        pieceType = PieceType.BISHOP;
      }
    }

    final position = getPiecePosition(pieceType, PlayerColor.white);

    // TODO: need to implement if multiple pieceses can move to the same square
    // if (correctMove.length > 3) {
    //   List<String> field = [];

    //   position.values.first.forEach((element) {
    //     field.add(element[0]);
    //   });

    //   if (field.contains(correctMove[1])) {
    //     // print(correctMove[1]);
    //   }
    // }

    List<String> from = [];
    List<String> to = [];

    for (Move move in possibleMoves) {
      if (!from.contains(move.fromAlgebraic)) from.add(move.fromAlgebraic);
      if (!to.contains(move.toAlgebraic)) to.add(move.toAlgebraic);
    }

    for (Move move in possibleMoves) {
      if (move.toAlgebraic == targetSquare) {
        if (position.values
            .expand((i) => i)
            .toList()
            .contains(move.fromAlgebraic)) {
          possiblePieces.add(move.fromAlgebraic);
        }
      }
    }

    return possiblePieces.isNotEmpty ? possiblePieces.first : "";
  }
}
