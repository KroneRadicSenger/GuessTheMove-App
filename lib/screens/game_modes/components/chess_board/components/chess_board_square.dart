import 'package:flutter/widgets.dart';
import 'package:guess_the_move/screens/game_modes/components/chess_board/chessboard_model.dart';
import 'package:guess_the_move/screens/game_modes/components/chess_board/utils/board_utils.dart';

class ChessBoardSquare extends StatelessWidget {
  final int squareIndex;
  final bool boardFlipped;
  final double boardSize;
  final Color lightSquareColor;
  final Color darkSquareColor;
  final Color highlightSquareColor;
  final Color markDragMoveToSquaresColor;
  final bool isLegalMoveToSquare;
  final bool isHighlightedSquare;
  final bool isPieceOnSquare;
  final Function(ChessSquare) onTap;
  final Function(ChessSquare) onDragPieceEnd;

  const ChessBoardSquare({
    Key? key,
    required this.squareIndex,
    required this.boardFlipped,
    required this.boardSize,
    required this.lightSquareColor,
    required this.darkSquareColor,
    required this.highlightSquareColor,
    required this.markDragMoveToSquaresColor,
    required this.isLegalMoveToSquare,
    required this.isHighlightedSquare,
    required this.isPieceOnSquare,
    required this.onTap,
    required this.onDragPieceEnd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var lightSquare = isLightSquare(squareIndex);
    var columnIndex = getColumnIndex(squareIndex);
    var rowIndex = getRowIndex(squareIndex);

    final actualChessSquare = ChessSquare(
      columnIndex: boardFlipped ? 7 - columnIndex : columnIndex,
      rowIndex: boardFlipped ? 7 - rowIndex : rowIndex,
    );

    return Positioned(
      width: boardSize / 8,
      height: boardSize / 8,
      left: columnIndex * (boardSize / 8),
      top: rowIndex * (boardSize / 8),
      child: GestureDetector(
        onTap: () => onTap(actualChessSquare),
        child: DragTarget<ChessPiece>(
          builder: (context, accepted, rejected) {
            return Stack(
              children: [
                Container(
                  color: lightSquare ? lightSquareColor : darkSquareColor,
                ),
                if (isLegalMoveToSquare) _buildMarkLegalMoveToSquare(actualChessSquare, lightSquare),
                if (isHighlightedSquare)
                  Container(
                    color: highlightSquareColor,
                  ),
                if (rowIndex == 7) _buildColumnName(boardFlipped ? 7 - columnIndex : columnIndex, lightSquare),
                if (columnIndex == 7) _buildRowNumber(boardFlipped ? 7 - rowIndex : rowIndex, lightSquare),
              ],
            );
          },
          onAccept: (final ChessPiece dragPiece) => onDragPieceEnd(actualChessSquare),
        ),
      ),
    );
  }

  Widget _buildColumnName(final int columnIndex, final bool isLightSquare) {
    var columnName = getColumnName(columnIndex);

    return Align(
      alignment: Alignment.bottomLeft,
      child: Text(
        columnName,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: isLightSquare ? darkSquareColor : lightSquareColor),
      ),
    );
  }

  Widget _buildRowNumber(final int rowIndex, final bool isLightSquare) {
    var rowNumber = getRowNumber(rowIndex);

    return Align(
      alignment: Alignment.topRight,
      child: Text(
        rowNumber.toString(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: isLightSquare ? darkSquareColor : lightSquareColor),
      ),
    );
  }

  Widget _buildMarkLegalMoveToSquare(final ChessSquare actualChessSquare, final bool lightSquare) {
    if (isPieceOnSquare) {
      return Container(
        decoration: BoxDecoration(
          color: markDragMoveToSquaresColor,
        ),
        child: ClipRect(
          clipBehavior: Clip.hardEdge,
          child: OverflowBox(
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: lightSquare ? lightSquareColor : darkSquareColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Positioned(
      top: (boardSize / 8) * 0.3,
      left: (boardSize / 8) * 0.3,
      child: Container(
        width: (boardSize / 8) * 0.4,
        height: (boardSize / 8) * 0.4,
        decoration: BoxDecoration(
          color: markDragMoveToSquaresColor,
          borderRadius: BorderRadius.circular((boardSize / 8) * 0.4),
        ),
      ),
    );
  }
}
