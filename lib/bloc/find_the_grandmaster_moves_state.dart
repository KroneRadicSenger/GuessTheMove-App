part of 'find_the_grandmaster_moves_bloc.dart';

enum FindTheGrandmasterMovesStateTypeEnum {
  // pregame,
  ingame,
  postgame,
  game_over,
}

abstract class FindTheGrandmasterMovesState {
  final AnalyzedGame analyzedGame;
  final GameModeEnum gameMode;
  final AnalyzedGamesBundle analyzedGameOriginBundle;
  final FindTheGrandmasterMovesStateTypeEnum stateTypeEnum;

  const FindTheGrandmasterMovesState(
    this.analyzedGame,
    this.gameMode,
    this.analyzedGameOriginBundle,
    this.stateTypeEnum,
  );

  FindTheGrandmasterMovesState copyWith();
}

/*abstract class FindTheGrandmasterMovesPregameState extends FindTheGrandmasterMovesState {
  FindTheGrandmasterMovesPregameState(AnalyzedGame analyzedGame)
      : super(analyzedGame, FindTheGrandmasterMovesStateTypeEnum.pregame);
}*/

abstract class FindTheGrandmasterMovesIngameState extends FindTheGrandmasterMovesState {
  final AnalyzedMove move;

  FindTheGrandmasterMovesIngameState(final AnalyzedGame analyzedGame, final GameModeEnum gameMode, final AnalyzedGamesBundle analyzedGameOriginBundle, this.move)
      : super(analyzedGame, gameMode, analyzedGameOriginBundle, FindTheGrandmasterMovesStateTypeEnum.ingame);

  int getFullMoveNumber() {
    var ply = this.move.ply;
    return (ply ~/ 2) + 1;
  }

  ChessColor getTurn() {
    var ply = this.move.ply;
    return ply % 2 == 0 ? ChessColor.white : ChessColor.black;
  }

  bool isFirstMoveAfterOpening() => move.ply == analyzedGame.gameAnalysis.opening.moves.split(' ').length;

  bool isLastMove() => move.ply == (analyzedGame.gameAnalysis.analyzedMoves.length - 1);
}

abstract class FindTheGrandmasterMovesPostgameState extends FindTheGrandmasterMovesState {
  FindTheGrandmasterMovesPostgameState(final AnalyzedGame analyzedGame, final GameModeEnum gameMode, final AnalyzedGamesBundle analyzedGameOriginBundle)
      : super(analyzedGame, gameMode, analyzedGameOriginBundle, FindTheGrandmasterMovesStateTypeEnum.postgame);
}

abstract class FindTheGrandmasterMovesGameOverState extends FindTheGrandmasterMovesState {
  FindTheGrandmasterMovesGameOverState(final AnalyzedGame analyzedGame, final GameModeEnum gameMode, final AnalyzedGamesBundle analyzedGameOriginBundle)
      : super(analyzedGame, gameMode, analyzedGameOriginBundle, FindTheGrandmasterMovesStateTypeEnum.game_over);
}

/*class FindTheGrandmasterMovesInitial extends FindTheGrandmasterMovesPregameState {
  FindTheGrandmasterMovesInitial(AnalyzedGame analyzedGame) : super(analyzedGame);

  @override
  List<Object> get props => [analyzedGame, stateTypeEnum];
}*/

class FindTheGrandmasterMovesShowingOpening extends FindTheGrandmasterMovesIngameState {
  FindTheGrandmasterMovesShowingOpening(final AnalyzedGame analyzedGame, final GameModeEnum gameMode, final AnalyzedGamesBundle analyzedGameOriginBundle, final AnalyzedMove move)
      : super(analyzedGame, gameMode, analyzedGameOriginBundle, move);

  bool isLastOpeningMove() => move.ply == (analyzedGame.gameAnalysis.opening.getMovesList().length - 1);

  @override
  FindTheGrandmasterMovesState copyWith() {
    return FindTheGrandmasterMovesShowingOpening(analyzedGame, gameMode, analyzedGameOriginBundle, analyzedGame.gameAnalysis.analyzedMoves[move.ply]);
  }
}

class FindTheGrandmasterMovesOpponentPlayingMove extends FindTheGrandmasterMovesIngameState {
  bool moveRevealed;

  FindTheGrandmasterMovesOpponentPlayingMove(
      final AnalyzedGame analyzedGame, final GameModeEnum gameMode, final AnalyzedGamesBundle analyzedGameOriginBundle, final AnalyzedMove move, this.moveRevealed)
      : super(analyzedGame, gameMode, analyzedGameOriginBundle, move);

  @override
  FindTheGrandmasterMovesState copyWith() {
    return FindTheGrandmasterMovesOpponentPlayingMove(analyzedGame, gameMode, analyzedGameOriginBundle, analyzedGame.gameAnalysis.analyzedMoves[move.ply], moveRevealed);
  }
}

class FindTheGrandmasterMovesGuessingMove extends FindTheGrandmasterMovesIngameState {
  final List<EvaluatedMove> shuffledAnswerMoves;

  bool showPieceTypeTipUsed;
  bool showActualPieceTipUsed;
  bool removeWorstAnswerTipUsed;

  FindTheGrandmasterMovesGuessingMove(final AnalyzedGame analyzedGame, final GameModeEnum gameMode, final AnalyzedGamesBundle analyzedGameOriginBundle, final AnalyzedMove move,
      this.shuffledAnswerMoves, this.showPieceTypeTipUsed, this.showActualPieceTipUsed, this.removeWorstAnswerTipUsed)
      : super(analyzedGame, gameMode, analyzedGameOriginBundle, move);

  @override
  FindTheGrandmasterMovesState copyWith({
    bool? showPieceTypeTipUsed,
    bool? showActualPieceTipUsed,
    bool? removeWorstAnswerTipUsed,
  }) {
    return FindTheGrandmasterMovesGuessingMove(analyzedGame, gameMode, analyzedGameOriginBundle, analyzedGame.gameAnalysis.analyzedMoves[move.ply], shuffledAnswerMoves,
        showPieceTypeTipUsed ?? this.showPieceTypeTipUsed, showActualPieceTipUsed ?? this.showActualPieceTipUsed, removeWorstAnswerTipUsed ?? this.removeWorstAnswerTipUsed);
  }
}

class FindTheGrandmasterMovesGuessingPreviewGuessMove extends FindTheGrandmasterMovesGuessingMove {
  final EvaluatedMove moveSelected;

  FindTheGrandmasterMovesGuessingPreviewGuessMove(
      final AnalyzedGame analyzedGame,
      final GameModeEnum gameMode,
      final AnalyzedGamesBundle analyzedGameOriginBundle,
      final AnalyzedMove move,
      final List<EvaluatedMove> shuffledAnswerMoves,
      final bool showPieceTypeTipUsed,
      final bool showActualPieceTipUsed,
      final bool removeWorstAnswerTipUsed,
      this.moveSelected)
      : super(analyzedGame, gameMode, analyzedGameOriginBundle, move, shuffledAnswerMoves, showPieceTypeTipUsed, showActualPieceTipUsed, removeWorstAnswerTipUsed);

  @override
  FindTheGrandmasterMovesState copyWith({
    bool? showPieceTypeTipUsed,
    bool? showActualPieceTipUsed,
    bool? removeWorstAnswerTipUsed,
  }) {
    return FindTheGrandmasterMovesGuessingPreviewGuessMove(
        analyzedGame,
        gameMode,
        analyzedGameOriginBundle,
        analyzedGame.gameAnalysis.analyzedMoves[move.ply],
        shuffledAnswerMoves,
        showPieceTypeTipUsed ?? this.showPieceTypeTipUsed,
        showActualPieceTipUsed ?? this.showActualPieceTipUsed,
        removeWorstAnswerTipUsed ?? this.removeWorstAnswerTipUsed,
        moveSelected);
  }
}

const bestMovePlayedPointsGiven = 20;
const mediocreMovePlayedPointsGiven = 10;
const badMovePlayedPointsGiven = 0;

class FindTheGrandmasterMovesGuessEvaluated extends FindTheGrandmasterMovesIngameState {
  final List<EvaluatedMove> shuffledAnswerMoves;
  final EvaluatedMove chosenMove;
  final bool grandmasterMovePlayed;
  final AnalyzedMoveType chosenMoveType;
  final int pointsGiven;

  FindTheGrandmasterMovesGuessEvaluated(final AnalyzedGame analyzedGame, final GameModeEnum gameMode, final AnalyzedGamesBundle analyzedGameOriginBundle, final AnalyzedMove move,
      this.shuffledAnswerMoves, this.chosenMove, this.grandmasterMovePlayed, this.chosenMoveType, this.pointsGiven)
      : super(analyzedGame, gameMode, analyzedGameOriginBundle, move);

  @override
  FindTheGrandmasterMovesState copyWith() {
    return FindTheGrandmasterMovesGuessEvaluated(analyzedGame, gameMode, analyzedGameOriginBundle, analyzedGame.gameAnalysis.analyzedMoves[move.ply], shuffledAnswerMoves,
        chosenMove, grandmasterMovePlayed, chosenMoveType, pointsGiven);
  }
}

enum MovesSummaryFieldEnum { pointsGivenTotalAmount, grandmasterMovesPlayedAmount, bestMovesPlayedAmount, blundersPlayedAmount, mistakesPlayedAmount, inaccuraciesPlayedAmount }

class FindTheGrandmasterMovesShowingSummary extends FindTheGrandmasterMovesPostgameState {
  final SummaryData data;
  final int playedTimestamp;

  FindTheGrandmasterMovesShowingSummary(
    final AnalyzedGame analyzedGame,
    final GameModeEnum gameMode,
    final AnalyzedGamesBundle analyzedGameOriginBundle,
    this.data,
    this.playedTimestamp,
  ) : super(analyzedGame, gameMode, analyzedGameOriginBundle);

  @override
  FindTheGrandmasterMovesState copyWith() {
    return FindTheGrandmasterMovesShowingSummary(analyzedGame, gameMode, analyzedGameOriginBundle, data, playedTimestamp);
  }
}

class FindTheGrandmasterMovesTimeBattleGameOver extends FindTheGrandmasterMovesGameOverState {
  final List<AnalyzedGame> gamesPlayed;
  final List<SummaryData> gamesSummaryData;
  final int playedTimestamp;

  FindTheGrandmasterMovesTimeBattleGameOver(
    final AnalyzedGame analyzedGame,
    final GameModeEnum gameMode,
    final AnalyzedGamesBundle analyzedGameOriginBundle,
    this.gamesPlayed,
    this.gamesSummaryData,
    this.playedTimestamp,
  ) : super(analyzedGame, gameMode, analyzedGameOriginBundle);

  @override
  FindTheGrandmasterMovesState copyWith() {
    return FindTheGrandmasterMovesTimeBattleGameOver(analyzedGame, gameMode, analyzedGameOriginBundle, gamesPlayed, gamesSummaryData, playedTimestamp);
  }
}

class FindTheGrandmasterMovesSurvivalGameOver extends FindTheGrandmasterMovesGameOverState {
  final List<AnalyzedGame> gamesPlayed;
  final List<SummaryData> gamesSummaryData;
  final int playedTimestamp;

  FindTheGrandmasterMovesSurvivalGameOver(
    final AnalyzedGame analyzedGame,
    final GameModeEnum gameMode,
    final AnalyzedGamesBundle analyzedGameOriginBundle,
    this.gamesPlayed,
    this.gamesSummaryData,
    this.playedTimestamp,
  ) : super(analyzedGame, gameMode, analyzedGameOriginBundle);

  @override
  FindTheGrandmasterMovesState copyWith() {
    return FindTheGrandmasterMovesSurvivalGameOver(analyzedGame, gameMode, analyzedGameOriginBundle, gamesPlayed, gamesSummaryData, playedTimestamp);
  }
}
