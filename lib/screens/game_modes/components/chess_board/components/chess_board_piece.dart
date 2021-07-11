import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:guess_the_move/screens/game_modes/components/chess_board/chess_board.dart';
import 'package:guess_the_move/screens/game_modes/components/chess_board/chessboard_model.dart';
import 'package:guess_the_move/screens/game_modes/components/chess_board/utils/board_utils.dart';

class ChessBoardPiece extends StatelessWidget {
  final Key? animatedKey;
  final ChessPiece piece;
  final bool isMoving;
  final bool isCaptured;
  final bool isLastCapturedPiece;
  final bool boardFlipped;
  final bool dragToMakeMove;
  final double boardSize;
  final Function(ChessPiece) onTap;
  final Function(ChessPiece, ChessSquare) onDragPieceStart;
  final Function(ChessSquare) onDragPieceEnd;
  final Function() onDragEnd;

  const ChessBoardPiece({
    Key? key,
    required this.animatedKey,
    required this.piece,
    required this.isMoving,
    required this.isCaptured,
    required this.isLastCapturedPiece,
    required this.boardFlipped,
    required this.dragToMakeMove,
    required this.boardSize,
    required this.onTap,
    required this.onDragPieceStart,
    required this.onDragPieceEnd,
    required this.onDragEnd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget chessPieceWidget = SvgPicture.asset(
      piece.type.assetName,
      semanticsLabel: piece.type.toString().split('.').last,
    );

    if (dragToMakeMove) {
      chessPieceWidget = DragTarget<ChessPiece>(
        builder: (context, accepted, rejected) {
          return GestureDetector(
            onTap: () => onTap(piece),
            child: Draggable(
              child: SvgPicture.asset(
                piece.type.assetName,
                semanticsLabel: piece.type.toString().split('.').last,
              ),
              feedback: Transform.scale(
                scale: 1.5,
                child: SvgPicture.asset(
                  piece.type.assetName,
                  semanticsLabel: piece.type.toString().split('.').last,
                ),
              ),
              childWhenDragging: Opacity(
                opacity: 0.4,
                child: SvgPicture.asset(
                  piece.type.assetName,
                  semanticsLabel: piece.type.toString().split('.').last,
                ),
              ),
              data: piece,
              onDragStarted: () => onDragPieceStart(piece, ChessSquare(columnIndex: piece.columnIndex, rowIndex: piece.rowIndex)),
              onDragEnd: (_) => onDragEnd(),
            ),
          );
        },
        onAccept: (_) => onDragPieceEnd(getSquareByPiece(piece)),
      );
    }

    final columnIndex = boardFlipped ? 7 - piece.columnIndex : piece.columnIndex;
    final rowIndex = boardFlipped ? 7 - piece.rowIndex : piece.rowIndex;

    return AnimatedPositioned(
      key: animatedKey,
      width: boardSize / 8,
      height: boardSize / 8,
      left: columnIndex * (boardSize / 8),
      top: rowIndex * (boardSize / 8),
      duration: isMoving ? const Duration(milliseconds: moveAnimationDurationMillis) : const Duration(milliseconds: 0),
      child: AnimatedOpacity(
        opacity: isCaptured ? 0 : 1,
        duration: (isCaptured && isLastCapturedPiece) ? const Duration(milliseconds: moveAnimationDurationMillis) : const Duration(milliseconds: 0),
        child: chessPieceWidget,
      ),
    );
  }
}
