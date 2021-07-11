import 'package:equatable/equatable.dart';
import 'package:guess_the_move/model/analyzed_game.dart';
import 'package:guess_the_move/model/player.dart';
import 'package:json_annotation/json_annotation.dart';

part 'game_played_info.g.dart';

@JsonSerializable()
class GamePlayedInfo extends Equatable {
  final String analyzedGameId;
  final Player whitePlayer;
  final Player blackPlayer;
  final String whitePlayerRating;
  final String blackPlayerRating;
  final GrandmasterSide grandmasterSide;
  final String gameInfoString;

  GamePlayedInfo({
    required this.analyzedGameId,
    required this.whitePlayer,
    required this.blackPlayer,
    required this.whitePlayerRating,
    required this.blackPlayerRating,
    required this.grandmasterSide,
    required this.gameInfoString,
  });

  Player getGrandmaster() {
    return grandmasterSide == GrandmasterSide.white ? whitePlayer : blackPlayer;
  }

  @override
  List<Object?> get props => [analyzedGameId, whitePlayer, blackPlayer, whitePlayerRating, blackPlayerRating, gameInfoString];

  factory GamePlayedInfo.fromJson(Map<String, dynamic> json) => _$GamePlayedInfoFromJson(json);
  Map<String, dynamic> toJson() => _$GamePlayedInfoToJson(this);
}
