import 'package:chess/chess.dart';
import 'package:guess_the_move/screens/game_modes/components/chess_board/chessboard_model.dart';
import 'package:guess_the_move/screens/game_modes/components/chess_board/utils/board_utils.dart';

final sanitizeMoveRegex = RegExp(r"[+#?!=]+$");

Move parseSanMove(final String sanMove, final Chess currentBoard) {
  var sanitizedMoveSan = sanitizeSanMove(sanMove);

  var legalMoves = currentBoard.generate_moves();
  for (int i = 0; i < legalMoves.length; i++) {
    var legalMoveSan = currentBoard.move_to_san(legalMoves[i]);
    var sanitizedLegalMoveSan = sanitizeSanMove(legalMoveSan);

    if (sanitizedMoveSan == sanitizedLegalMoveSan) {
      var move = legalMoves[i];
      return move;
    }
  }
  throw ArgumentError('Illegal input move.');
}

ChessMove getChessMoveFromLibraryMove(final Move move, final List<ChessPiece> nonCapturedBoardPieces, final Chess currentBoard) {
  assert(!nonCapturedBoardPieces.any((piece) => piece.captured), 'There should only be non captured pieces in the given list');

  var fromSquare = getSquareByColumnNameAndRowNumber(move.fromAlgebraic[0], int.parse(move.fromAlgebraic[1]));
  var toSquare = getSquareByColumnNameAndRowNumber(move.toAlgebraic[0], int.parse(move.toAlgebraic[1]));

  var capturedPiece;
  if ((move.flags & Chess.BITS_EP_CAPTURE) != 0) {
    final capturedPawnRowOffset = move.color == Color.WHITE ? 1 : -1;
    capturedPiece = nonCapturedBoardPieces.firstWhere((piece) => piece.columnIndex == toSquare.columnIndex && piece.rowIndex == toSquare.rowIndex + capturedPawnRowOffset);
  } else {
    var capturedPieces = nonCapturedBoardPieces.where((piece) => piece.columnIndex == toSquare.columnIndex && piece.rowIndex == toSquare.rowIndex);
    capturedPiece = capturedPieces.isEmpty ? null : capturedPieces.first;
  }

  var movingPieces = [nonCapturedBoardPieces.firstWhere((piece) => piece.columnIndex == fromSquare.columnIndex && piece.rowIndex == fromSquare.rowIndex)];

  if ((move.flags & Chess.BITS_KSIDE_CASTLE) != 0) {
    movingPieces.add(nonCapturedBoardPieces.firstWhere((piece) => piece.columnIndex == 7 && piece.rowIndex == (currentBoard.turn == Chess.WHITE ? 7 : 0)));
  } else if ((move.flags & Chess.BITS_QSIDE_CASTLE) != 0) {
    movingPieces.add(nonCapturedBoardPieces.firstWhere((piece) => piece.columnIndex == 0 && piece.rowIndex == (currentBoard.turn == Chess.WHITE ? 7 : 0)));
  }

  var promotionPiece;
  if (move.promotion != null) {
    promotionPiece = ChessPiece(type: _getColoredPieceType(move.promotion!, currentBoard.turn), columnIndex: toSquare.columnIndex, rowIndex: toSquare.rowIndex);
    movingPieces.add(promotionPiece);
  }

  return ChessMove(
      sanMove: currentBoard.move_to_san(move),
      libraryMove: move,
      fromSquare: fromSquare,
      toSquare: toSquare,
      movingPieces: movingPieces,
      capturedPiece: capturedPiece,
      promotionPiece: promotionPiece);
}

ChessPieceTypeEnum _getColoredPieceType(final PieceType type, final Color turn) {
  switch (type) {
    case Chess.KING:
      return turn == Chess.WHITE ? ChessPieceTypeEnum.whiteKing : ChessPieceTypeEnum.blackKing;
    case Chess.QUEEN:
      return turn == Chess.WHITE ? ChessPieceTypeEnum.whiteQueen : ChessPieceTypeEnum.blackQueen;
    case Chess.ROOK:
      return turn == Chess.WHITE ? ChessPieceTypeEnum.whiteRook : ChessPieceTypeEnum.blackRook;
    case Chess.KNIGHT:
      return turn == Chess.WHITE ? ChessPieceTypeEnum.whiteKnight : ChessPieceTypeEnum.blackKnight;
    case Chess.BISHOP:
      return turn == Chess.WHITE ? ChessPieceTypeEnum.whiteBishop : ChessPieceTypeEnum.blackBishop;
    case Chess.PAWN:
      return turn == Chess.WHITE ? ChessPieceTypeEnum.whitePawn : ChessPieceTypeEnum.blackPawn;
    default:
      throw ArgumentError('Illegal piece type.');
  }
}

String sanitizeSanMove(final String sanMove) {
  return sanMove.replaceAll(sanitizeMoveRegex, '');
}
