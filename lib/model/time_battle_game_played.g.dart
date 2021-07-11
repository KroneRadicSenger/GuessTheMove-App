// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_battle_game_played.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimeBattleGamePlayed _$TimeBattleGamePlayedFromJson(Map<String, dynamic> json) {
  return TimeBattleGamePlayed(
    grandmaster: Player.fromJson(json['grandmaster'] as Map<String, dynamic>),
    initialTimeInSeconds: json['initialTimeInSeconds'] as int,
    analyzedGameOriginBundle: AnalyzedGamesBundle.fromJson(
        json['analyzedGameOriginBundle'] as Map<String, dynamic>),
    analyzedGamesPlayedIds: (json['analyzedGamesPlayedIds'] as List<dynamic>)
        .map((e) => e as String)
        .toList(),
    gamesPlayedInfo: (json['gamesPlayedInfo'] as List<dynamic>)
        .map((e) => GamePlayedInfo.fromJson(e as Map<String, dynamic>))
        .toList(),
    analyzedGamesPlayedSummaryData:
        (json['analyzedGamesPlayedSummaryData'] as List<dynamic>)
            .map((e) => SummaryData.fromJson(e as Map<String, dynamic>))
            .toList(),
    totalPointsGivenAmount: json['totalPointsGivenAmount'] as int,
    totalMovesPlayedAmount: json['totalMovesPlayedAmount'] as int,
    correctMovesPlayedAmount: json['correctMovesPlayedAmount'] as int,
    playedDateTimestamp: json['playedDateTimestamp'] as int,
  );
}

Map<String, dynamic> _$TimeBattleGamePlayedToJson(
        TimeBattleGamePlayed instance) =>
    <String, dynamic>{
      'grandmaster': instance.grandmaster.toJson(),
      'analyzedGameOriginBundle': instance.analyzedGameOriginBundle.toJson(),
      'initialTimeInSeconds': instance.initialTimeInSeconds,
      'totalPointsGivenAmount': instance.totalPointsGivenAmount,
      'totalMovesPlayedAmount': instance.totalMovesPlayedAmount,
      'correctMovesPlayedAmount': instance.correctMovesPlayedAmount,
      'analyzedGamesPlayedIds': instance.analyzedGamesPlayedIds,
      'gamesPlayedInfo':
          instance.gamesPlayedInfo.map((e) => e.toJson()).toList(),
      'analyzedGamesPlayedSummaryData': instance.analyzedGamesPlayedSummaryData
          .map((e) => e.toJson())
          .toList(),
      'playedDateTimestamp': instance.playedDateTimestamp,
    };
