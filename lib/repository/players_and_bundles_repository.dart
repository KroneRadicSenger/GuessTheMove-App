import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:guess_the_move/model/analyzed_games_bundle.dart';
import 'package:guess_the_move/model/player.dart';
import 'package:guess_the_move/model/players_and_bundles_meta.dart';

PlayersAndBundlesMeta? _playersAndBundlesMeta;

Future<List<AnalyzedGamesBundle>> getAnalyzedGamesBundlesForGrandmaster(final Player grandmaster) async {
  await _loadMetaFile();
  final analyzedGamesBundlesForGrandmaster =
      _playersAndBundlesMeta!.analyzedGamesBundles.where((bundle) => bundle is AnalyzedGamesBundleByGrandmasterAndYear && bundle.grandmaster == grandmaster).toList();
  analyzedGamesBundlesForGrandmaster.sort();
  return analyzedGamesBundlesForGrandmaster;
}

Future<int> getTotalAnalyzedGamesAmountForGrandmaster(final Player grandmaster) async {
  await _loadMetaFile();
  final grandmasterBundles = await getAnalyzedGamesBundlesForGrandmaster(grandmaster);
  final gamesAmountsInGrandmasterBundles = grandmasterBundles.map((bundle) => _playersAndBundlesMeta!.gamesAmountByAnalyzedGamesBundleId[bundle.getId()]!).toList();
  return ([0] + gamesAmountsInGrandmasterBundles).reduce((value, element) => value + element);
}

Future<List<AnalyzedGamesBundle>> getAllAnalyzedGamesBundles() async {
  await _loadMetaFile();
  return _playersAndBundlesMeta!.analyzedGamesBundles.toList();
}

Future<List<Player>> getAllGrandmasters() async {
  await _loadMetaFile();
  return _playersAndBundlesMeta!.grandmasters.toList();
}

Future<void> _loadMetaFile() async {
  if (_playersAndBundlesMeta != null) {
    return;
  }
  final fileContents = await rootBundle.loadString('assets/generated_meta.json');
  final fileJson = jsonDecode(fileContents);
  _playersAndBundlesMeta = PlayersAndBundlesMeta.fromJson(fileJson);
}
