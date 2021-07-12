import 'package:equatable/equatable.dart';
import 'package:guess_the_move/model/player.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

part 'analyzed_game.g.dart';

final DateFormat enUsDateFormat = DateFormat('yyyy.MM.dd');
DateTime _enUsDateTimeFromJson(final String date) => enUsDateFormat.parse(date);
String _enUsDateTimeToJson(final DateTime date) => enUsDateFormat.format(date);

final DateFormat germanDateTimeFormat = DateFormat('dd/MM/yyyy hh:mm:ss');
DateTime _germanDateTimeFromJson(final String date) => germanDateTimeFormat.parse(date);
String _germanDateTimeToJson(final DateTime date) => germanDateTimeFormat.format(date);

final DateFormat germanDateTimeFormatShort = DateFormat('dd.MM.yyyy');

enum GrandmasterSide { white, black }

enum GamePhase { opening, midgame, endgame }

enum AnalyzedMoveType { book, blunder, mistake, inaccuracy, okay, good, excellent, best, brilliant, critical, gameChanger }

extension AnalyzedMoveTypeExtension on AnalyzedMoveType {
  String get name {
    switch (this) {
      case AnalyzedMoveType.critical:
        return 'Einzige Wahl';
      case AnalyzedMoveType.gameChanger:
        return 'Konter';
      case AnalyzedMoveType.blunder:
        return 'Grober Fehler';
      case AnalyzedMoveType.inaccuracy:
        return 'Ungenauigkeit';
      case AnalyzedMoveType.mistake:
        return 'Fehler';
      case AnalyzedMoveType.best:
        return 'Bester Zug';
      case AnalyzedMoveType.brilliant:
        return 'Brillanter Zug';
      case AnalyzedMoveType.excellent:
        return 'Sehr guter Zug';
      case AnalyzedMoveType.good:
        return 'Guter Zug';
      case AnalyzedMoveType.okay:
        return 'Mittelmäßiger Zug';
      default:
        throw StateError('Unknown enum type');
    }
  }
}

@JsonSerializable()
class Opening {
  final String eco;
  final String name;
  final String fen;
  final String moves;

  Opening(this.eco, this.name, this.fen, this.moves);

  List<String> getMovesList() => moves.split(' ');

  factory Opening.fromJson(Map<String, dynamic> json) => _$OpeningFromJson(json);
  Map<String, dynamic> toJson() => _$OpeningToJson(this);
}

@JsonSerializable()
class Move {
  final String uci;
  final String san;

  Move(this.uci, this.san);

  factory Move.fromJson(Map<String, dynamic> json) => _$MoveFromJson(json);
  Map<String, dynamic> toJson() => _$MoveToJson(this);
}

@JsonSerializable()
class EvaluatedMove extends Equatable {
  final Move move;
  final AnalyzedMoveType moveType;
  final String signedCPScore;
  final double gmExpectation;
  final String pv;

  EvaluatedMove(this.move, this.moveType, this.signedCPScore, this.gmExpectation, this.pv);

  factory EvaluatedMove.fromJson(Map<String, dynamic> json) => _$EvaluatedMoveFromJson(json);
  Map<String, dynamic> toJson() => _$EvaluatedMoveToJson(this);

  @override
  List<Object?> get props => [move.san];
}

@JsonSerializable()
class AnalyzedMove extends Equatable {
  final int ply;
  final GamePhase gamePhase;
  final GrandmasterSide turn;
  final EvaluatedMove actualMove;
  final List<EvaluatedMove> alternativeMoves;

  AnalyzedMove(this.ply, this.gamePhase, this.turn, this.actualMove, this.alternativeMoves);

  factory AnalyzedMove.fromJson(Map<String, dynamic> json) => _$AnalyzedMoveFromJson(json);
  Map<String, dynamic> toJson() => _$AnalyzedMoveToJson(this);

  @override
  List<Object?> get props => [ply, gamePhase.toString(), turn.toString(), actualMove, alternativeMoves];
}

@JsonSerializable()
class GameAnalysis {
  final GrandmasterSide grandmasterSide;
  final int? grandmasterDepthToMateInHalfMoves;
  final Opening opening;
  final List<AnalyzedMove> analyzedMoves;

  GameAnalysis(this.grandmasterSide, this.grandmasterDepthToMateInHalfMoves, this.opening, this.analyzedMoves);

  factory GameAnalysis.fromJson(Map<String, dynamic> json) => _$GameAnalysisFromJson(json);
  Map<String, dynamic> toJson() => _$GameAnalysisToJson(this);
}

@JsonSerializable()
class GameInfo {
  final String event;
  final String site;
  @JsonKey(fromJson: _enUsDateTimeFromJson, toJson: _enUsDateTimeToJson)
  final DateTime date;
  final String round;

  GameInfo(this.event, this.site, this.date, this.round);

  factory GameInfo.fromJson(Map<String, dynamic> json) => _$GameInfoFromJson(json);
  Map<String, dynamic> toJson() => _$GameInfoToJson(this);

  String getEventAndSite() {
    return '$event - $site';
  }

  String getDateFormatted() {
    return germanDateTimeFormatShort.format(date);
  }

  String getRoundAndDate() {
    return 'Runde $round am ${getDateFormatted()}';
  }

  @override
  String toString() {
    return '${getEventAndSite()}\n${getRoundAndDate()}';
  }
}

Player _playerFromJson(final String playerName) => Player(playerName, '-');
String _playerToJson(final Player player) => player.fullName;

@JsonSerializable()
class AnalyzedGame extends Equatable {
  final String id;
  @JsonKey(fromJson: _germanDateTimeFromJson, toJson: _germanDateTimeToJson)
  final DateTime addedDate;
  final String pgn;
  @JsonKey(fromJson: _playerFromJson, toJson: _playerToJson)
  final Player whitePlayer;
  @JsonKey(fromJson: _playerFromJson, toJson: _playerToJson)
  final Player blackPlayer;
  final String whitePlayerRating;
  final String blackPlayerRating;
  final GameInfo gameInfo;
  final GameAnalysis gameAnalysis;

  AnalyzedGame(this.id, this.addedDate, this.pgn, this.whitePlayer, this.blackPlayer, this.whitePlayerRating, this.blackPlayerRating, this.gameInfo, this.gameAnalysis);

  factory AnalyzedGame.fromJson(Map<String, dynamic> json) => _$AnalyzedGameFromJson(json);
  Map<String, dynamic> toJson() => _$AnalyzedGameToJson(this);

  String getGrandmasterRating() {
    return gameAnalysis.grandmasterSide == GrandmasterSide.white ? whitePlayerRating : blackPlayerRating;
  }

  Player getGrandmaster() {
    return gameAnalysis.grandmasterSide == GrandmasterSide.white ? whitePlayer : blackPlayer;
  }

  bool wasAnalyzedFromPerspectiveOf(final Player player) {
    return (whitePlayer == player && gameAnalysis.grandmasterSide == GrandmasterSide.white) || (blackPlayer == player && gameAnalysis.grandmasterSide == GrandmasterSide.black);
  }

  @override
  List<Object?> get props => [id, whitePlayer, blackPlayer, whitePlayerRating, blackPlayerRating, gameInfo, pgn, addedDate];
}
