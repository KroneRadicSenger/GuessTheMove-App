part of 'puzzle_bloc.dart';

enum PuzzleStateTypeEnum {
  ingame,
  postgame,
}

@immutable
abstract class PuzzleState extends Equatable {
  final PuzzleStateTypeEnum stateTypeEnum;

  PuzzleState(this.stateTypeEnum);
}

abstract class PuzzleIngameState extends PuzzleState {
  final AnalyzedGame analyzedGame;
  final AnalyzedGamesBundle analyzedGameOriginBundle;
  final AnalyzedMove puzzleMove;
  final DateTime startTime;
  final int wrongTries;
  final bool wasAlreadySolved;
  final bool showPieceTypeTipUsed;
  final bool showActualPieceTipUsed;
  final bool showActualMoveTipUsed;

  PuzzleIngameState(this.analyzedGame, this.analyzedGameOriginBundle, this.puzzleMove, this.startTime, this.wrongTries, this.wasAlreadySolved, this.showPieceTypeTipUsed,
      this.showActualPieceTipUsed, this.showActualMoveTipUsed)
      : super(PuzzleStateTypeEnum.ingame);
}

abstract class PuzzlePostgameState extends PuzzleState {
  PuzzlePostgameState() : super(PuzzleStateTypeEnum.postgame);
}

class PuzzleGuessMove extends PuzzleIngameState {
  final bool isNewPuzzle;

  PuzzleGuessMove(final AnalyzedGame analyzedGame, final AnalyzedGamesBundle analyzedGameOriginBundle, final AnalyzedMove puzzleMove, final DateTime startTime,
      final int wrongTries, final bool wasAlreadySolved, final bool showPieceTypeTipUsed, final bool showActualPieceTipUsed, final bool showActualMoveTipUsed, this.isNewPuzzle)
      : super(analyzedGame, analyzedGameOriginBundle, puzzleMove, startTime, wrongTries, wasAlreadySolved, showPieceTypeTipUsed, showActualPieceTipUsed, showActualMoveTipUsed);

  @override
  List<Object?> get props => [
        analyzedGame,
        analyzedGameOriginBundle,
        puzzleMove,
        startTime,
        wrongTries,
        wasAlreadySolved,
        isNewPuzzle,
        showPieceTypeTipUsed,
        showActualPieceTipUsed,
        showActualMoveTipUsed
      ];

  PuzzleGuessMove copyWith({
    bool? showPieceTypeTipUsed,
    bool? showActualPieceTipUsed,
    bool? showActualMoveTipUsed,
  }) {
    return PuzzleGuessMove(analyzedGame, analyzedGameOriginBundle, puzzleMove, startTime, wrongTries, wasAlreadySolved, showPieceTypeTipUsed ?? this.showPieceTypeTipUsed,
        showActualPieceTipUsed ?? this.showActualPieceTipUsed, showActualMoveTipUsed ?? this.showActualMoveTipUsed, isNewPuzzle);
  }
}

class PuzzleWrongMove extends PuzzleIngameState {
  final String playedMove;

  PuzzleWrongMove(final AnalyzedGame analyzedGame, final AnalyzedGamesBundle analyzedGameOriginBundle, final AnalyzedMove puzzleMove, final DateTime startTime, this.playedMove,
      final int wrongTries, final bool wasAlreadySolved, final bool showPieceTypeTipUsed, final bool showActualPieceTipUsed, final bool showActualMoveTipUsed)
      : super(analyzedGame, analyzedGameOriginBundle, puzzleMove, startTime, wrongTries, wasAlreadySolved, showPieceTypeTipUsed, showActualPieceTipUsed, showActualMoveTipUsed);

  @override
  List<Object?> get props =>
      [analyzedGame, analyzedGameOriginBundle, puzzleMove, startTime, wrongTries, wasAlreadySolved, showPieceTypeTipUsed, showActualPieceTipUsed, playedMove];
}

class PuzzleCorrectMove extends PuzzleIngameState {
  final String playedMove;
  final int pointsGiven;
  final int timeNeededInMilliseconds;

  PuzzleCorrectMove(
    final AnalyzedGame analyzedGame,
    final AnalyzedGamesBundle analyzedGameOriginBundle,
    final AnalyzedMove puzzleMove,
    final DateTime startTime,
    final int wrongTries,
    final bool wasAlreadySolved,
    final bool showPieceTypeTipUsed,
    final bool showActualPieceTipUsed,
    final bool showActualMoveTipUsed,
    this.playedMove,
    this.pointsGiven,
    this.timeNeededInMilliseconds,
  ) : super(analyzedGame, analyzedGameOriginBundle, puzzleMove, startTime, wrongTries, wasAlreadySolved, showPieceTypeTipUsed, showActualPieceTipUsed, showActualMoveTipUsed);

  @override
  List<Object?> get props => [
        analyzedGame,
        analyzedGameOriginBundle,
        puzzleMove,
        startTime,
        wrongTries,
        wasAlreadySolved,
        showPieceTypeTipUsed,
        showActualPieceTipUsed,
        playedMove,
        pointsGiven,
        timeNeededInMilliseconds
      ];
}

class PuzzleGameOver extends PuzzlePostgameState {
  final AnalyzedGamesBundle analyzedGamesOriginBundle;
  final List<AnalyzedGame> analyzedGamesInBundle;
  final List<PuzzlePlayed> puzzlesPlayed;
  final int playedDateTimestamp;

  PuzzleGameOver(this.analyzedGamesOriginBundle, this.analyzedGamesInBundle, this.puzzlesPlayed, this.playedDateTimestamp);

  @override
  List<Object?> get props => [analyzedGamesOriginBundle, analyzedGamesInBundle, puzzlesPlayed, playedDateTimestamp];
}
