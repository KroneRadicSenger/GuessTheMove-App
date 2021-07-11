import 'package:guess_the_move/screens/game_modes/components/chess_board/chessboard_model.dart';

const List<String> columnNames = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
const List<int> rowNumbers = [8, 7, 6, 5, 4, 3, 2, 1];

const startingPositionFen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';

ChessSquare getSquareByPiece(final ChessPiece piece) {
  return ChessSquare(columnIndex: piece.columnIndex, rowIndex: piece.rowIndex);
}

ChessSquare getSquareByColumnNameAndRowNumber(final String columnName, final int rowNumber) {
  for (int i = 0; i < columnNames.length; i++) {
    for (int j = 0; j < rowNumbers.length; j++) {
      if (columnNames[i] == columnName && rowNumbers[j] == rowNumber) {
        return ChessSquare(columnIndex: i, rowIndex: j);
      }
    }
  }
  throw ArgumentError('Invalid column name or row number.');
}

String getSquareName(final ChessSquare chessSquare) => '${getColumnName(chessSquare.columnIndex)}${getRowNumber(chessSquare.rowIndex)}';

String getColumnName(final int columnIndex) => columnNames[columnIndex];

int getRowNumber(final int rowIndex) => rowNumbers[rowIndex];

bool isLightSquare(final int squareIndex) => (getColumnIndex(squareIndex) % 2) == (getRowIndex(squareIndex) % 2);

int getColumnIndex(final int squareIndex) => squareIndex % 8;

int getRowIndex(final int squareIndex) => squareIndex ~/ 8;
