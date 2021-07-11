// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'puzzle_game_played.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PuzzleGamePlayed _$PuzzleGamePlayedFromJson(Map<String, dynamic> json) {
  return PuzzleGamePlayed(
    grandmaster: Player.fromJson(json['grandmaster'] as Map<String, dynamic>),
    analyzedGameOriginBundle: AnalyzedGamesBundle.fromJson(
        json['analyzedGameOriginBundle'] as Map<String, dynamic>),
    puzzlesPlayed: (json['puzzlesPlayed'] as List<dynamic>)
        .map((e) => PuzzlePlayed.fromJson(e as Map<String, dynamic>))
        .toList(),
    totalPointsGivenAmount: json['totalPointsGivenAmount'] as int,
    playedDateTimestamp: json['playedDateTimestamp'] as int,
  );
}

Map<String, dynamic> _$PuzzleGamePlayedToJson(PuzzleGamePlayed instance) =>
    <String, dynamic>{
      'grandmaster': instance.grandmaster.toJson(),
      'analyzedGameOriginBundle': instance.analyzedGameOriginBundle.toJson(),
      'puzzlesPlayed': instance.puzzlesPlayed.map((e) => e.toJson()).toList(),
      'totalPointsGivenAmount': instance.totalPointsGivenAmount,
      'playedDateTimestamp': instance.playedDateTimestamp,
    };

PuzzlePlayed _$PuzzlePlayedFromJson(Map<String, dynamic> json) {
  return PuzzlePlayed(
    analyzedGameId: json['analyzedGameId'] as String,
    gamePlayedInfo:
        GamePlayedInfo.fromJson(json['gamePlayedInfo'] as Map<String, dynamic>),
    puzzleMove:
        AnalyzedMove.fromJson(json['puzzleMove'] as Map<String, dynamic>),
    startTime: DateTime.parse(json['startTime'] as String),
    timeNeededInMilliseconds: json['timeNeededInMilliseconds'] as int?,
    pointsGiven: json['pointsGiven'] as int?,
    wrongTries: json['wrongTries'] as int,
    wasAlreadySolved: json['wasAlreadySolved'] as bool,
    showPieceTypeTipUsed: json['showPieceTypeTipUsed'] as bool,
    showActualPieceTipUsed: json['showActualPieceTipUsed'] as bool,
    showActualMoveTipUsed: json['showActualMoveTipUsed'] as bool,
  );
}

Map<String, dynamic> _$PuzzlePlayedToJson(PuzzlePlayed instance) =>
    <String, dynamic>{
      'analyzedGameId': instance.analyzedGameId,
      'gamePlayedInfo': instance.gamePlayedInfo.toJson(),
      'puzzleMove': instance.puzzleMove.toJson(),
      'startTime': instance.startTime.toIso8601String(),
      'timeNeededInMilliseconds': instance.timeNeededInMilliseconds,
      'pointsGiven': instance.pointsGiven,
      'wrongTries': instance.wrongTries,
      'wasAlreadySolved': instance.wasAlreadySolved,
      'showPieceTypeTipUsed': instance.showPieceTypeTipUsed,
      'showActualPieceTipUsed': instance.showActualPieceTipUsed,
      'showActualMoveTipUsed': instance.showActualMoveTipUsed,
    };
