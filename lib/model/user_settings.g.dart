// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserSettings _$UserSettingsFromJson(Map<String, dynamic> json) {
  return UserSettings(
    _$enumDecode(_$ThemeModeEnumMap, json['themeMode']),
    _$enumDecode(_$MoveNotationEnumEnumMap, json['moveNotation']),
    _$enumDecode(_$MoveEvaluationNotationEnumEnumMap, json['moveEvaluationNotation']),
    json['revealOpponentMovesFindGrandmasterMove'] as bool,
    json['revealOpponentMovesTimeBattle'] as bool,
    json['revealOpponentMovesSurvival'] as bool,
    _$enumDecode(_$BoardRotationEnumEnumMap, json['boardRotation']),
  );
}

Map<String, dynamic> _$UserSettingsToJson(UserSettings instance) => <String, dynamic>{
      'themeMode': _$ThemeModeEnumMap[instance.themeMode],
      'moveNotation': _$MoveNotationEnumEnumMap[instance.moveNotation],
      'moveEvaluationNotation': _$MoveEvaluationNotationEnumEnumMap[instance.moveEvaluationNotation],
      'revealOpponentMovesFindGrandmasterMove': instance.revealOpponentMovesFindGrandmasterMove,
      'revealOpponentMovesTimeBattle': instance.revealOpponentMovesTimeBattle,
      'revealOpponentMovesSurvival': instance.revealOpponentMovesSurvival,
      'boardRotation': _$BoardRotationEnumEnumMap[instance.boardRotation],
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

const _$ThemeModeEnumMap = {
  ThemeMode.light: 'light',
  ThemeMode.dark: 'dark',
};

const _$MoveNotationEnumEnumMap = {
  MoveNotationEnum.san: 'san',
  MoveNotationEnum.fan: 'fan',
  MoveNotationEnum.uci: 'uci',
};

const _$MoveEvaluationNotationEnumEnumMap = {
  MoveEvaluationNotationEnum.pawnScore: 'pawnScore',
  MoveEvaluationNotationEnum.grandmasterExpectation: 'grandmasterExpectation',
};

const _$BoardRotationEnumEnumMap = {
  BoardRotationEnum.white: 'white',
  BoardRotationEnum.grandmaster: 'grandmaster',
};
