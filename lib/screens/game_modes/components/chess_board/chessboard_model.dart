import 'package:chess/chess.dart';
import 'package:equatable/equatable.dart';

typedef bool ChessBoardHasNext();
typedef bool ChessBoardHasPrevious();
typedef void ChessBoardForward();
typedef void ChessBoardBackward();
typedef void ChessBoardMakeMove(final String sanMove);
typedef void ChessBoardUndoLastMove();
typedef void ChessBoardShowMoveArrow(final String sanMove);
typedef void ChessBoardRemoveMoveArrow();
typedef int ChessBoardGetNextPly();
typedef ChessMove ChessBoardGetChessMoveFromSan(final String sanMove);
typedef Chess ChessBoardGetLibraryBoard();
typedef ChessMoveHistory ChessBoardGetMoveHistory();
typedef void ChessBoardReset();

class ChessBoardController {
  ChessBoardHasNext? hasNext;
  ChessBoardHasPrevious? hasPrevious;
  ChessBoardForward? forward;
  ChessBoardBackward? backward;
  ChessBoardMakeMove? makeMove;
  ChessBoardUndoLastMove? undoLastMove;
  ChessBoardShowMoveArrow? showMoveArrow;
  ChessBoardRemoveMoveArrow? removeMoveArrow;
  ChessBoardGetNextPly? getNextPly;
  ChessBoardGetChessMoveFromSan? getChessMoveFromSan;
  ChessBoardGetLibraryBoard? getLibraryBoard;
  ChessBoardGetMoveHistory? getMoveHistory;
  ChessBoardReset? reset;

  void dispose() {
    // Remove references to prevent memory leaks
    hasNext = null;
    hasPrevious = null;
    forward = null;
    backward = null;
    makeMove = null;
    undoLastMove = null;
    showMoveArrow = null;
    removeMoveArrow = null;
    getNextPly = null;
    getChessMoveFromSan = null;
    getLibraryBoard = null;
    getMoveHistory = null;
    reset = null;
  }
}

class ChessSquare extends Equatable {
  final int columnIndex;
  final int rowIndex;

  ChessSquare({required this.columnIndex, required this.rowIndex})
      : assert(columnIndex >= 0 && columnIndex < 8, 'Column index must be between zero (inclusive) and eight (exclusive).'),
        assert(rowIndex >= 0 && rowIndex < 8, 'Row index must be between zero (inclusive) and eight (exclusive).');

  @override
  List<Object?> get props => [columnIndex, rowIndex];
}

enum ChessColor { white, black }

enum ChessPieceTypeEnum {
  whiteKing,
  whiteQueen,
  whiteRook,
  whiteBishop,
  whiteKnight,
  whitePawn,
  blackKing,
  blackQueen,
  blackRook,
  blackBishop,
  blackKnight,
  blackPawn,
}

const assetNamePrefix = 'assets/svg/chess_pieces/cburnett/';

extension ChessPieceExtension on ChessPieceTypeEnum {
  String get assetName {
    switch (this) {
      case ChessPieceTypeEnum.whiteKing:
        return '${assetNamePrefix}Chess_klt45.svg';
      case ChessPieceTypeEnum.whiteQueen:
        return '${assetNamePrefix}Chess_qlt45.svg';
      case ChessPieceTypeEnum.whiteRook:
        return '${assetNamePrefix}Chess_rlt45.svg';
      case ChessPieceTypeEnum.whiteBishop:
        return '${assetNamePrefix}Chess_blt45.svg';
      case ChessPieceTypeEnum.whiteKnight:
        return '${assetNamePrefix}Chess_nlt45.svg';
      case ChessPieceTypeEnum.whitePawn:
        return '${assetNamePrefix}Chess_plt45.svg';
      case ChessPieceTypeEnum.blackKing:
        return '${assetNamePrefix}Chess_kdt45.svg';
      case ChessPieceTypeEnum.blackQueen:
        return '${assetNamePrefix}Chess_qdt45.svg';
      case ChessPieceTypeEnum.blackRook:
        return '${assetNamePrefix}Chess_rdt45.svg';
      case ChessPieceTypeEnum.blackBishop:
        return '${assetNamePrefix}Chess_bdt45.svg';
      case ChessPieceTypeEnum.blackKnight:
        return '${assetNamePrefix}Chess_ndt45.svg';
      case ChessPieceTypeEnum.blackPawn:
        return '${assetNamePrefix}Chess_pdt45.svg';
    }
  }

  String get uncoloredDisplayName {
    switch (this) {
      case ChessPieceTypeEnum.whiteKing:
      case ChessPieceTypeEnum.blackKing:
        return 'König';
      case ChessPieceTypeEnum.whiteQueen:
      case ChessPieceTypeEnum.blackQueen:
        return 'Dame';
      case ChessPieceTypeEnum.whiteRook:
      case ChessPieceTypeEnum.blackRook:
        return 'Turm';
      case ChessPieceTypeEnum.whiteBishop:
      case ChessPieceTypeEnum.blackBishop:
        return 'Läufer';
      case ChessPieceTypeEnum.whiteKnight:
      case ChessPieceTypeEnum.blackKnight:
        return 'Springer';
      case ChessPieceTypeEnum.whitePawn:
      case ChessPieceTypeEnum.blackPawn:
        return 'Bauer';
    }
  }
}

class ChessPiece {
  final ChessPieceTypeEnum type;
  int columnIndex;
  int rowIndex;
  bool captured;

  ChessPiece({required this.type, required this.columnIndex, required this.rowIndex}) : this.captured = false;

  ChessColor getColor() {
    return type.toString().split('.').last.startsWith('white') ? ChessColor.white : ChessColor.black;
  }
}

class ChessMove {
  final String sanMove;
  final Move libraryMove;
  final ChessSquare fromSquare;
  final ChessSquare toSquare;
  final List<ChessPiece> movingPieces;
  final ChessPiece? capturedPiece;
  final ChessPiece? promotionPiece;

  ChessMove(
      {required this.sanMove,
      required this.libraryMove,
      required this.fromSquare,
      required this.toSquare,
      required this.movingPieces,
      required this.capturedPiece,
      required this.promotionPiece});

  ChessSquare getCastlingRookFromSquare() {
    if (!isCastling()) {
      throw StateError('This is not a castling move.');
    }

    var isWhiteMoving = movingPieces.first.getColor() == ChessColor.white;

    if (isKingSideCastling()) {
      return ChessSquare(columnIndex: 7, rowIndex: isWhiteMoving ? 7 : 0);
    } else {
      return ChessSquare(columnIndex: 0, rowIndex: isWhiteMoving ? 7 : 0);
    }
  }

  ChessSquare getCastlingRookToSquare() {
    if (!isCastling()) {
      throw StateError('This is not a castling move.');
    }

    var isWhiteMoving = movingPieces.first.getColor() == ChessColor.white;

    if (isKingSideCastling()) {
      return ChessSquare(columnIndex: 5, rowIndex: isWhiteMoving ? 7 : 0);
    } else {
      return ChessSquare(columnIndex: 3, rowIndex: isWhiteMoving ? 7 : 0);
    }
  }

  bool isCastling() {
    return isKingSideCastling() || isQueenSideCastling();
  }

  bool isKingSideCastling() {
    return sanMove == 'O-O';
  }

  bool isQueenSideCastling() {
    return sanMove == 'O-O-O';
  }
}

class ChessMoveHistory {
  List<ChessMove> moves = [];
}
