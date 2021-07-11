// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_analysis_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LiveAnalysisResponse _$LiveAnalysisResponseFromJson(Map<String, dynamic> json) {
  return LiveAnalysisResponse(
    _$enumDecode(_$GrandmasterSideEnumMap, json['turn']),
    EvaluatedMove.fromJson(json['evaluatedMove'] as Map<String, dynamic>),
    (json['alternativeMoves'] as List<dynamic>)
        .map((e) => EvaluatedMove.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$LiveAnalysisResponseToJson(
        LiveAnalysisResponse instance) =>
    <String, dynamic>{
      'turn': _$GrandmasterSideEnumMap[instance.turn],
      'evaluatedMove': instance.evaluatedMove.toJson(),
      'alternativeMoves':
          instance.alternativeMoves.map((e) => e.toJson()).toList(),
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
