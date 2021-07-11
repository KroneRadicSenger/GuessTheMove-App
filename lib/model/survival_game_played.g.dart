// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'survival_game_played.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SurvivalGamePlayed _$SurvivalGamePlayedFromJson(Map<String, dynamic> json) {
  return SurvivalGamePlayed(
    grandmaster: Player.fromJson(json['grandmaster'] as Map<String, dynamic>),
    amountLives: json['amountLives'] as int,
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

Map<String, dynamic> _$SurvivalGamePlayedToJson(SurvivalGamePlayed instance) =>
    <String, dynamic>{
      'grandmaster': instance.grandmaster.toJson(),
      'analyzedGameOriginBundle': instance.analyzedGameOriginBundle.toJson(),
      'amountLives': instance.amountLives,
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
