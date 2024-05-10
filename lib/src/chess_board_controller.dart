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
}
