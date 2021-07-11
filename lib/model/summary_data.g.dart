// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'summary_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SummaryDataGuessEvaluated _$SummaryDataGuessEvaluatedFromJson(
    Map<String, dynamic> json) {
  return SummaryDataGuessEvaluated(
    AnalyzedMove.fromJson(json['move'] as Map<String, dynamic>),
    (json['shuffledAnswerMoves'] as List<dynamic>)
        .map((e) => EvaluatedMove.fromJson(e as Map<String, dynamic>))
        .toList(),
    EvaluatedMove.fromJson(json['chosenMove'] as Map<String, dynamic>),
    json['grandmasterMovePlayed'] as bool,
    _$enumDecode(_$AnalyzedMoveTypeEnumMap, json['chosenMoveType']),
    json['pointsGiven'] as int,
  );
}

Map<String, dynamic> _$SummaryDataGuessEvaluatedToJson(
        SummaryDataGuessEvaluated instance) =>
    <String, dynamic>{
      'move': instance.move.toJson(),
      'shuffledAnswerMoves':
          instance.shuffledAnswerMoves.map((e) => e.toJson()).toList(),
      'chosenMove': instance.chosenMove.toJson(),
      'grandmasterMovePlayed': instance.grandmasterMovePlayed,
      'chosenMoveType': _$AnalyzedMoveTypeEnumMap[instance.chosenMoveType],
      'pointsGiven': instance.pointsGiven,
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

const _$AnalyzedMoveTypeEnumMap = {
  AnalyzedMoveType.book: 'book',
  AnalyzedMoveType.blunder: 'blunder',
  AnalyzedMoveType.mistake: 'mistake',
  AnalyzedMoveType.inaccuracy: 'inaccuracy',
  AnalyzedMoveType.okay: 'okay',
  AnalyzedMoveType.good: 'good',
  AnalyzedMoveType.excellent: 'excellent',
  AnalyzedMoveType.best: 'best',
  AnalyzedMoveType.brilliant: 'brilliant',
  AnalyzedMoveType.critical: 'critical',
  AnalyzedMoveType.gameChanger: 'gameChanger',
};

SummaryData _$SummaryDataFromJson(Map<String, dynamic> json) {
  return SummaryData(
    (json['guessEvaluatedList'] as List<dynamic>)
        .map((e) =>
            SummaryDataGuessEvaluated.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$SummaryDataToJson(SummaryData instance) =>
    <String, dynamic>{
      'guessEvaluatedList':
          instance.guessEvaluatedList.map((e) => e.toJson()).toList(),
    };
