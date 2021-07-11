import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:guess_the_move/model/analyzed_game.dart';
import 'package:guess_the_move/model/analyzed_games_bundle.dart';
import 'package:guess_the_move/model/player.dart';
import 'package:guess_the_move/model/players_and_bundles_meta.dart';
import 'package:path/path.dart' as p;
import 'package:tuple/tuple.dart';

final analyzedGamesBundleByGrandmasterAndYearRegex = RegExp(
  r"^.*[/\\]([a-zA-Z0-9 '\-]+, [a-zA-Z0-9 '\-]+)_([1-9][0-9]{3})_compressed$",
  multiLine: false,
);

main(final List<String> args) async {
  final analyzedGamesDirectoryPath = p.normalize(p.join(p.current, 'assets', 'analyzed_games'));
  final analyzedGamesDirectory = Directory(analyzedGamesDirectoryPath);

  final filesInAnalyzedGamesDirectory = await _getDirectoryContents(analyzedGamesDirectory);

  Set<Player> grandmasters = {};
  final Map<Player, Tuple2<int, String>> latestEloRatingByGrandmaster = {};
  final Set<AnalyzedGamesBundle> analyzedGamesBundles = {};
  final Map<String, int> gamesAmountByAnalyzedGamesBundleId = {};

  for (final file in filesInAnalyzedGamesDirectory) {
    final fileExtension = p.extension(file.path);
    if (!(file is File) || fileExtension != '') {
      continue;
    }

    if (analyzedGamesBundleByGrandmasterAndYearRegex.hasMatch(file.path)) {
      final match = analyzedGamesBundleByGrandmasterAndYearRegex.firstMatch(file.path);

      final startTime = DateTime.now().millisecondsSinceEpoch;

      final grandmaster = Player(match!.group(1)!, '-');
      final year = int.parse(match.group(2)!);

      final analyzedGamesBundle = AnalyzedGamesBundleByGrandmasterAndYear(grandmaster: grandmaster, year: year);

      final allGamesInBundle = await _loadAnalyzedGamesFromFile(file);

      allGamesInBundle.sort((game1, game2) => game1.gameInfo.date.millisecondsSinceEpoch.compareTo(game2.gameInfo.date.millisecondsSinceEpoch));

      final latestGameInBundle = allGamesInBundle.last;
      if (!latestEloRatingByGrandmaster.containsKey(grandmaster) || latestEloRatingByGrandmaster[grandmaster]!.item1 < year) {
        latestEloRatingByGrandmaster[grandmaster] = Tuple2<int, String>(year, latestGameInBundle.getGrandmasterRating());
      }

      grandmasters.add(grandmaster);
      analyzedGamesBundles.add(analyzedGamesBundle);
      gamesAmountByAnalyzedGamesBundleId.putIfAbsent(analyzedGamesBundle.getId(), () => allGamesInBundle.length);

      final endTime = DateTime.now().millisecondsSinceEpoch;

      print('Found analyzed games bundle by grandmaster and year:');
      print('Grandmaster: ${grandmaster.getFirstAndLastName()}');
      print('Year: $year');
      print('Games in bundle: ${allGamesInBundle.length}');
      print('Parsed bundle in ${endTime - startTime}ms');
      print('');
    }
  }

  grandmasters = grandmasters
      .map(
        (grandmaster) => Player(
          grandmaster.fullName,
          latestEloRatingByGrandmaster.containsKey(grandmaster) ? latestEloRatingByGrandmaster[grandmaster]!.item2 : '-',
        ),
      )
      .toSet();

  final totalGamesAmount = ([0] + gamesAmountByAnalyzedGamesBundleId.values.toList()).reduce((value, element) => value + element);

  print('Done.');
  print('Found ${grandmasters.length} grandmasters and ${analyzedGamesBundles.length} analyzed games bundles with $totalGamesAmount games in total.');

  final meta = PlayersAndBundlesMeta(grandmasters, analyzedGamesBundles, gamesAmountByAnalyzedGamesBundleId);
  _savePlayersAndBundlesMetaToFile(meta);

  return 0;
}

void _savePlayersAndBundlesMetaToFile(final PlayersAndBundlesMeta meta) async {
  final metaOutputFilePath = p.normalize(p.join(p.current, 'assets', 'generated_meta.json'));
  final metaOutputFile = File(metaOutputFilePath);
  await metaOutputFile.writeAsString(jsonEncode(meta.toJson()));
  print('Saved output json file at $metaOutputFilePath.');
}

Future<List<FileSystemEntity>> _getDirectoryContents(final Directory directory) {
  var files = <FileSystemEntity>[];
  var completer = Completer<List<FileSystemEntity>>();
  var lister = directory.list(recursive: false);
  lister.listen(
    (file) => files.add(file),
    onDone: () => completer.complete(files),
    onError: (e, s) => throw StateError('Error parsing file in given directory at ${directory.path}. Original error: ${e.toString()}. Stacktrace: ${s.toString()}'),
  );
  return completer.future;
}

Future<List<AnalyzedGame>> _loadAnalyzedGamesFromFile(final File file) async {
  final Uint8List gzipBytes = await file.readAsBytes();

  var contentBytes = GZipCodec().decode(gzipBytes);
  var contentJsonString = utf8.decode(contentBytes);

  return _parseAnalyzedGame(contentJsonString);
}

List<AnalyzedGame> _parseAnalyzedGame(final String contentJsonString) {
  final List<dynamic> parsed = jsonDecode(contentJsonString);
  return parsed.map<AnalyzedGame>((json) => AnalyzedGame.fromJson(json)).toList();
}
