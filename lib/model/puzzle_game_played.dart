import 'package:equatable/equatable.dart';
import 'package:guess_the_move/model/analyzed_game.dart';
import 'package:guess_the_move/model/analyzed_games_bundle.dart';
import 'package:guess_the_move/model/game_played_info.dart';
import 'package:guess_the_move/model/player.dart';
import 'package:json_annotation/json_annotation.dart';

part 'puzzle_game_played.g.dart';

@JsonSerializable()
class PuzzleGamePlayed extends Equatable {
  final Player grandmaster;
  final AnalyzedGamesBundle analyzedGameOriginBundle;
  final List<PuzzlePlayed> puzzlesPlayed;
  final int totalPointsGivenAmount;
  final int playedDateTimestamp;

  PuzzleGamePlayed(
      {required this.grandmaster, required this.analyzedGameOriginBundle, required this.puzzlesPlayed, required this.totalPointsGivenAmount, required this.playedDateTimestamp});

  @override
  List<Object?> get props => [grandmaster, analyzedGameOriginBundle, puzzlesPlayed, totalPointsGivenAmount, playedDateTimestamp];

  factory PuzzleGamePlayed.fromJson(Map<String, dynamic> json) => _$PuzzleGamePlayedFromJson(json);
  Map<String, dynamic> toJson() => _$PuzzleGamePlayedToJson(this);
}

@JsonSerializable()
class PuzzlePlayed extends Equatable {
  final String analyzedGameId;
  final GamePlayedInfo gamePlayedInfo;
  final AnalyzedMove puzzleMove;
  final DateTime startTime;
  final int? timeNeededInMilliseconds;
  final int? pointsGiven;
  final int wrongTries;
  final bool wasAlreadySolved;
  final bool showPieceTypeTipUsed;
  final bool showActualPieceTipUsed;
  final bool showActualMoveTipUsed;

  PuzzlePlayed(
      {required this.analyzedGameId,
      required this.gamePlayedInfo,
      required this.puzzleMove,
      required this.startTime,
      this.timeNeededInMilliseconds,
      this.pointsGiven,
      required this.wrongTries,
      required this.wasAlreadySolved,
      required this.showPieceTypeTipUsed,
      required this.showActualPieceTipUsed,
      required this.showActualMoveTipUsed});

  bool wasCorrectMovePlayed() {
    return timeNeededInMilliseconds != null;
  }

  @override
  List<Object?> get props =>
      [analyzedGameId, gamePlayedInfo, puzzleMove, startTime, wrongTries, wasAlreadySolved, showPieceTypeTipUsed, showActualPieceTipUsed, showActualMoveTipUsed];

  factory PuzzlePlayed.fromJson(Map<String, dynamic> json) => _$PuzzlePlayedFromJson(json);
  Map<String, dynamic> toJson() => _$PuzzlePlayedToJson(this);
}

int getPuzzleGamePointsScore(final List<PuzzlePlayed> puzzlesPlayed) {
  final pointsGivenList = puzzlesPlayed.where((puzzlePlayed) => puzzlePlayed.wasCorrectMovePlayed()).map((puzzlePlayed) => puzzlePlayed.pointsGiven!).toList();
  return (pointsGivenList + [0]).reduce((value, element) => value + element);
}

int getPuzzleGameMovesGuessedCorrect(final List<PuzzlePlayed> puzzlesPlayed) {
  return puzzlesPlayed.where((puzzlePlayed) => puzzlePlayed.wasCorrectMovePlayed()).length;
}

int getPuzzleGameTotalMovesGuessed(final List<PuzzlePlayed> puzzlesPlayed) {
  return puzzlesPlayed.map((puzzlePlayed) => puzzlePlayed.wrongTries).reduce((value, element) => value + element) + getPuzzleGameMovesGuessedCorrect(puzzlesPlayed);
}
