// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_played_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GamePlayedInfo _$GamePlayedInfoFromJson(Map<String, dynamic> json) {
  return GamePlayedInfo(
    analyzedGameId: json['analyzedGameId'] as String,
    whitePlayer: Player.fromJson(json['whitePlayer'] as Map<String, dynamic>),
    blackPlayer: Player.fromJson(json['blackPlayer'] as Map<String, dynamic>),
    whitePlayerRating: json['whitePlayerRating'] as String,
    blackPlayerRating: json['blackPlayerRating'] as String,
    grandmasterSide:
        _$enumDecode(_$GrandmasterSideEnumMap, json['grandmasterSide']),
    gameInfoString: json['gameInfoString'] as String,
  );
}

Map<String, dynamic> _$GamePlayedInfoToJson(GamePlayedInfo instance) =>
    <String, dynamic>{
      'analyzedGameId': instance.analyzedGameId,
      'whitePlayer': instance.whitePlayer.toJson(),
      'blackPlayer': instance.blackPlayer.toJson(),
      'whitePlayerRating': instance.whitePlayerRating,
      'blackPlayerRating': instance.blackPlayerRating,
      'grandmasterSide': _$GrandmasterSideEnumMap[instance.grandmasterSide],
      'gameInfoString': instance.gameInfoString,
    };

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

const _$GrandmasterSideEnumMap = {
  GrandmasterSide.white: 'white',
  GrandmasterSide.black: 'black',
};
