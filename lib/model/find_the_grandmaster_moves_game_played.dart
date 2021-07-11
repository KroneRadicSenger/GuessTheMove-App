import 'package:equatable/equatable.dart';
import 'package:guess_the_move/model/analyzed_games_bundle.dart';
import 'package:guess_the_move/model/game_played_info.dart';
import 'package:guess_the_move/model/summary_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'find_the_grandmaster_moves_game_played.g.dart';

@JsonSerializable()
class FindTheGrandmasterMovesGamePlayed extends Equatable {
  final String analyzedGameId;
  final AnalyzedGamesBundle analyzedGameOriginBundle;
  final GamePlayedInfo info;
  final SummaryData gameEvaluationData;
  final int playedDateTimestamp;

  FindTheGrandmasterMovesGamePlayed(
      {required this.analyzedGameId, required this.analyzedGameOriginBundle, required this.info, required this.gameEvaluationData, required this.playedDateTimestamp});

  @override
  List<Object?> get props => [analyzedGameId, info, gameEvaluationData, playedDateTimestamp];

  factory FindTheGrandmasterMovesGamePlayed.fromJson(Map<String, dynamic> json) => _$FindTheGrandmasterMovesGamePlayedFromJson(json);
  Map<String, dynamic> toJson() => _$FindTheGrandmasterMovesGamePlayedToJson(this);
}
