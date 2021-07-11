// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'players_and_bundles_meta.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlayersAndBundlesMeta _$PlayersAndBundlesMetaFromJson(
    Map<String, dynamic> json) {
  return PlayersAndBundlesMeta(
    (json['grandmasters'] as List<dynamic>)
        .map((e) => Player.fromJson(e as Map<String, dynamic>))
        .toSet(),
    (json['analyzedGamesBundles'] as List<dynamic>)
        .map((e) => AnalyzedGamesBundle.fromJson(e as Map<String, dynamic>))
        .toSet(),
    Map<String, int>.from(json['gamesAmountByAnalyzedGamesBundleId'] as Map),
  );
}

Map<String, dynamic> _$PlayersAndBundlesMetaToJson(
        PlayersAndBundlesMeta instance) =>
    <String, dynamic>{
      'grandmasters': instance.grandmasters.map((e) => e.toJson()).toList(),
      'analyzedGamesBundles':
          instance.analyzedGamesBundles.map((e) => e.toJson()).toList(),
      'gamesAmountByAnalyzedGamesBundleId':
          instance.gamesAmountByAnalyzedGamesBundleId,
    };
