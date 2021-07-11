import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:guess_the_move/bloc/points_bloc.dart';
import 'package:guess_the_move/main.dart';
import 'package:guess_the_move/model/analyzed_game.dart';
import 'package:guess_the_move/model/analyzed_games_bundle.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/model/game_played_info.dart';
import 'package:guess_the_move/model/puzzle_game_played.dart';
import 'package:guess_the_move/model/user_settings.dart';
import 'package:guess_the_move/repository/dao/points_dao.dart';
import 'package:guess_the_move/repository/dao/puzzle_games_played_dao.dart';
import 'package:guess_the_move/screens/game_modes/components/chess_board/chessboard_model.dart';
import 'package:guess_the_move/screens/game_modes/components/chess_board/utils/san_utils.dart';
import 'package:guess_the_move/screens/game_modes/puzzle/components/puzzle_timer.dart';
import 'package:guess_the_move/theme/theme.dart';
import 'package:meta/meta.dart';
import 'package:sembast/sembast.dart';

part 'puzzle_event.dart';
part 'puzzle_state.dart';

class PuzzleBloc extends Bloc<PuzzleEvent, PuzzleState> {
  static final int maxPointsForCorrectPuzzleMove = 50;
  static final int discountPointsForWrongTry = 10;
  static final int buyNextTipPrice = 10;
  static final int maxMateDepth = 5;

  final Database? database;
  final PuzzleTimerController puzzleTimerController;
  final Function? handleError;
  final AnalyzedGamesBundle analyzedGamesOriginBundle;
  final List<AnalyzedGame> analyzedGamesInBundle;
  final ChessBoardController chessBoardController;
  final UserSettings userSettings;

  List<PuzzleIngameState> puzzlesPlayedStates;

  PuzzleBloc(
    final PuzzleGuessMove initialState,
    this.puzzleTimerController,
    this.chessBoardController,
    this.analyzedGamesOriginBundle,
    this.analyzedGamesInBundle,
    this.userSettings, {
    this.database,
    this.handleError,
  })  : this.puzzlesPlayedStates = [initialState],
        super(initialState);

  @override
  void onError(Object error, StackTrace stackTrace) {
    if (handleError != null) {
      handleError!(error, stackTrace);
      return;
    }
    super.onError(error, stackTrace);
  }

  @override
  Stream<PuzzleState> mapEventToState(
    PuzzleEvent event,
  ) async* {
    if (event is PuzzlePlayMoveEvent) {
      if (!(state is PuzzleGuessMove)) {
        throw StateError('You can only play moves when in guessing puzzle state.');
      }

      final ingameState = state as PuzzleIngameState;

      if (_isCorrectMove(event.sanMove)) {
        var pointsGiven = 0;

        if (!ingameState.wasAlreadySolved) {
          pointsGiven = max(0, maxPointsForCorrectPuzzleMove - ingameState.wrongTries * discountPointsForWrongTry);
          event.pointsBloc.add(AddPoints(pointsGiven));
        }

        final newState = PuzzleCorrectMove(
            ingameState.analyzedGame,
            ingameState.analyzedGameOriginBundle,
            ingameState.puzzleMove,
            ingameState.startTime,
            ingameState.wrongTries,
            true,
            ingameState.showPieceTypeTipUsed,
            ingameState.showActualPieceTipUsed,
            ingameState.showActualMoveTipUsed,
            event.sanMove,
            pointsGiven,
            puzzleTimerController.getTimePassedInMilliseconds!());
        puzzlesPlayedStates.removeLast();
        puzzlesPlayedStates.add(newState);

        yield newState;
      } else {
        final newState = PuzzleWrongMove(ingameState.analyzedGame, ingameState.analyzedGameOriginBundle, ingameState.puzzleMove, ingameState.startTime, event.sanMove,
            ingameState.wrongTries + 1, ingameState.wasAlreadySolved, ingameState.showPieceTypeTipUsed, ingameState.showActualPieceTipUsed, ingameState.showActualMoveTipUsed);
        puzzlesPlayedStates.removeLast();
        puzzlesPlayedStates.add(newState);

        yield newState;
      }
    } else if (event is PuzzleShowNextTipEvent) {
      if (!(state is PuzzleGuessMove)) {
        throw StateError('You can only show a next tip when guessing a move.');
      }

      final currentPoints = await PointsDao(database: database).get();

      if (currentPoints.amount < buyNextTipPrice) {
        if (event.context != null) {
          showDialog<void>(
            context: event.context!,
            builder: (BuildContext context) => AlertDialog(
              title: Text('Zu wenig Punkte'),
              content: Text('Du benötigst $buyNextTipPrice Punkte um den nächsten Tipp freischalten zu können'),
              actions: <Widget>[
                TextButton(
                  child: Text('Ok'),
                  style: TextButton.styleFrom(
                    primary: appTheme(context, userSettings.themeMode).gameModeThemes[GameModeEnum.puzzleMode]!.accentColor,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        }

        yield state;
        return;
      }

      event.pointsBloc.add(RemovePoints(buyNextTipPrice));

      final guessingState = state as PuzzleGuessMove;

      final PuzzleGuessMove newState;
      if (!guessingState.showPieceTypeTipUsed) {
        newState = guessingState.copyWith(showPieceTypeTipUsed: true);
      } else if (!guessingState.showActualPieceTipUsed) {
        newState = guessingState.copyWith(showActualPieceTipUsed: true);
      } else if (!guessingState.showActualMoveTipUsed) {
        newState = guessingState.copyWith(showActualMoveTipUsed: true);
      } else {
        throw StateError('No more next tip to show available.');
      }

      puzzlesPlayedStates.removeLast();
      puzzlesPlayedStates.add(newState);

      yield newState;
    } else if (event is PuzzleRetryCurrentPuzzleEvent) {
      if (!(state is PuzzleWrongMove || state is PuzzleCorrectMove)) {
        throw StateError('You can only retry the current puzzle after guessing a move.');
      }

      final ingameState = state as PuzzleIngameState;
      final isPuzzleSolved = ingameState.wasAlreadySolved || ingameState is PuzzleCorrectMove;

      chessBoardController.undoLastMove!();

      final newState = PuzzleGuessMove(ingameState.analyzedGame, ingameState.analyzedGameOriginBundle, ingameState.puzzleMove, ingameState.startTime, ingameState.wrongTries,
          isPuzzleSolved, ingameState.showPieceTypeTipUsed, ingameState.showActualPieceTipUsed, ingameState.showActualMoveTipUsed, false);
      puzzlesPlayedStates.removeLast();
      puzzlesPlayedStates.add(newState);

      yield newState;
    } else if (event is PuzzleShowNextPuzzleEvent) {
      if (!(state is PuzzleCorrectMove || state is PuzzleWrongMove)) {
        throw StateError('You can only go to next puzzle after guessing a move');
      }

      final newPuzzleState = buildNewPuzzleState(analyzedGamesOriginBundle, analyzedGamesInBundle, puzzlesPlayedStates);

      if (newPuzzleState == null) {
        yield _buildGameOverState();
      } else {
        chessBoardController.reset!();
        for (final analyzedMove in newPuzzleState.analyzedGame.gameAnalysis.analyzedMoves) {
          if (analyzedMove == newPuzzleState.puzzleMove) {
            break;
          }
          chessBoardController.makeMove!(analyzedMove.actualMove.move.san);
        }

        puzzlesPlayedStates.add(newPuzzleState);
        yield newPuzzleState;
      }
    } else if (event is PuzzleEndGameEvent) {
      yield _buildGameOverState();
    }
  }

  bool _isCorrectMove(final String sanMove) {
    return sanitizeSanMove((state as PuzzleIngameState).puzzleMove.actualMove.move.san) == sanitizeSanMove(sanMove);
  }

  PuzzleGameOver _buildGameOverState() {
    final puzzlesPlayed = puzzlesPlayedStates
        .map(
          (state) => PuzzlePlayed(
            analyzedGameId: state.analyzedGame.id,
            gamePlayedInfo: GamePlayedInfo(
              analyzedGameId: state.analyzedGame.id,
              whitePlayer: state.analyzedGame.whitePlayer,
              blackPlayer: state.analyzedGame.blackPlayer,
              whitePlayerRating: state.analyzedGame.whitePlayerRating,
              blackPlayerRating: state.analyzedGame.blackPlayerRating,
              grandmasterSide: state.analyzedGame.gameAnalysis.grandmasterSide,
              gameInfoString: state.analyzedGame.gameInfo.toString(),
            ),
            puzzleMove: state.puzzleMove,
            startTime: state.startTime,
            wrongTries: state.wrongTries,
            wasAlreadySolved: state.wasAlreadySolved,
            showPieceTypeTipUsed: state.showPieceTypeTipUsed,
            showActualPieceTipUsed: state.showActualPieceTipUsed,
            timeNeededInMilliseconds: state is PuzzleCorrectMove ? puzzleTimerController.getTimePassedInMilliseconds!() : null,
            showActualMoveTipUsed: state.showActualMoveTipUsed,
            pointsGiven: state is PuzzleCorrectMove ? state.pointsGiven : null,
          ),
        )
        .toList();

    final ingameState = state as PuzzleIngameState;
    final playedTimestamp = DateTime.now().millisecondsSinceEpoch;

    PuzzleGamesPlayedDao(database: database).insert(
      PuzzleGamePlayed(
        analyzedGameOriginBundle: ingameState.analyzedGameOriginBundle,
        grandmaster: ingameState.analyzedGame.getGrandmaster(),
        puzzlesPlayed: puzzlesPlayed,
        totalPointsGivenAmount: getPuzzleGamePointsScore(puzzlesPlayed),
        playedDateTimestamp: playedTimestamp,
      ),
    );

    return PuzzleGameOver(analyzedGamesOriginBundle, analyzedGamesInBundle, puzzlesPlayed, DateTime.now().millisecondsSinceEpoch);
  }

  static bool hasPuzzle(final List<AnalyzedGame> allGamesInBundle) {
    for (final analyzedGame in allGamesInBundle) {
      for (final analyzedMove in analyzedGame.gameAnalysis.analyzedMoves) {
        if (analyzedMove.turn != analyzedGame.gameAnalysis.grandmasterSide || !_isGrandmasterMoveRelevantForPuzzleMove(analyzedMove)) {
          continue;
        }
        return true;
      }
    }
    return false;
  }

  static PuzzleGuessMove? buildNewPuzzleState(
      final AnalyzedGamesBundle analyzedGamesOriginBundle, final List<AnalyzedGame> allGamesInBundle, List<PuzzleIngameState> puzzlesPlayedStates) {
    final DateTime startTime = DateTime.now();

    final allPuzzles = [];
    for (final analyzedGame in allGamesInBundle) {
      for (final analyzedMove in analyzedGame.gameAnalysis.analyzedMoves) {
        if (analyzedMove.turn != analyzedGame.gameAnalysis.grandmasterSide ||
            puzzlesPlayedStates.any((puzzlePlayedState) => puzzlePlayedState.puzzleMove == analyzedMove) ||
            !_isGrandmasterMoveRelevantForPuzzleMove(analyzedMove)) {
          continue;
        }

        allPuzzles.add(PuzzleGuessMove(analyzedGame, analyzedGamesOriginBundle, analyzedMove, startTime, 0, false, false, false, false, true));
      }
    }

    return allPuzzles.isNotEmpty ? allPuzzles[MyApp.random.nextInt(allPuzzles.length)] : null;
  }

  static bool _isGrandmasterMoveRelevantForPuzzleMove(final AnalyzedMove analyzedMove) {
    return analyzedMove.actualMove.moveType == AnalyzedMoveType.critical || _isGrandmasterMoveOnlyMateScoreMove(analyzedMove);
  }

  static bool _isGrandmasterMoveOnlyMateScoreMove(final AnalyzedMove analyzedMove) {
    return analyzedMove.actualMove.signedCPScore.startsWith('M') &&
        !analyzedMove.alternativeMoves.any((alternativeMove) => alternativeMove.signedCPScore.startsWith('M')) &&
        int.parse(analyzedMove.actualMove.signedCPScore.replaceAll('M', '').replaceAll('-', '')) <= maxMateDepth;
  }
}
