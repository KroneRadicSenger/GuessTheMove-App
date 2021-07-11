// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'find_the_grandmaster_moves_game_played.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FindTheGrandmasterMovesGamePlayed _$FindTheGrandmasterMovesGamePlayedFromJson(
    Map<String, dynamic> json) {
  return FindTheGrandmasterMovesGamePlayed(
    analyzedGameId: json['analyzedGameId'] as String,
    analyzedGameOriginBundle: AnalyzedGamesBundle.fromJson(
        json['analyzedGameOriginBundle'] as Map<String, dynamic>),
    info: GamePlayedInfo.fromJson(json['info'] as Map<String, dynamic>),
    gameEvaluationData: SummaryData.fromJson(
        json['gameEvaluationData'] as Map<String, dynamic>),
    playedDateTimestamp: json['playedDateTimestamp'] as int,
  );
}

Map<String, dynamic> _$FindTheGrandmasterMovesGamePlayedToJson(
        FindTheGrandmasterMovesGamePlayed instance) =>
    <String, dynamic>{
      'analyzedGameId': instance.analyzedGameId,
      'analyzedGameOriginBundle': instance.analyzedGameOriginBundle.toJson(),
      'info': instance.info.toJson(),
      'gameEvaluationData': instance.gameEvaluationData.toJson(),
      'playedDateTimestamp': instance.playedDateTimestamp,
    };
