import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:guess_the_move/model/analyzed_game.dart';
import 'package:guess_the_move/model/analyzed_games_bundle.dart';

final Map<AnalyzedGamesBundle, List<AnalyzedGame>> analyzedGamesByBundle = {};

Future<List<AnalyzedGame>> loadAnalyzedGamesInBundle(final AnalyzedGamesBundle analyzedGamesBundle) async {
  if (isAnalyzedGamesBundleLoaded(analyzedGamesBundle)) {
    return analyzedGamesByBundle[analyzedGamesBundle]!;
  }

  final Future<List<AnalyzedGame>> analyzedGamesFuture = _loadAnalyzedGamesFromFile(analyzedGamesBundle.getFileName());
  analyzedGamesFuture.then((list) {
    analyzedGamesByBundle[analyzedGamesBundle] = list;
  });

  return analyzedGamesFuture;
}

bool isAnalyzedGamesBundleLoaded(final AnalyzedGamesBundle analyzedGamesBundle) {
  return analyzedGamesByBundle.containsKey(analyzedGamesBundle);
}

AnalyzedGame? getAnalyzedGameByBundleAndId(final AnalyzedGamesBundle analyzedGamesBundle, final String analyzedGameId) {
  if (!analyzedGamesByBundle.containsKey(analyzedGamesBundle)) {
    return null;
  }
  final gamesMatched = analyzedGamesByBundle[analyzedGamesBundle]!.where((game) => game.id == analyzedGameId);
  return gamesMatched.isNotEmpty ? gamesMatched.first : null;
}

Future<List<AnalyzedGame>> _loadAnalyzedGamesFromFile(final String fileName) async {
  final String compressedFileName = 'assets/analyzed_games/$fileName';

  final Uint8List gzipBytes;
  try {
    final ByteData byteData = await rootBundle.load(compressedFileName);
    gzipBytes = byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
  } on Exception {
    return Future.error('Es existiert kein Spielepaket mit dem gebenenen Namen.');
  }

  var contentBytes = GZipCodec().decode(gzipBytes);
  var contentJsonString = utf8.decode(contentBytes);

  // Use compute to run the parsing in a separate isolate
  return compute(_parseAnalyzedGame, {'content': contentJsonString});
}

List<AnalyzedGame> _parseAnalyzedGame(Map argumentsMap) {
  final List<dynamic> parsed = jsonDecode(argumentsMap['content']);
  return parsed.map<AnalyzedGame>((json) => AnalyzedGame.fromJson(json)).toList();
}
