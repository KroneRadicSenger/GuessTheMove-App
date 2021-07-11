import 'package:equatable/equatable.dart';
import 'package:guess_the_move/model/analyzed_games_bundle.dart';
import 'package:guess_the_move/model/player.dart';
import 'package:json_annotation/json_annotation.dart';

part 'players_and_bundles_meta.g.dart';

@JsonSerializable()
class PlayersAndBundlesMeta extends Equatable {
  final Set<Player> grandmasters;
  final Set<AnalyzedGamesBundle> analyzedGamesBundles;
  final Map<String, int> gamesAmountByAnalyzedGamesBundleId;

  PlayersAndBundlesMeta(this.grandmasters, this.analyzedGamesBundles, this.gamesAmountByAnalyzedGamesBundleId);

  factory PlayersAndBundlesMeta.fromJson(Map<String, dynamic> json) => _$PlayersAndBundlesMetaFromJson(json);

  Map<String, dynamic> toJson() => _$PlayersAndBundlesMetaToJson(this);

  @override
  List<Object?> get props => [grandmasters, analyzedGamesBundles, gamesAmountByAnalyzedGamesBundleId];
}
