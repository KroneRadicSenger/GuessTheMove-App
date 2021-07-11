import 'package:equatable/equatable.dart';
import 'package:guess_the_move/model/analyzed_games_bundle.dart';
import 'package:guess_the_move/model/game_played_info.dart';
import 'package:guess_the_move/model/player.dart';
import 'package:guess_the_move/model/summary_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'survival_game_played.g.dart';

@JsonSerializable()
class SurvivalGamePlayed extends Equatable {
  final Player grandmaster;
  final AnalyzedGamesBundle analyzedGameOriginBundle;
  final int amountLives;
  final int totalPointsGivenAmount;
  final int totalMovesPlayedAmount;
  final int correctMovesPlayedAmount;
  final List<String> analyzedGamesPlayedIds;
  final List<GamePlayedInfo> gamesPlayedInfo;
  final List<SummaryData> analyzedGamesPlayedSummaryData;
  final int playedDateTimestamp;

  SurvivalGamePlayed(
      {required this.grandmaster,
      required this.amountLives,
      required this.analyzedGameOriginBundle,
      required this.analyzedGamesPlayedIds,
      required this.gamesPlayedInfo,
      required this.analyzedGamesPlayedSummaryData,
      required this.totalPointsGivenAmount,
      required this.totalMovesPlayedAmount,
      required this.correctMovesPlayedAmount,
      required this.playedDateTimestamp});

  @override
  List<Object?> get props => [
        grandmaster,
        analyzedGameOriginBundle,
        amountLives,
        totalPointsGivenAmount,
        totalMovesPlayedAmount,
        correctMovesPlayedAmount,
        analyzedGamesPlayedIds,
        gamesPlayedInfo,
        analyzedGamesPlayedSummaryData,
        playedDateTimestamp
      ];

  factory SurvivalGamePlayed.fromJson(Map<String, dynamic> json) => _$SurvivalGamePlayedFromJson(json);
  Map<String, dynamic> toJson() => _$SurvivalGamePlayedToJson(this);
}
