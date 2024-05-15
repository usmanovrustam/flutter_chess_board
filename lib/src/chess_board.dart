import 'dart:math';

import 'package:chess/chess.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_chess_board/src/pieces.dart';

import 'board_arrow.dart';
import 'chess_board_controller.dart';
import 'constants.dart';

class ChessBoardWidget extends StatefulWidget {
  final ChessController controller;

  final double? size;

  final bool enableUserMoves;

  final BoardColor boardColor;

  final PlayerColor boardOrientation;

  final VoidCallback? onMove;

  final List<BoardArrow> arrows;

  final BoardSquare? square;

  const ChessBoardWidget({
    Key? key,
    required this.controller,
    this.size,
    this.enableUserMoves = true,
    this.boardColor = BoardColor.brown,
    this.boardOrientation = PlayerColor.white,
    this.onMove,
    this.arrows = const [],
    this.square,
  }) : super(key: key);

  @override
  State<ChessBoardWidget> createState() => _ChessBoardWidgetState();
}

class _ChessBoardWidgetState extends State<ChessBoardWidget> {
  @override
  Widget build(BuildContext context) {
    final List<String> positions = widget.square?.positions ?? [];
    return ValueListenableBuilder<Chess>(
      valueListenable: widget.controller,
      builder: (context, game, _) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            children: [
              AspectRatio(
                child: _getBoardImage(widget.boardColor),
                aspectRatio: 1.0,
              ),
              if (widget.square != null && positions.isNotEmpty)
                IgnorePointer(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: CustomPaint(
                      child: Container(),
                      painter: _SquarePainter(
                        boardOrientation: widget.boardOrientation,
                        square: widget.square ??
                            BoardSquare(
                              positions: [],
                              color: MaterialColor(0xffbaca44, {}),
                            ),
                      ),
                    ),
                  ),
                ),
              AspectRatio(
                aspectRatio: 1.0,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8),
                  itemBuilder: (context, index) {
                    var row = index ~/ 8;
                    var column = index % 8;
                    var boardRank = widget.boardOrientation == PlayerColor.black
                        ? '${row + 1}'
                        : '${(7 - row) + 1}';
                    var boardFile = widget.boardOrientation == PlayerColor.white
                        ? '${files[column]}'
                        : '${files[7 - column]}';

                    var squareName = '$boardFile$boardRank';
                    var pieceOnSquare = game.get(squareName);

                    var piece = BoardPiece(
                      squareName: squareName,
                      game: game,
                    );

                    var draggable = game.get(squareName) != null
                        ? Draggable<PieceMoveData>(
                            child: piece,
                            feedback: piece,
                            childWhenDragging: SizedBox(),
                            data: PieceMoveData(
                              squareName: squareName,
                              pieceType:
                                  pieceOnSquare?.type.toUpperCase() ?? 'P',
                              pieceColor: pieceOnSquare?.color ?? Color.WHITE,
                            ),
                          )
                        : Container();

                    var dragTarget =
                        DragTarget<PieceMoveData>(builder: (context, list, _) {
                      return draggable;
                    }, onWillAcceptWithDetails: (pieceMoveData) {
                      return widget.enableUserMoves ? true : false;
                    }, onAcceptWithDetails: (pieceMoveData) async {
                      Color moveColor = game.turn;

                      if (pieceMoveData.data.pieceType == "P" &&
                          ((pieceMoveData.data.squareName[1] == "7" &&
                                  squareName[1] == "8" &&
                                  pieceMoveData.data.pieceColor ==
                                      Color.WHITE) ||
                              (pieceMoveData.data.squareName[1] == "2" &&
                                  squareName[1] == "1" &&
                                  pieceMoveData.data.pieceColor ==
                                      Color.BLACK))) {
                        var val = await _promotionDialog(context);

                        if (val != null) {
                          widget.controller.makeMoveWithPromotion(
                            from: pieceMoveData.data.squareName,
                            to: squareName,
                            pieceToPromoteTo: val,
                          );
                        } else {
                          return;
                        }
                      } else {
                        widget.controller.makeMove(
                          from: pieceMoveData.data.squareName,
                          to: squareName,
                        );
                      }
                      if (game.turn != moveColor) {
                        widget.onMove?.call();
                      }
                    });

                    return dragTarget;
                  },
                  itemCount: 64,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                ),
              ),
              if (widget.arrows.isNotEmpty)
                IgnorePointer(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: CustomPaint(
                      child: Container(),
                      painter:
                          _ArrowPainter(widget.arrows, widget.boardOrientation),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Image _getBoardImage(BoardColor color) {
    switch (color) {
      case BoardColor.brown:
        return Image.asset(
          "assets/images/brown_board.png",
          package: 'flutter_chess_board',
          fit: BoxFit.cover,
        );
      case BoardColor.darkBrown:
        return Image.asset(
          "assets/images/dark_brown_board.png",
          package: 'flutter_chess_board',
          fit: BoxFit.cover,
        );
      case BoardColor.blue:
        return Image.asset(
          "assets/images/blue_board.png",
          package: 'flutter_chess_board',
          fit: BoxFit.cover,
        );
      case BoardColor.orange:
        return Image.asset(
          "assets/images/orange_board.png",
          package: 'flutter_chess_board',
          fit: BoxFit.cover,
        );
      case BoardColor.green:
        return Image.asset(
          "assets/images/green_board.png",
          package: 'flutter_chess_board',
          fit: BoxFit.cover,
        );
    }
  }

  Future<String?> _promotionDialog(BuildContext context) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text('Choose promotion'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              InkWell(
                child: _PieceWidget(source: Pieces.whiteKing),
                onTap: () {
                  Navigator.of(context).pop("q");
                },
              ),
              InkWell(
                child: _PieceWidget(source: Pieces.whiteRook),
                onTap: () {
                  Navigator.of(context).pop("r");
                },
              ),
              InkWell(
                child: _PieceWidget(source: Pieces.whiteBipshop),
                onTap: () {
                  Navigator.of(context).pop("b");
                },
              ),
              InkWell(
                child: _PieceWidget(source: Pieces.whiteKnight),
                onTap: () {
                  Navigator.of(context).pop("n");
                },
              ),
            ],
          ),
        );
      },
    ).then((value) {
      return value;
    });
  }
}

class BoardPiece extends StatelessWidget {
  final String squareName;
  final Chess game;

  const BoardPiece({
    Key? key,
    required this.squareName,
    required this.game,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    late Widget imageToDisplay;
    var square = game.get(squareName);

    if (game.get(squareName) == null) {
      return Container();
    }

    String piece = (square?.color == Color.WHITE ? 'W' : 'B') +
        (square?.type.toUpperCase() ?? 'P');

    switch (piece) {
      case "WP":
        imageToDisplay = _PieceWidget(source: Pieces.whitePawn);
        break;
      case "WR":
        imageToDisplay = _PieceWidget(source: Pieces.whiteRook);
        break;
      case "WN":
        imageToDisplay = _PieceWidget(source: Pieces.whiteKnight);
        break;
      case "WB":
        imageToDisplay = _PieceWidget(source: Pieces.whiteBipshop);
        break;
      case "WQ":
        imageToDisplay = _PieceWidget(source: Pieces.whiteQueen);
        break;
      case "WK":
        imageToDisplay = _PieceWidget(source: Pieces.whiteKing);
        break;
      case "BP":
        imageToDisplay = _PieceWidget(source: Pieces.blackPawn);
        break;
      case "BR":
        imageToDisplay = _PieceWidget(source: Pieces.blackRook);
        break;
      case "BN":
        imageToDisplay = _PieceWidget(source: Pieces.blackKnight);
        break;
      case "BB":
        imageToDisplay = _PieceWidget(source: Pieces.blackBipshop);
        break;
      case "BQ":
        imageToDisplay = _PieceWidget(source: Pieces.blackQueen);
        break;
      case "BK":
        imageToDisplay = _PieceWidget(source: Pieces.blackKing);
        break;
      default:
        imageToDisplay = _PieceWidget(source: Pieces.blackPawn);
    }

    return imageToDisplay;
  }
}

class _PieceWidget extends StatelessWidget {
  final String source;
  const _PieceWidget({required this.source});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      source,
      package: 'flutter_chess_board',
      fit: BoxFit.cover,
      width: 45,
      height: 45,
    );
  }
}

class PieceMoveData {
  final String squareName;
  final String pieceType;
  final Color pieceColor;

  PieceMoveData({
    required this.squareName,
    required this.pieceType,
    required this.pieceColor,
  });
}

class BoardSquare {
  List<String> positions;
  MaterialColor color;

  BoardSquare({
    required this.positions,
    this.color = const MaterialColor(0xffbaca44, {}),
  });
}

class _SquarePainter extends CustomPainter {
  BoardSquare square;
  PlayerColor boardOrientation;

  _SquarePainter({required this.square, required this.boardOrientation});

  @override
  void paint(Canvas canvas, Size size) {
    List<String> positions = [];
    positions.addAll(square.positions.map((position) {
      if (position.length > 2) return position.substring(1);
      return position;
    }).toList());

    var blockSize = size.width / 8;

    for (var position in positions) {
      var file = files.indexOf(position[0]);
      var rank = int.parse(position[1]) - 1;

      int effectiveColumn, effectiveRow;
      if (boardOrientation == PlayerColor.black) {
        effectiveColumn = 7 - file;
        effectiveRow = rank;
      } else {
        effectiveColumn = file;
        effectiveRow = 7 - rank;
      }

      var topLeft = Offset(
        effectiveColumn * blockSize,
        effectiveRow * blockSize,
      );

      var paint = Paint()..color = square.color;
      canvas.drawRect(
        Rect.fromLTWH(topLeft.dx, topLeft.dy, blockSize, blockSize),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_SquarePainter oldDelegate) {
    return square != oldDelegate.square;
  }
}

class _ArrowPainter extends CustomPainter {
  List<BoardArrow> arrows;
  PlayerColor boardOrientation;

  _ArrowPainter(this.arrows, this.boardOrientation);

  @override
  void paint(Canvas canvas, Size size) {
    var blockSize = size.width / 8;
    var halfBlockSize = size.width / 16;

    for (var arrow in arrows) {
      var startFile = files.indexOf(arrow.from[0]);
      var startRank = int.parse(arrow.from[1]) - 1;
      var endFile = files.indexOf(arrow.to[0]);
      var endRank = int.parse(arrow.to[1]) - 1;

      int effectiveRowStart = 0;
      int effectiveColumnStart = 0;
      int effectiveRowEnd = 0;
      int effectiveColumnEnd = 0;

      if (boardOrientation == PlayerColor.black) {
        effectiveColumnStart = 7 - startFile;
        effectiveColumnEnd = 7 - endFile;
        effectiveRowStart = startRank;
        effectiveRowEnd = endRank;
      } else {
        effectiveColumnStart = startFile;
        effectiveColumnEnd = endFile;
        effectiveRowStart = 7 - startRank;
        effectiveRowEnd = 7 - endRank;
      }

      var startOffset = Offset(
          ((effectiveColumnStart + 1) * blockSize) - halfBlockSize,
          ((effectiveRowStart + 1) * blockSize) - halfBlockSize);
      var endOffset = Offset(
          ((effectiveColumnEnd + 1) * blockSize) - halfBlockSize,
          ((effectiveRowEnd + 1) * blockSize) - halfBlockSize);

      var yDist = 0.8 * (endOffset.dy - startOffset.dy);
      var xDist = 0.8 * (endOffset.dx - startOffset.dx);

      var paint = Paint()
        ..strokeWidth = halfBlockSize * 0.8
        ..color = arrow.color;

      canvas.drawLine(startOffset,
          Offset(startOffset.dx + xDist, startOffset.dy + yDist), paint);

      var slope =
          (endOffset.dy - startOffset.dy) / (endOffset.dx - startOffset.dx);

      var newLineSlope = -1 / slope;

      var points = _getNewPoints(
          Offset(startOffset.dx + xDist, startOffset.dy + yDist),
          newLineSlope,
          halfBlockSize);
      var newPoint1 = points[0];
      var newPoint2 = points[1];

      var path = Path();

      path.moveTo(endOffset.dx, endOffset.dy);
      path.lineTo(newPoint1.dx, newPoint1.dy);
      path.lineTo(newPoint2.dx, newPoint2.dy);
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  List<Offset> _getNewPoints(Offset start, double slope, double length) {
    if (slope == double.infinity || slope == double.negativeInfinity) {
      return [
        Offset(start.dx, start.dy + length),
        Offset(start.dx, start.dy - length)
      ];
    }

    return [
      Offset(start.dx + (length / sqrt(1 + (slope * slope))),
          start.dy + ((length * slope) / sqrt(1 + (slope * slope)))),
      Offset(start.dx - (length / sqrt(1 + (slope * slope))),
          start.dy - ((length * slope) / sqrt(1 + (slope * slope)))),
    ];
  }

  @override
  bool shouldRepaint(_ArrowPainter oldDelegate) {
    return arrows != oldDelegate.arrows;
  }
}
