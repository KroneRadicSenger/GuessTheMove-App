// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analyzed_game.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Opening _$OpeningFromJson(Map<String, dynamic> json) {
  return Opening(
    json['eco'] as String,
    json['name'] as String,
    json['fen'] as String,
    json['moves'] as String,
  );
}

Map<String, dynamic> _$OpeningToJson(Opening instance) => <String, dynamic>{
      'eco': instance.eco,
      'name': instance.name,
      'fen': instance.fen,
      'moves': instance.moves,
    };

Move _$MoveFromJson(Map<String, dynamic> json) {
  return Move(
    json['uci'] as String,
    json['san'] as String,
  );
}

Map<String, dynamic> _$MoveToJson(Move instance) => <String, dynamic>{
      'uci': instance.uci,
      'san': instance.san,
    };

EvaluatedMove _$EvaluatedMoveFromJson(Map<String, dynamic> json) {
  return EvaluatedMove(
    Move.fromJson(json['move'] as Map<String, dynamic>),
    _$enumDecode(_$AnalyzedMoveTypeEnumMap, json['moveType']),
    json['signedCPScore'] as String,
    (json['gmExpectation'] as num).toDouble(),
    json['pv'] as String,
  );
}

Map<String, dynamic> _$EvaluatedMoveToJson(EvaluatedMove instance) =>
    <String, dynamic>{
      'move': instance.move.toJson(),
      'moveType': _$AnalyzedMoveTypeEnumMap[instance.moveType],
      'signedCPScore': instance.signedCPScore,
      'gmExpectation': instance.gmExpectation,
      'pv': instance.pv,
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

AnalyzedMove _$AnalyzedMoveFromJson(Map<String, dynamic> json) {
  return AnalyzedMove(
    json['ply'] as int,
    _$enumDecode(_$GamePhaseEnumMap, json['gamePhase']),
    _$enumDecode(_$GrandmasterSideEnumMap, json['turn']),
    EvaluatedMove.fromJson(json['actualMove'] as Map<String, dynamic>),
    (json['alternativeMoves'] as List<dynamic>)
        .map((e) => EvaluatedMove.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$AnalyzedMoveToJson(AnalyzedMove instance) =>
    <String, dynamic>{
      'ply': instance.ply,
      'gamePhase': _$GamePhaseEnumMap[instance.gamePhase],
      'turn': _$GrandmasterSideEnumMap[instance.turn],
      'actualMove': instance.actualMove.toJson(),
      'alternativeMoves':
          instance.alternativeMoves.map((e) => e.toJson()).toList(),
    };

const _$GamePhaseEnumMap = {
  GamePhase.opening: 'opening',
  GamePhase.midgame: 'midgame',
  GamePhase.endgame: 'endgame',
};

const _$GrandmasterSideEnumMap = {
  GrandmasterSide.white: 'white',
  GrandmasterSide.black: 'black',
};

GameAnalysis _$GameAnalysisFromJson(Map<String, dynamic> json) {
  return GameAnalysis(
    _$enumDecode(_$GrandmasterSideEnumMap, json['grandmasterSide']),
    json['grandmasterDepthToMateInHalfMoves'] as int?,
    Opening.fromJson(json['opening'] as Map<String, dynamic>),
    (json['analyzedMoves'] as List<dynamic>)
        .map((e) => AnalyzedMove.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$GameAnalysisToJson(GameAnalysis instance) =>
    <String, dynamic>{
      'grandmasterSide': _$GrandmasterSideEnumMap[instance.grandmasterSide],
      'grandmasterDepthToMateInHalfMoves':
          instance.grandmasterDepthToMateInHalfMoves,
      'opening': instance.opening.toJson(),
      'analyzedMoves': instance.analyzedMoves.map((e) => e.toJson()).toList(),
    };

GameInfo _$GameInfoFromJson(Map<String, dynamic> json) {
  return GameInfo(
    json['event'] as String,
    json['site'] as String,
    _enUsDateTimeFromJson(json['date'] as String),
    json['round'] as String,
  );
}

Map<String, dynamic> _$GameInfoToJson(GameInfo instance) => <String, dynamic>{
      'event': instance.event,
      'site': instance.site,
      'date': _enUsDateTimeToJson(instance.date),
      'round': instance.round,
    };

AnalyzedGame _$AnalyzedGameFromJson(Map<String, dynamic> json) {
  return AnalyzedGame(
    json['id'] as String,
    _germanDateTimeFromJson(json['addedDate'] as String),
    json['pgn'] as String,
    _playerFromJson(json['whitePlayer'] as String),
    _playerFromJson(json['blackPlayer'] as String),
    json['whitePlayerRating'] as String,
    json['blackPlayerRating'] as String,
    GameInfo.fromJson(json['gameInfo'] as Map<String, dynamic>),
    GameAnalysis.fromJson(json['gameAnalysis'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$AnalyzedGameToJson(AnalyzedGame instance) =>
    <String, dynamic>{
      'id': instance.id,
      'addedDate': _germanDateTimeToJson(instance.addedDate),
      'pgn': instance.pgn,
      'whitePlayer': _playerToJson(instance.whitePlayer),
      'blackPlayer': _playerToJson(instance.blackPlayer),
      'whitePlayerRating': instance.whitePlayerRating,
      'blackPlayerRating': instance.blackPlayerRating,
      'gameInfo': instance.gameInfo.toJson(),
      'gameAnalysis': instance.gameAnalysis.toJson(),
    };
