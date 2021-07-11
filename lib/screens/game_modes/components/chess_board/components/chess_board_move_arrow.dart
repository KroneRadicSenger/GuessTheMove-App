import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:guess_the_move/screens/game_modes/components/chess_board/chessboard_model.dart';

class ChessBoardMoveArrow extends StatelessWidget {
  final bool boardFlipped;
  final double boardSize;
  final Color highlightSquareColor;
  final ChessMove arrowMove;

  const ChessBoardMoveArrow({
    Key? key,
    required this.boardFlipped,
    required this.boardSize,
    required this.highlightSquareColor,
    required this.arrowMove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = (boardSize / 8);

    final fromColumnIndex = boardFlipped ? 7 - arrowMove.fromSquare.columnIndex : arrowMove.fromSquare.columnIndex;
    final fromRowIndex = boardFlipped ? 7 - arrowMove.fromSquare.rowIndex : arrowMove.fromSquare.rowIndex;

    final originLeft = (fromColumnIndex + 0.5) * (boardSize / 8) - width / 2;
    final originTop = (fromRowIndex + 0.5) * (boardSize / 8);

    final columnsDistance = arrowMove.toSquare.columnIndex - arrowMove.fromSquare.columnIndex;
    final rowsDistance = arrowMove.toSquare.rowIndex - arrowMove.fromSquare.rowIndex;
    final squaresDistance = sqrt((columnsDistance * columnsDistance) + (rowsDistance * rowsDistance));

    final height = squaresDistance * (boardSize / 8);

    final angleRadians = atan2(rowsDistance, columnsDistance);

    var angleDegrees = (angleRadians * 180.0) / pi - 90;
    if (boardFlipped) {
      angleDegrees = (angleDegrees + 180) % 360;
    }

    return Positioned(
      width: width,
      height: height,
      left: originLeft,
      top: originTop,
      child: Transform(
        alignment: FractionalOffset.topCenter,
        transform: Matrix4.identity()..rotateZ(angleDegrees * pi / 180),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              color: highlightSquareColor.withOpacity(.7),
              width: width / 5,
              height: height - (2.5 * width / 5),
            ),
            ClipPath(
              clipper: TriangleClipper(),
              child: Container(
                color: highlightSquareColor.withOpacity(.7),
                height: (2.5 * width / 5),
                width: (2.5 * width / 5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(final Size size) {
    final path = Path();
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(final TriangleClipper oldClipper) => false;
}
