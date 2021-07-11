import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guess_the_move/bloc/points_bloc.dart';
import 'package:guess_the_move/main.dart';
import 'package:guess_the_move/model/analyzed_game.dart';
import 'package:guess_the_move/model/analyzed_games_bundle.dart';
import 'package:guess_the_move/model/find_the_grandmaster_moves_game_played.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/model/game_played_info.dart';
import 'package:guess_the_move/model/summary_data.dart';
import 'package:guess_the_move/model/survival_game_played.dart';
import 'package:guess_the_move/model/time_battle_game_played.dart';
import 'package:guess_the_move/model/user_settings.dart';
import 'package:guess_the_move/repository/analyzed_games_repository.dart';
import 'package:guess_the_move/repository/dao/find_the_grandmaster_moves_games_played_dao.dart';
import 'package:guess_the_move/repository/dao/points_dao.dart';
import 'package:guess_the_move/repository/dao/survival_games_played_dao.dart';
import 'package:guess_the_move/repository/dao/time_battle_games_played_dao.dart';
import 'package:guess_the_move/screens/game_modes/components/chess_board/chessboard_model.dart';
import 'package:guess_the_move/theme/theme.dart';
import 'package:sembast/sembast.dart';

part 'find_the_grandmaster_moves_event.dart';
part 'find_the_grandmaster_moves_state.dart';

class FindTheGrandmasterMovesBloc extends Bloc<FindTheGrandmasterMovesEvent, FindTheGrandmasterMovesState> {
  static final int buyNextTipPrice = 5;

  final Database? database;
  final GameModeEnum gameMode;
  final ChessBoardController chessBoardController;
  final Function? handleError;
  final UserSettings userSettings;

  List<AnalyzedGame> analyzedGamesPlayed = [];
  List<SummaryData> analyzedGamesSummaryData = [];
  List<FindTheGrandmasterMovesState> screenStateHistory = [];
  int viewerScreenStateIndex = 0;

  FindTheGrandmasterMovesBloc(final FindTheGrandmasterMovesState initialState, this.gameMode, this.chessBoardController, this.userSettings, {this.database, this.handleError})
      : this.analyzedGamesPlayed = [initialState.analyzedGame],
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
  Stream<FindTheGrandmasterMovesState> mapEventToState(
    FindTheGrandmasterMovesEvent event,
  ) async* {
    if (event is FindTheGrandmasterMovesSelectGuessEvent) {
      yield _handleSelectGuessEvent(event);
    } else if (event is FindTheGrandmasterMovesUnselectGuessEvent) {
      yield _handleUnselectGuessEvent(event);
    } else if (event is FindTheGrandmasterMovesShowNextTipEvent) {
      yield await _handleShowNextTipEvent(event);
    } else if (event is FindTheGrandmasterMovesSubmitGuessEvent) {
      yield _handleSubmitGuessEvent(event);
    } else if (event is FindTheGrandmasterMovesRevealOpponentMoveEvent) {
      yield _handleRevealOpponentMoveEvent(event);
    } else if (event is FindTheGrandmasterMovesGoToPreviousStateEvent) {
      yield _handleGoToPreviousStateEvent(event);
    } else if (event is FindTheGrandmasterMovesGoToNextStateEvent) {
      yield await _handleGoToNextStateEvent(event);
    } else if (event is FindTheGrandmasterMovesEndTimeBattleGameEvent) {
      yield _handleEndTimeBattleGame(event);
    } else if (event is FindTheGrandmasterMovesEndSurvivalGameEvent) {
      yield _handleEndSurvivalGame(event);
    } else {
      throw UnimplementedError('Unsupported event.');
    }
  }

  FindTheGrandmasterMovesState _handleSelectGuessEvent(final FindTheGrandmasterMovesSelectGuessEvent event) {
    var guessingState = state as FindTheGrandmasterMovesGuessingMove;

    var newState = FindTheGrandmasterMovesGuessingPreviewGuessMove(
      guessingState.analyzedGame,
      guessingState.gameMode,
      guessingState.analyzedGameOriginBundle,
      guessingState.move,
      guessingState.shuffledAnswerMoves,
      guessingState.showPieceTypeTipUsed,
      guessingState.showActualPieceTipUsed,
      guessingState.removeWorstAnswerTipUsed,
      event.moveSelected,
    );

    screenStateHistory.removeLast();
    screenStateHistory.add(newState);

    // Perform makeMove(selected move) on chess board controller
    chessBoardController.makeMove!(event.moveSelected.move.san);

    return newState;
  }

  FindTheGrandmasterMovesState _handleUnselectGuessEvent(final FindTheGrandmasterMovesUnselectGuessEvent event) {
    var previewState = state as FindTheGrandmasterMovesGuessingMove;

    var newState = FindTheGrandmasterMovesGuessingMove(
      previewState.analyzedGame,
      previewState.gameMode,
      previewState.analyzedGameOriginBundle,
      previewState.move,
      previewState.shuffledAnswerMoves,
      previewState.showPieceTypeTipUsed,
      previewState.showActualPieceTipUsed,
      previewState.removeWorstAnswerTipUsed,
    );
    screenStateHistory.removeLast();
    screenStateHistory.add(newState);

    // Perform undoLastMove on chess board controller
    chessBoardController.undoLastMove!();

    return newState;
  }

  Future<FindTheGrandmasterMovesState> _handleShowNextTipEvent(final FindTheGrandmasterMovesShowNextTipEvent event) async {
    final currentPoints = await PointsDao(database: database).get();

    if (currentPoints.amount < buyNextTipPrice) {
      if (event.context != null) {
        showDialog<void>(
          context: event.context!,
          builder: (BuildContext context) => AlertDialog(
            title: Text('Zu wenig Punkte'),
            content: Text('Du benötigst 5 Punkte um den nächsten Tipp freischalten zu können'),
            actions: <Widget>[
              TextButton(
                child: Text('Ok'),
                style: TextButton.styleFrom(
                  primary: appTheme(context, userSettings.themeMode).gameModeThemes[state.gameMode]!.accentColor,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      }
      return state;
    }

    event.pointsBloc.add(RemovePoints(buyNextTipPrice));

    final guessingState = state as FindTheGrandmasterMovesGuessingMove;
    final newState;

    if (!guessingState.removeWorstAnswerTipUsed) {
      newState = guessingState.copyWith(removeWorstAnswerTipUsed: true);
    } else if (!guessingState.showPieceTypeTipUsed) {
      newState = guessingState.copyWith(showPieceTypeTipUsed: true);
    } else if (!guessingState.showActualPieceTipUsed) {
      newState = guessingState.copyWith(showActualPieceTipUsed: true);
    } else {
      throw StateError('No more next tip to show available.');
    }

    screenStateHistory.removeLast();
    screenStateHistory.add(newState);

    return newState;
  }

  FindTheGrandmasterMovesState _handleSubmitGuessEvent(final FindTheGrandmasterMovesSubmitGuessEvent event) {
    viewerScreenStateIndex++;
    if (viewerScreenStateIndex < screenStateHistory.length || !(state is FindTheGrandmasterMovesGuessingPreviewGuessMove)) {
      throw StateError('You can only make a guess when in a preview guess state!');
    }

    // do not add state to history because we do not want to to gack to guessing states

    var guessingState = state as FindTheGrandmasterMovesGuessingPreviewGuessMove;

    var currentMove = guessingState.move;
    var moveSelected = guessingState.moveSelected;
    var grandmasterMovePlayed = moveSelected == currentMove.actualMove;
    var guessEvaluationType = moveSelected.moveType;

    var pointsGiven;
    if (grandmasterMovePlayed ||
        guessEvaluationType == AnalyzedMoveType.best ||
        guessEvaluationType == AnalyzedMoveType.brilliant ||
        guessEvaluationType == AnalyzedMoveType.gameChanger ||
        guessEvaluationType == AnalyzedMoveType.critical) {
      pointsGiven = bestMovePlayedPointsGiven;
    } else if (guessEvaluationType == AnalyzedMoveType.blunder || guessEvaluationType == AnalyzedMoveType.mistake || guessEvaluationType == AnalyzedMoveType.inaccuracy) {
      pointsGiven = badMovePlayedPointsGiven;
    } else {
      pointsGiven = mediocreMovePlayedPointsGiven;
    }

    event.pointsBloc.add(AddPoints(pointsGiven));

    // Undo guessed move
    chessBoardController.undoLastMove!();

    var newState = FindTheGrandmasterMovesGuessEvaluated(guessingState.analyzedGame, guessingState.gameMode, guessingState.analyzedGameOriginBundle, currentMove,
        guessingState.shuffledAnswerMoves, moveSelected, grandmasterMovePlayed, guessEvaluationType, pointsGiven);
    screenStateHistory.add(newState);

    // Show move arrow
    chessBoardController.showMoveArrow!(newState.move.actualMove.move.san);

    return newState;
  }

  FindTheGrandmasterMovesState _handleRevealOpponentMoveEvent(final FindTheGrandmasterMovesRevealOpponentMoveEvent event) {
    var opponentPlayingState = state as FindTheGrandmasterMovesOpponentPlayingMove;

    var newState = FindTheGrandmasterMovesOpponentPlayingMove(
      opponentPlayingState.analyzedGame,
      opponentPlayingState.gameMode,
      opponentPlayingState.analyzedGameOriginBundle,
      opponentPlayingState.move,
      true,
    );
    screenStateHistory.removeLast();
    screenStateHistory.add(newState);

    // Show move arrow
    chessBoardController.showMoveArrow!(newState.move.actualMove.move.san);

    return newState;
  }

  FindTheGrandmasterMovesState _handleGoToPreviousStateEvent(final FindTheGrandmasterMovesGoToPreviousStateEvent event) {
    if (viewerScreenStateIndex == 0) {
      throw StateError('You are already in the first state.');
    }

    // Undo guessing move in preview if existing
    if (state is FindTheGrandmasterMovesGuessingPreviewGuessMove) {
      chessBoardController.undoLastMove!();
    }

    viewerScreenStateIndex--;

    var previousState = screenStateHistory[viewerScreenStateIndex];

    // Backward on chess board controller
    chessBoardController.backward!();

    if (previousState is FindTheGrandmasterMovesGuessingPreviewGuessMove) {
      // skip old guessing states
      previousState = screenStateHistory[--viewerScreenStateIndex];
    }

    // Show move arrow
    chessBoardController.showMoveArrow!((previousState as FindTheGrandmasterMovesIngameState).move.actualMove.move.san);

    return previousState.copyWith();
  }

  Future<FindTheGrandmasterMovesState> _handleGoToNextStateEvent(final FindTheGrandmasterMovesGoToNextStateEvent event) async {
    if (viewerScreenStateIndex < (screenStateHistory.length - 1)) {
      return _handleGoToOldNextState();
    }
    return _handleGoToNewNextState();
  }

  FindTheGrandmasterMovesState _handleGoToOldNextState() {
    viewerScreenStateIndex++;

    if (screenStateHistory[viewerScreenStateIndex] is FindTheGrandmasterMovesGuessingMove && viewerScreenStateIndex < (screenStateHistory.length - 1)) {
      // skip old guessing states
      viewerScreenStateIndex++;
    }

    // Forward on chess board controller
    chessBoardController.forward!();

    var newState = screenStateHistory[viewerScreenStateIndex].copyWith();

    // play selected guessing move in preview again
    if (newState is FindTheGrandmasterMovesGuessingPreviewGuessMove) {
      chessBoardController.makeMove!(newState.moveSelected.move.san);
    }

    // Remove move arrow
    chessBoardController.removeMoveArrow!();

    // Show move arrow if not guessing gm or opponent move
    if (!(newState is FindTheGrandmasterMovesGuessingMove ||
        newState is FindTheGrandmasterMovesShowingSummary ||
        (newState is FindTheGrandmasterMovesOpponentPlayingMove && !newState.moveRevealed))) {
      chessBoardController.showMoveArrow!((newState as FindTheGrandmasterMovesIngameState).move.actualMove.move.san);
    }

    // we are exploring a previous state instead of going to a new state
    return newState;
  }

  Future<FindTheGrandmasterMovesState> _handleGoToNewNextState() async {
    viewerScreenStateIndex++;

    if (state is FindTheGrandmasterMovesShowingOpening) {
      return _handleGoToNewNextStateFromOpeningState();
    } else if (state is FindTheGrandmasterMovesGuessEvaluated) {
      return _handleGoToNewNextStateFromGuessEvaluatedState();
    } else if (state is FindTheGrandmasterMovesOpponentPlayingMove) {
      return _handleGoToNewNextStateFromOpponentPlayingMoveState();
    } else if (state is FindTheGrandmasterMovesPostgameState) {
      if (gameMode == GameModeEnum.findTheGrandmasterMoves) {
        throw StateError('You are already in the last state.');
      }
      return await _handleGoToNewNextGame();
    } else if (state is FindTheGrandmasterMovesGuessingMove) {
      throw StateError('You have to make a guess first.');
    } else {
      throw StateError('Illegal state');
    }
  }

  FindTheGrandmasterMovesState _handleGoToNewNextStateFromOpeningState() {
    var openingState = state as FindTheGrandmasterMovesShowingOpening;

    // Play current move on chess board controller
    chessBoardController.makeMove!(openingState.move.actualMove.move.san);

    FindTheGrandmasterMovesIngameState newState;
    var nextMove = openingState.analyzedGame.gameAnalysis.analyzedMoves[openingState.move.ply + 1];
    var isGrandmasterTurn = nextMove.turn == openingState.analyzedGame.gameAnalysis.grandmasterSide;

    if (openingState.isLastOpeningMove()) {
      if (isGrandmasterTurn) {
        // show grandmaster guessing move
        var shuffledAnswerMoves = ([nextMove.actualMove] + nextMove.alternativeMoves);
        shuffledAnswerMoves.shuffle();

        newState = FindTheGrandmasterMovesGuessingMove(
            openingState.analyzedGame, openingState.gameMode, openingState.analyzedGameOriginBundle, nextMove, shuffledAnswerMoves, false, false, false);

        // Remove existing move arrow
        chessBoardController.removeMoveArrow!();
      } else {
        // show opponent move
        final revealOpponentMove = _shouldRevealOpponentMoves();

        newState = FindTheGrandmasterMovesOpponentPlayingMove(
          openingState.analyzedGame,
          openingState.gameMode,
          openingState.analyzedGameOriginBundle,
          nextMove,
          revealOpponentMove,
        );

        // Remove existing move arrow
        chessBoardController.removeMoveArrow!();

        // Show move arrow if move revealed
        if (revealOpponentMove) {
          chessBoardController.showMoveArrow!(newState.move.actualMove.move.san);
        }
      }
    } else {
      // show next opening move
      newState = FindTheGrandmasterMovesShowingOpening(openingState.analyzedGame, openingState.gameMode, openingState.analyzedGameOriginBundle, nextMove);

      // Show move arrow
      chessBoardController.showMoveArrow!(newState.move.actualMove.move.san);
    }

    screenStateHistory.add(newState);

    return newState;
  }

  FindTheGrandmasterMovesState _handleGoToNewNextStateFromGuessEvaluatedState() {
    var guessEvaluatedState = state as FindTheGrandmasterMovesGuessEvaluated;

    // Play actual grandmaster move on chess board controller
    chessBoardController.makeMove!(guessEvaluatedState.move.actualMove.move.san);

    final FindTheGrandmasterMovesState newState;
    if (guessEvaluatedState.isLastMove()) {
      newState = _buildSummaryState();
    } else {
      // show opponent move
      var nextMove = guessEvaluatedState.analyzedGame.gameAnalysis.analyzedMoves[guessEvaluatedState.move.ply + 1];

      final revealOpponentMove = _shouldRevealOpponentMoves();

      newState = FindTheGrandmasterMovesOpponentPlayingMove(
        guessEvaluatedState.analyzedGame,
        guessEvaluatedState.gameMode,
        guessEvaluatedState.analyzedGameOriginBundle,
        nextMove,
        revealOpponentMove,
      );

      // Remove existing move arrow
      chessBoardController.removeMoveArrow!();

      // Show move arrow if move revealed
      if (revealOpponentMove) {
        chessBoardController.showMoveArrow!(nextMove.actualMove.move.san);
      }
    }

    screenStateHistory.add(newState);

    return newState;
  }

  FindTheGrandmasterMovesState _handleGoToNewNextStateFromOpponentPlayingMoveState() {
    var opponentPlayingState = state as FindTheGrandmasterMovesOpponentPlayingMove;

    // Play opponent move on chess board controller
    chessBoardController.makeMove!(opponentPlayingState.move.actualMove.move.san);

    FindTheGrandmasterMovesState newState;
    var nextMove = opponentPlayingState.analyzedGame.gameAnalysis.analyzedMoves[opponentPlayingState.move.ply + 1];

    if (opponentPlayingState.isLastMove()) {
      newState = _buildSummaryState();
    } else {
      // show grandmaster guessing move
      var shuffledAnswerMoves = ([nextMove.actualMove] + nextMove.alternativeMoves);
      shuffledAnswerMoves.shuffle();

      // Remove existing move arrow
      chessBoardController.removeMoveArrow!();

      newState = FindTheGrandmasterMovesGuessingMove(
          opponentPlayingState.analyzedGame, opponentPlayingState.gameMode, opponentPlayingState.analyzedGameOriginBundle, nextMove, shuffledAnswerMoves, false, false, false);
    }

    screenStateHistory.add(newState);

    return newState;
  }

  Future<FindTheGrandmasterMovesState> _handleGoToNewNextGame() async {
    final bundle = state.analyzedGameOriginBundle;
    final allGamesInBundle = await loadAnalyzedGamesInBundle(bundle);

    var newRandomGame = allGamesInBundle[MyApp.random.nextInt(allGamesInBundle.length)];
    while (analyzedGamesPlayed.contains(newRandomGame)) {
      newRandomGame = allGamesInBundle[MyApp.random.nextInt(allGamesInBundle.length)];
    }

    analyzedGamesPlayed.add(newRandomGame);

    screenStateHistory.clear();
    viewerScreenStateIndex = 0;

    final initialState = FindTheGrandmasterMovesShowingOpening(newRandomGame, gameMode, bundle, newRandomGame.gameAnalysis.analyzedMoves.first);

    screenStateHistory.add(initialState);

    return initialState;
  }

  FindTheGrandmasterMovesState _buildSummaryState() {
    final summaryData = _buildSummaryDataForCurrentGame();
    final playedDateTimestamp = DateTime.now().millisecondsSinceEpoch;

    analyzedGamesSummaryData.add(summaryData);

    if (gameMode == GameModeEnum.findTheGrandmasterMoves) {
      _saveFindTheGrandmasterMovesGamePlayed(summaryData, playedDateTimestamp);
    }

    return FindTheGrandmasterMovesShowingSummary(state.analyzedGame, state.gameMode, state.analyzedGameOriginBundle, summaryData, playedDateTimestamp);
  }

  SummaryData _buildSummaryDataForCurrentGame() {
    final List<SummaryDataGuessEvaluated> guessEvaluatedStates =
        screenStateHistory.where((oldState) => oldState is FindTheGrandmasterMovesGuessEvaluated && oldState.analyzedGame == state.analyzedGame).map((state) {
      final FindTheGrandmasterMovesGuessEvaluated guessEvaluatedState = state as FindTheGrandmasterMovesGuessEvaluated;
      return SummaryDataGuessEvaluated(
        guessEvaluatedState.move,
        guessEvaluatedState.shuffledAnswerMoves,
        guessEvaluatedState.chosenMove,
        guessEvaluatedState.grandmasterMovePlayed,
        guessEvaluatedState.chosenMoveType,
        guessEvaluatedState.pointsGiven,
      );
    }).toList();

    return SummaryData(guessEvaluatedStates);
  }

  void _saveFindTheGrandmasterMovesGamePlayed(final SummaryData summaryData, final int playedDateTimestamp) {
    FindTheGrandmasterMovesGamesPlayedDao(database: database).insert(FindTheGrandmasterMovesGamePlayed(
      analyzedGameId: state.analyzedGame.id,
      analyzedGameOriginBundle: state.analyzedGameOriginBundle,
      info: GamePlayedInfo(
        analyzedGameId: state.analyzedGame.id,
        gameInfoString: state.analyzedGame.gameInfo.toString(),
        whitePlayer: state.analyzedGame.whitePlayer,
        blackPlayer: state.analyzedGame.blackPlayer,
        whitePlayerRating: state.analyzedGame.whitePlayerRating,
        blackPlayerRating: state.analyzedGame.blackPlayerRating,
        grandmasterSide: state.analyzedGame.gameAnalysis.grandmasterSide,
      ),
      gameEvaluationData: summaryData,
      playedDateTimestamp: playedDateTimestamp,
    ));
  }

  FindTheGrandmasterMovesState _handleEndTimeBattleGame(final FindTheGrandmasterMovesEndTimeBattleGameEvent event) {
    if (!(state is FindTheGrandmasterMovesPostgameState)) {
      // if current game is not finished playing, save summary data until now
      analyzedGamesSummaryData.add(_buildSummaryDataForCurrentGame());
    }

    final playedTimestamp = DateTime.now().millisecondsSinceEpoch;

    TimeBattleGamesPlayedDao(database: database).insert(TimeBattleGamePlayed(
      analyzedGameOriginBundle: state.analyzedGameOriginBundle,
      initialTimeInSeconds: event.initialTimeInSeconds,
      grandmaster: state.analyzedGame.getGrandmaster(),
      analyzedGamesPlayedIds: analyzedGamesPlayed.map((g) => g.id).toList(),
      analyzedGamesPlayedSummaryData: analyzedGamesSummaryData,
      totalPointsGivenAmount: event.totalPointsGivenAmount,
      totalMovesPlayedAmount: event.totalMovesPlayedAmount,
      correctMovesPlayedAmount: event.correctMovesPlayedAmount,
      gamesPlayedInfo: analyzedGamesPlayed
          .map((g) => GamePlayedInfo(
                analyzedGameId: g.id,
                gameInfoString: g.gameInfo.toString(),
                whitePlayer: g.whitePlayer,
                blackPlayer: g.blackPlayer,
                whitePlayerRating: g.whitePlayerRating,
                blackPlayerRating: g.blackPlayerRating,
                grandmasterSide: g.gameAnalysis.grandmasterSide,
              ))
          .toList(),
      playedDateTimestamp: playedTimestamp,
    ));

    final newState = FindTheGrandmasterMovesTimeBattleGameOver(
      state.analyzedGame,
      gameMode,
      state.analyzedGameOriginBundle,
      analyzedGamesPlayed,
      analyzedGamesSummaryData,
      playedTimestamp,
    );

    screenStateHistory.add(newState);

    return newState;
  }

  FindTheGrandmasterMovesState _handleEndSurvivalGame(final FindTheGrandmasterMovesEndSurvivalGameEvent event) {
    if (!(state is FindTheGrandmasterMovesPostgameState)) {
      // if current game is not finished playing, save summary data until now
      analyzedGamesSummaryData.add(_buildSummaryDataForCurrentGame());
    }

    final playedTimestamp = DateTime.now().millisecondsSinceEpoch;

    SurvivalGamesPlayedDao(database: database).insert(
      SurvivalGamePlayed(
        analyzedGameOriginBundle: state.analyzedGameOriginBundle,
        amountLives: event.amountLives,
        grandmaster: state.analyzedGame.getGrandmaster(),
        analyzedGamesPlayedIds: analyzedGamesPlayed.map((g) => g.id).toList(),
        analyzedGamesPlayedSummaryData: analyzedGamesSummaryData,
        totalPointsGivenAmount: event.totalPointsGivenAmount,
        totalMovesPlayedAmount: event.totalMovesPlayedAmount,
        correctMovesPlayedAmount: event.correctMovesPlayedAmount,
        gamesPlayedInfo: analyzedGamesPlayed
            .map(
              (g) => GamePlayedInfo(
                analyzedGameId: g.id,
                gameInfoString: g.gameInfo.toString(),
                whitePlayer: g.whitePlayer,
                blackPlayer: g.blackPlayer,
                whitePlayerRating: g.whitePlayerRating,
                blackPlayerRating: g.blackPlayerRating,
                grandmasterSide: g.gameAnalysis.grandmasterSide,
              ),
            )
            .toList(),
        playedDateTimestamp: playedTimestamp,
      ),
    );

    final newState = FindTheGrandmasterMovesSurvivalGameOver(
      state.analyzedGame,
      gameMode,
      state.analyzedGameOriginBundle,
      analyzedGamesPlayed,
      analyzedGamesSummaryData,
      playedTimestamp,
    );

    screenStateHistory.add(newState);

    return newState;
  }

  bool _shouldRevealOpponentMoves() {
    switch (gameMode) {
      case GameModeEnum.findTheGrandmasterMoves:
        return userSettings.revealOpponentMovesFindGrandmasterMove;
      case GameModeEnum.timeBattle:
        return userSettings.revealOpponentMovesTimeBattle;
      case GameModeEnum.survivalMode:
        return userSettings.revealOpponentMovesSurvival;
      default:
        throw StateError('Unsupported game mode ${gameMode.toString()}');
    }
  }
}
