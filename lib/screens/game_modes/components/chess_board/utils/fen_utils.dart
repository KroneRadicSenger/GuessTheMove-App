import 'package:flutter/widgets.dart';
import 'package:guess_the_move/screens/game_modes/components/chess_board/chessboard_model.dart';
import 'package:guess_the_move/screens/game_modes/components/chess_board/utils/board_utils.dart';

Map<ChessPiece, Key> loadBoardPiecesWithKeysFromFen(final String fen) {
  final Map<ChessPiece, Key> boardPiecesWithKeys = {};

  var fenSplitted = fen.split(' ');
  if (fenSplitted.length != 6) {
    throw ArgumentError('Given fen must consist of six space seperated components.');
  }

  var position = fenSplitted[0];

  int squareIndex = 0;

  for (int i = 0; i < position.length; i++) {
    var char = position[i];

    if (char == '/') {
      continue;
    } else if (int.tryParse(char) != null) {
      squareIndex += int.parse(char);
      continue;
    } else {
      var columnIndex = getColumnIndex(squareIndex);
      var rowIndex = getRowIndex(squareIndex);

      switch (char) {
        case 'k':
          boardPiecesWithKeys[ChessPiece(type: ChessPieceTypeEnum.blackKing, columnIndex: columnIndex, rowIndex: rowIndex)] = UniqueKey();
          break;
        case 'q':
          boardPiecesWithKeys[ChessPiece(type: ChessPieceTypeEnum.blackQueen, columnIndex: columnIndex, rowIndex: rowIndex)] = UniqueKey();
          break;
        case 'r':
          boardPiecesWithKeys[ChessPiece(type: ChessPieceTypeEnum.blackRook, columnIndex: columnIndex, rowIndex: rowIndex)] = UniqueKey();
          break;
        case 'b':
          boardPiecesWithKeys[ChessPiece(type: ChessPieceTypeEnum.blackBishop, columnIndex: columnIndex, rowIndex: rowIndex)] = UniqueKey();
          break;
        case 'n':
          boardPiecesWithKeys[ChessPiece(type: ChessPieceTypeEnum.blackKnight, columnIndex: columnIndex, rowIndex: rowIndex)] = UniqueKey();
          break;
        case 'p':
          boardPiecesWithKeys[ChessPiece(type: ChessPieceTypeEnum.blackPawn, columnIndex: columnIndex, rowIndex: rowIndex)] = UniqueKey();
          break;
        case 'K':
          boardPiecesWithKeys[ChessPiece(type: ChessPieceTypeEnum.whiteKing, columnIndex: columnIndex, rowIndex: rowIndex)] = UniqueKey();
          break;
        case 'Q':
          boardPiecesWithKeys[ChessPiece(type: ChessPieceTypeEnum.whiteQueen, columnIndex: columnIndex, rowIndex: rowIndex)] = UniqueKey();
          break;
        case 'R':
          boardPiecesWithKeys[ChessPiece(type: ChessPieceTypeEnum.whiteRook, columnIndex: columnIndex, rowIndex: rowIndex)] = UniqueKey();
          break;
        case 'B':
          boardPiecesWithKeys[ChessPiece(type: ChessPieceTypeEnum.whiteBishop, columnIndex: columnIndex, rowIndex: rowIndex)] = UniqueKey();
          break;
        case 'N':
          boardPiecesWithKeys[ChessPiece(type: ChessPieceTypeEnum.whiteKnight, columnIndex: columnIndex, rowIndex: rowIndex)] = UniqueKey();
          break;
        case 'P':
          boardPiecesWithKeys[ChessPiece(type: ChessPieceTypeEnum.whitePawn, columnIndex: columnIndex, rowIndex: rowIndex)] = UniqueKey();
          break;
        default:
          throw ArgumentError('Error during fen parsing (Invalid input fen string)');
      }
      squareIndex++;
    }
  }

  return boardPiecesWithKeys;
}
