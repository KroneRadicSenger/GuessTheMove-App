import 'dart:core';

import 'package:chess/chess.dart' as chess;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guess_the_move/model/player.dart';
import 'package:guess_the_move/screens/game_modes/components/chess_board/chessboard_model.dart';
import 'package:guess_the_move/screens/game_modes/components/chess_board/components/chess_board_move_arrow.dart';
import 'package:guess_the_move/screens/game_modes/components/chess_board/components/chess_board_piece.dart';
import 'package:guess_the_move/screens/game_modes/components/chess_board/components/chess_board_square.dart';
import 'package:guess_the_move/screens/game_modes/components/chess_board/utils/board_utils.dart';
import 'package:guess_the_move/screens/game_modes/components/chess_board/utils/fen_utils.dart';
import 'package:guess_the_move/screens/game_modes/components/chess_board/utils/san_utils.dart';
import 'package:guess_the_move/screens/game_modes/components/chess_board/utils/show_promotion_dialog.dart';

const moveAnimationDurationMillis = 250;

class ChessBoard extends StatefulWidget {
  final double size;
  final Color lightSquareColor;
  final Color darkSquareColor;
  final Color highlightSquareColor;
  final Color markDragMoveToSquaresColor;
  final Color textColor;
  final Player whitePlayer;
  final Player blackPlayer;
  final bool flipped;
  final bool dragToMakeMove;
  final String fen;
  final ChessBoardController? controller;
  final Function? postInitialize;
  final Function(chess.Chess?, chess.Chess, ChessMove?)? onBoardChange;
  final Function(chess.Chess?, chess.Chess, ChessMove?)? onDragMoveSucceeded;

  const ChessBoard({
    Key? key,
    required this.size,
    required this.lightSquareColor,
    required this.darkSquareColor,
    required this.highlightSquareColor,
    required this.markDragMoveToSquaresColor,
    required this.textColor,
    required this.whitePlayer,
    required this.blackPlayer,
    this.flipped = false,
    this.dragToMakeMove = false,
    this.fen = startingPositionFen,
    this.controller,
    this.postInitialize,
    this.onBoardChange,
    this.onDragMoveSucceeded,
  })  : assert(size % 8 == 0, 'Size must be divisible by eight'),
        super(key: key);

  @override
  _ChessBoardState createState() => _ChessBoardState();
}

class _ChessBoardState extends State<ChessBoard> with TickerProviderStateMixin {
  chess.Chess? _currentBoard;
  Map<ChessPiece, Key>? _boardPiecesWithKeys;
  ChessMoveHistory? _moveHistory;
  int? _nextPly;
  List<ChessPiece>? _movingPieces;
  ChessPiece? _lastCapturedPiece;
  ChessSquare? _moveFromSquare;
  ChessSquare? _moveToSquare;
  ChessMove? _arrowMove;
  ChessSquare? _dragFromSquare;
  ChessSquare? _dragTargetSquare;
  ChessPiece? _dragPiece;
  List<ChessMove>? _dragLegalMoves;

  @override
  void initState() {
    super.initState();

    if (widget.controller != null) {
      widget.controller!.hasPrevious = hasPrevious;
      widget.controller!.hasNext = hasNext;
      widget.controller!.forward = forward;
      widget.controller!.backward = backward;
      widget.controller!.makeMove = makeMove;
      widget.controller!.undoLastMove = undoLastMove;
      widget.controller!.showMoveArrow = showMoveArrow;
      widget.controller!.removeMoveArrow = removeMoveArrow;
      widget.controller!.getNextPly = getNextPly;
      widget.controller!.getChessMoveFromSan = getChessMoveFromSan;
      widget.controller!.getLibraryBoard = () => _currentBoard!;
      widget.controller!.getMoveHistory = () => _moveHistory!;
      widget.controller!.reset = reset;
    }

    _currentBoard = chess.Chess.fromFEN(widget.fen);
    _boardPiecesWithKeys = loadBoardPiecesWithKeysFromFen(widget.fen);
    _moveHistory = ChessMoveHistory();
    _nextPly = 0;

    if (widget.postInitialize != null) {
      widget.postInitialize!();
    }
  }

  @override
  Widget build(BuildContext context) => _buildBoard();

  Widget _buildBoard() {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        children: [
          ...List<Widget>.generate(64, (index) => _buildSquare(index)),
          ..._boardPiecesWithKeys!.keys.map((piece) => _buildPiece(piece)).toList(),
          if (_arrowMove != null) _buildMoveArrow(),
        ],
      ),
    );
  }

  Widget _buildSquare(final int squareIndex) {
    final columnIndex = getColumnIndex(squareIndex);
    final rowIndex = getRowIndex(squareIndex);

    final chessSquare = ChessSquare(
      columnIndex: getColumnIndex(squareIndex),
      rowIndex: getRowIndex(squareIndex),
    );

    final actualChessSquare = ChessSquare(
      columnIndex: widget.flipped ? 7 - columnIndex : columnIndex,
      rowIndex: widget.flipped ? 7 - rowIndex : rowIndex,
    );

    return ChessBoardSquare(
      squareIndex: squareIndex,
      boardFlipped: widget.flipped,
      boardSize: widget.size,
      lightSquareColor: widget.lightSquareColor,
      darkSquareColor: widget.darkSquareColor,
      highlightSquareColor: widget.highlightSquareColor,
      markDragMoveToSquaresColor: widget.markDragMoveToSquaresColor,
      isLegalMoveToSquare: _isLegalMoveToSquare(chessSquare),
      isHighlightedSquare: _isHighlightedSquare(chessSquare),
      isPieceOnSquare: _isPieceOnSquare(actualChessSquare),
      onTap: _onTapSquare,
      onDragPieceEnd: _onDragPieceEnd,
    );
  }

  Widget _buildPiece(final ChessPiece piece) {
    final isMoving = _movingPieces != null && _movingPieces!.contains(piece);
    final isCaptured = piece.captured;

    final onDragEnd = () {
      setState(() {
        _dragFromSquare = null;
        _dragTargetSquare = null;
        _dragLegalMoves = null;
      });
    };

    return ChessBoardPiece(
      animatedKey: _boardPiecesWithKeys![piece],
      piece: piece,
      isMoving: isMoving,
      isCaptured: isCaptured,
      isLastCapturedPiece: piece == _lastCapturedPiece,
      boardFlipped: widget.flipped,
      dragToMakeMove: widget.dragToMakeMove,
      boardSize: widget.size,
      onTap: _onTapPiece,
      onDragPieceStart: _onDragPieceStart,
      onDragPieceEnd: _onDragPieceEnd,
      onDragEnd: onDragEnd,
    );
  }

  Widget _buildMoveArrow() {
    return ChessBoardMoveArrow(
      boardFlipped: widget.flipped,
      boardSize: widget.size,
      highlightSquareColor: widget.highlightSquareColor,
      arrowMove: _arrowMove!,
    );
  }

  // -----------------------------------------------
  // Chessboard Controller Function Implementations
  // -----------------------------------------------

  bool hasNext() {
    return _nextPly! < _moveHistory!.moves.length;
  }

  bool hasPrevious() {
    return _nextPly! > 0;
  }

  void forward({final bool dragMove = false}) {
    if (!hasNext()) {
      throw StateError('There is no next move.');
    }

    final boardBefore = _currentBoard!.copy();

    int currentMovePly = _nextPly!;
    var currentMove = _moveHistory!.moves[currentMovePly];

    var movingPiece = currentMove.movingPieces.first;

    _currentBoard!.make_move(currentMove.libraryMove);

    // Move moving piece
    setState(() {
      // Reset drag data
      _dragFromSquare = null;
      _dragTargetSquare = null;
      _dragPiece = null;
      _dragLegalMoves = null;

      // Remove captured piece after it faded out
      if (currentMove.capturedPiece != null) {
        currentMove.capturedPiece!.captured = true;
      }

      // Replace pawn with promoted piece
      if (currentMove.promotionPiece != null) {
        _boardPiecesWithKeys!.remove(movingPiece);
        _boardPiecesWithKeys![currentMove.promotionPiece!] = UniqueKey();
      }

      _movingPieces = currentMove.movingPieces;
      _moveFromSquare = currentMove.fromSquare;
      _moveToSquare = currentMove.toSquare;
      _lastCapturedPiece = currentMove.capturedPiece;

      movingPiece.rowIndex = currentMove.toSquare.rowIndex;
      movingPiece.columnIndex = currentMove.toSquare.columnIndex;

      if (currentMove.isCastling()) {
        var rookToSquare = currentMove.getCastlingRookToSquare();
        currentMove.movingPieces.last.columnIndex = rookToSquare.columnIndex;
        currentMove.movingPieces.last.rowIndex = rookToSquare.rowIndex;
      }

      _nextPly = _nextPly! + 1;

      if (widget.onBoardChange != null) {
        widget.onBoardChange!(boardBefore, _currentBoard!, currentMove);
      }
      if (dragMove && widget.onDragMoveSucceeded != null) {
        widget.onDragMoveSucceeded!(boardBefore, _currentBoard!, currentMove);
      }
    });
  }

  void backward() {
    if (!hasPrevious()) {
      throw StateError('There is no previous move.');
    }

    int lastMovePly = _nextPly! - 1;
    var lastMove = _moveHistory!.moves[lastMovePly];

    var movingPiece = lastMove.movingPieces.first;

    var fromSquareBeforeLastMove = lastMovePly == 0 ? null : _moveHistory!.moves[lastMovePly - 1].fromSquare;
    var toSquareBeforeLastMove = lastMovePly == 0 ? null : _moveHistory!.moves[lastMovePly - 1].toSquare;

    _currentBoard!.undo_move();

    chess.Chess? boardBefore;
    ChessMove? moveBefore;
    if (_currentBoard!.history.isNotEmpty) {
      boardBefore = _currentBoard!.copy();
      moveBefore = _moveHistory!.moves[_nextPly! - 2];
      boardBefore.undo_move();
    }

    // Move moving piece
    setState(() {
      // Reset drag data
      _dragFromSquare = null;
      _dragTargetSquare = null;
      _dragPiece = null;
      _dragLegalMoves = null;

      // Replace promoted piece with original pawn
      if (lastMove.promotionPiece != null) {
        _boardPiecesWithKeys![movingPiece] = UniqueKey();
        _boardPiecesWithKeys!.remove(lastMove.promotionPiece!);
      }

      if (lastMove.capturedPiece != null) {
        lastMove.capturedPiece!.captured = false;
      }

      _movingPieces = lastMove.movingPieces;
      _moveFromSquare = fromSquareBeforeLastMove;
      _moveToSquare = toSquareBeforeLastMove;
      _lastCapturedPiece = null;

      movingPiece.rowIndex = lastMove.fromSquare.rowIndex;
      movingPiece.columnIndex = lastMove.fromSquare.columnIndex;

      if (lastMove.isCastling()) {
        var rookFromSquare = lastMove.getCastlingRookFromSquare();
        lastMove.movingPieces.last.columnIndex = rookFromSquare.columnIndex;
        lastMove.movingPieces.last.rowIndex = rookFromSquare.rowIndex;
      }

      _nextPly = _nextPly! - 1;

      if (widget.onBoardChange != null) {
        widget.onBoardChange!(boardBefore, _currentBoard!, moveBefore);
      }
    });
  }

  void makeMove(final String sanMove, {final bool dragMove = false}) {
    if (_nextPly! != _moveHistory!.moves.length) {
      throw StateError('You are currently viewing a previous move. You can only make a new move when viewing the last move.');
    }

    final parsedMove = getChessMoveFromSan(sanMove);

    _moveHistory!.moves.add(parsedMove);
    forward(dragMove: dragMove);
  }

  void undoLastMove() {
    if (_nextPly! != _moveHistory!.moves.length) {
      throw StateError('You are currently viewing a previous move. You can only undo the last move when viewing the last move.');
    }

    backward();

    _moveHistory!.moves.removeLast();
  }

  void showMoveArrow(final String sanMove) {
    setState(() {
      _arrowMove = getChessMoveFromSan(sanMove);
    });
  }

  void removeMoveArrow() {
    setState(() {
      _arrowMove = null;
    });
  }

  int getNextPly() => _nextPly!;

  void reset() {
    setState(() {
      _currentBoard = chess.Chess.fromFEN(widget.fen);
      _boardPiecesWithKeys = loadBoardPiecesWithKeysFromFen(widget.fen);
      _moveHistory = ChessMoveHistory();
      _nextPly = 0;
      _movingPieces = null;
      _moveFromSquare = null;
      _moveToSquare = null;
      _lastCapturedPiece = null;
      _arrowMove = null;
    });
  }

  ChessMove getChessMoveFromSan(final String sanMove) {
    var parsedLibraryMove = parseSanMove(sanMove, _currentBoard!);
    return getChessMoveFromLibraryMove(parsedLibraryMove, _boardPiecesWithKeys!.keys.where((piece) => !piece.captured).toList(), _currentBoard!);
  }

  // -----------------------------------------------
  // Chessboard Drag To Make Move Handlers
  // -----------------------------------------------

  void _onTapSquare(final ChessSquare square) {
    if (_dragPiece == null) {
      return;
    }
    _onDragPieceEnd(square);
  }

  void _onTapPiece(final ChessPiece piece) async {
    final tappedSquare = getSquareByPiece(piece);

    if (_dragFromSquare == tappedSquare) {
      setState(() {
        _dragFromSquare = null;
        _dragTargetSquare = null;
        _dragPiece = null;
        _dragLegalMoves = null;
      });
      return;
    }

    // Check if move is legal drag moves
    if (_dragPiece != null && _dragLegalMoves != null) {
      final fromSquare = getSquareByPiece(_dragPiece!);

      final movesMatched = _dragLegalMoves!.where((move) {
        return fromSquare.columnIndex == move.fromSquare.columnIndex &&
            fromSquare.rowIndex == move.fromSquare.rowIndex &&
            tappedSquare.columnIndex == move.toSquare.columnIndex &&
            tappedSquare.rowIndex == move.toSquare.rowIndex;
      });

      if (movesMatched.isNotEmpty) {
        await _makeDragMove(piece, tappedSquare, movesMatched.toList());
        return;
      }
    }

    _onDragPieceStart(piece, tappedSquare);
  }

  void _onDragPieceStart(final ChessPiece piece, final ChessSquare fromSquare) {
    final legalMoves = _currentBoard!
        .generate_moves()
        .map((move) => getChessMoveFromLibraryMove(move, _boardPiecesWithKeys!.keys.where((piece) => !piece.captured).toList(), _currentBoard!))
        .where((chessMove) => chessMove.fromSquare == fromSquare)
        .toList();

    setState(() {
      _dragFromSquare = fromSquare;
      _dragPiece = piece;
      _dragTargetSquare = null;
      _dragLegalMoves = legalMoves;
    });
  }

  void _onDragPieceEnd(final ChessSquare toSquare) async {
    final movesMatched = _dragLegalMoves!.where((move) {
      return _dragPiece!.columnIndex == move.fromSquare.columnIndex &&
          _dragPiece!.rowIndex == move.fromSquare.rowIndex &&
          toSquare.columnIndex == move.toSquare.columnIndex &&
          toSquare.rowIndex == move.toSquare.rowIndex;
    });

    // Check if move is legal drag moves
    if (movesMatched.isNotEmpty) {
      await _makeDragMove(_dragPiece!, toSquare, movesMatched.toList());
    }

    setState(() {
      _dragFromSquare = null;
      _dragTargetSquare = null;
      _dragPiece = null;
      _dragLegalMoves = null;
    });
  }

  Future<void> _makeDragMove(final ChessPiece piece, final ChessSquare toSquare, final List<ChessMove> movesMatched) async {
    if (movesMatched.isEmpty) {
      throw ArgumentError('Given moves matched list may not be empty');
    }

    final isPromotion = (piece.type == ChessPieceTypeEnum.whitePawn || piece.type == ChessPieceTypeEnum.blackPawn) && (toSquare.rowIndex == 0 || toSquare.rowIndex == 7);

    final moveToPlay;
    if (isPromotion) {
      final promotionPieceType = await showPromotionDialog(context, _currentBoard!.turn);
      if (promotionPieceType == null) {
        return;
      }
      moveToPlay = movesMatched.firstWhere((move) => move.promotionPiece!.type == promotionPieceType);
    } else {
      moveToPlay = movesMatched.first;
    }

    // Clear history for moves following current board state
    while (hasNext()) {
      _moveHistory!.moves.removeLast();
    }

    // Play actual move
    makeMove(moveToPlay.sanMove, dragMove: true);
  }

  // -----------------------------------------------
  // Chessboard Helper Utils
  // -----------------------------------------------

  bool _isPieceOnSquare(final ChessSquare actualChessSquare) {
    return _boardPiecesWithKeys!.keys.any((piece) => !piece.captured && piece.columnIndex == actualChessSquare.columnIndex && piece.rowIndex == actualChessSquare.rowIndex);
  }

  bool _isHighlightedSquare(final ChessSquare chessSquare) {
    if (!widget.flipped) {
      return chessSquare == _moveFromSquare || chessSquare == _moveToSquare || chessSquare == _dragFromSquare || chessSquare == _dragTargetSquare;
    }

    if (_moveFromSquare != null && (7 - chessSquare.rowIndex) == _moveFromSquare!.rowIndex && (7 - chessSquare.columnIndex) == _moveFromSquare!.columnIndex) {
      return true;
    }

    if (_moveToSquare != null && (7 - chessSquare.rowIndex) == _moveToSquare!.rowIndex && (7 - chessSquare.columnIndex) == _moveToSquare!.columnIndex) {
      return true;
    }

    if (_dragFromSquare != null && (7 - chessSquare.rowIndex) == _dragFromSquare!.rowIndex && (7 - chessSquare.columnIndex) == _dragFromSquare!.columnIndex) {
      return true;
    }

    if (_dragTargetSquare != null && (7 - chessSquare.rowIndex) == _dragTargetSquare!.rowIndex && (7 - chessSquare.columnIndex) == _dragTargetSquare!.columnIndex) {
      return true;
    }

    return false;
  }

  bool _isLegalMoveToSquare(final ChessSquare chessSquare) {
    if (_dragLegalMoves == null) {
      return false;
    }

    if (!widget.flipped) {
      return _dragLegalMoves!.any((chessMove) => chessMove.toSquare == chessSquare);
    }

    return _dragLegalMoves!.any((chessMove) => chessMove.toSquare.columnIndex == (7 - chessSquare.columnIndex) && chessMove.toSquare.rowIndex == (7 - chessSquare.rowIndex));
  }
}
