// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analyzed_games_bundle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnalyzedGamesBundleByGrandmasterAndYear
    _$AnalyzedGamesBundleByGrandmasterAndYearFromJson(
        Map<String, dynamic> json) {
  return AnalyzedGamesBundleByGrandmasterAndYear(
    type: _$enumDecode(_$AnalyzedGamesBundleTypeEnumMap, json['type']),
    grandmaster: Player.fromJson(json['grandmaster'] as Map<String, dynamic>),
    year: json['year'] as int,
  );
}

Map<String, dynamic> _$AnalyzedGamesBundleByGrandmasterAndYearToJson(
        AnalyzedGamesBundleByGrandmasterAndYear instance) =>
    <String, dynamic>{
      'type': _$AnalyzedGamesBundleTypeEnumMap[instance.type],
      'grandmaster': instance.grandmaster.toJson(),
      'year': instance.year,
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

const _$AnalyzedGamesBundleTypeEnumMap = {
  AnalyzedGamesBundleType.byGrandmasterAndYear: 'byGrandmasterAndYear',
};
