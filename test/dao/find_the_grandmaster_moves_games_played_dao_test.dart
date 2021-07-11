import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guess_the_move/model/analyzed_game.dart';
import 'package:guess_the_move/model/analyzed_games_bundle.dart';
import 'package:guess_the_move/model/find_the_grandmaster_moves_game_played.dart';
import 'package:guess_the_move/model/game_played_info.dart';
import 'package:guess_the_move/model/player.dart';
import 'package:guess_the_move/model/summary_data.dart';
import 'package:guess_the_move/repository/analyzed_games_repository.dart';
import 'package:guess_the_move/repository/dao/find_the_grandmaster_moves_games_played_dao.dart';
import 'package:guess_the_move/repository/players_and_bundles_repository.dart';
import 'package:sembast/sembast.dart';

import 'utils/test_database_provider.dart';

const testDatabasePath = 'test/dao/db/findthegrandmastermovesgamesplayeddaotest.db';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FindTheGrandmasterMovesGamesPlayedDao test', () {
    final dbProvider = TestDatabaseProvider();
    late Database db;

    late Player grandmaster;
    late AnalyzedGamesBundle analyzedGamesBundle;
    late List<AnalyzedGame> analyzedGamesInBundle;

    final DateTime testDateTime1 = DateTime(2020, 05, 05, 17, 30);
    final DateTime testDateTime2 = DateTime(2020, 05, 05, 18, 30);
    final DateTime testDateTime3 = DateTime(2020, 07, 05, 10, 30);

    setUp(() async {
      db = await dbProvider.open(testDatabasePath);
      grandmaster = Player('Carlsen, Magnus', '-');
      analyzedGamesBundle = (await getAnalyzedGamesBundlesForGrandmaster(grandmaster)).first;
      analyzedGamesInBundle = await loadAnalyzedGamesInBundle(analyzedGamesBundle);
    });

    tearDown(() async {
      await db.close();
      return dbProvider.delete(testDatabasePath);
    });

    debugPrint('Running FindTheGrandmasterMovesGamesPlayedDao tests..');

    test('no data is retrieved before inserting data', () async {
      var gamesPlayed = await FindTheGrandmasterMovesGamesPlayedDao(database: db).getByAnalyzedGame(analyzedGamesInBundle.first);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed, isEmpty);

      gamesPlayed = await FindTheGrandmasterMovesGamesPlayedDao(database: db).getByGrandmaster(grandmaster);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed, isEmpty);

      gamesPlayed = await FindTheGrandmasterMovesGamesPlayedDao(database: db).getByPlayedDay(testDateTime1);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed, isEmpty);

      gamesPlayed = await FindTheGrandmasterMovesGamesPlayedDao(database: db).getByPlayedDay(testDateTime2);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed, isEmpty);

      gamesPlayed = await FindTheGrandmasterMovesGamesPlayedDao(database: db).getByPlayedDay(testDateTime3);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed, isEmpty);

      gamesPlayed = await FindTheGrandmasterMovesGamesPlayedDao(database: db).getByPlayedDateInRange(testDateTime1, testDateTime3);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed, isEmpty);

      final newestGamePlayed = await FindTheGrandmasterMovesGamesPlayedDao(database: db).getNewest();
      expect(newestGamePlayed, isNull);
    });

    test('insert and retrieve games played', () async {
      final gamePlayed1 = FindTheGrandmasterMovesGamePlayed(
        analyzedGameId: analyzedGamesInBundle.first.id,
        analyzedGameOriginBundle: analyzedGamesBundle,
        info: GamePlayedInfo(
          analyzedGameId: analyzedGamesInBundle.first.id,
          blackPlayer: analyzedGamesInBundle.first.blackPlayer,
          whitePlayer: analyzedGamesInBundle.first.whitePlayer,
          blackPlayerRating: analyzedGamesInBundle.first.blackPlayerRating,
          whitePlayerRating: analyzedGamesInBundle.first.whitePlayerRating,
          gameInfoString: analyzedGamesInBundle.first.gameInfo.toString(),
          grandmasterSide: analyzedGamesInBundle.first.gameAnalysis.grandmasterSide,
        ),
        gameEvaluationData: SummaryData([]),
        playedDateTimestamp: testDateTime1.millisecondsSinceEpoch,
      );

      final gamePlayed2 = FindTheGrandmasterMovesGamePlayed(
        analyzedGameId: analyzedGamesInBundle[1].id,
        analyzedGameOriginBundle: analyzedGamesBundle,
        info: GamePlayedInfo(
          analyzedGameId: analyzedGamesInBundle[1].id,
          blackPlayer: analyzedGamesInBundle[1].blackPlayer,
          whitePlayer: analyzedGamesInBundle[1].whitePlayer,
          blackPlayerRating: analyzedGamesInBundle[1].blackPlayerRating,
          whitePlayerRating: analyzedGamesInBundle[1].whitePlayerRating,
          gameInfoString: analyzedGamesInBundle[1].gameInfo.toString(),
          grandmasterSide: analyzedGamesInBundle[1].gameAnalysis.grandmasterSide,
        ),
        gameEvaluationData: SummaryData([]),
        playedDateTimestamp: testDateTime2.millisecondsSinceEpoch,
      );

      final gamePlayed3 = FindTheGrandmasterMovesGamePlayed(
        analyzedGameId: analyzedGamesInBundle[2].id,
        analyzedGameOriginBundle: analyzedGamesBundle,
        info: GamePlayedInfo(
          analyzedGameId: analyzedGamesInBundle[2].id,
          blackPlayer: analyzedGamesInBundle[2].blackPlayer,
          whitePlayer: analyzedGamesInBundle[2].whitePlayer,
          blackPlayerRating: analyzedGamesInBundle[2].blackPlayerRating,
          whitePlayerRating: analyzedGamesInBundle[2].whitePlayerRating,
          gameInfoString: analyzedGamesInBundle[2].gameInfo.toString(),
          grandmasterSide: analyzedGamesInBundle[2].gameAnalysis.grandmasterSide,
        ),
        gameEvaluationData: SummaryData([]),
        playedDateTimestamp: testDateTime3.millisecondsSinceEpoch,
      );

      // Inserts first game played
      await FindTheGrandmasterMovesGamesPlayedDao(database: db).insert(gamePlayed1);

      // Test retrieving this first game played

      var gamesPlayed = await FindTheGrandmasterMovesGamesPlayedDao(database: db).getByAnalyzedGame(analyzedGamesInBundle.first);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 1);
      expect(gamesPlayed.first, gamePlayed1);

      gamesPlayed = await FindTheGrandmasterMovesGamesPlayedDao(database: db).getByAnalyzedGame(analyzedGamesInBundle[1]);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed, isEmpty);

      gamesPlayed = await FindTheGrandmasterMovesGamesPlayedDao(database: db).getByAnalyzedGame(analyzedGamesInBundle[2]);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed, isEmpty);

      gamesPlayed = await FindTheGrandmasterMovesGamesPlayedDao(database: db).getByGrandmaster(grandmaster);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 1);
      expect(gamesPlayed.first, gamePlayed1);

      gamesPlayed = await FindTheGrandmasterMovesGamesPlayedDao(database: db).getByPlayedDay(testDateTime1);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 1);
      expect(gamesPlayed.first, gamePlayed1);

      gamesPlayed = await FindTheGrandmasterMovesGamesPlayedDao(database: db).getByPlayedDay(testDateTime2);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 1);
      expect(gamesPlayed.first, gamePlayed1);

      gamesPlayed = await FindTheGrandmasterMovesGamesPlayedDao(database: db).getByPlayedDay(testDateTime3);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed, isEmpty);

      gamesPlayed = await FindTheGrandmasterMovesGamesPlayedDao(database: db).getByPlayedDateInRange(testDateTime1, testDateTime3);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 1);
      expect(gamesPlayed.first, gamePlayed1);

      var newestGamePlayed = await FindTheGrandmasterMovesGamesPlayedDao(database: db).getNewest();
      expect(newestGamePlayed, isNotNull);
      expect(newestGamePlayed, gamePlayed1);

      // Inserts second game played
      await FindTheGrandmasterMovesGamesPlayedDao(database: db).insert(gamePlayed2);

      // Test retrieving first and second game played

      gamesPlayed = await FindTheGrandmasterMovesGamesPlayedDao(database: db).getByAnalyzedGame(analyzedGamesInBundle.first);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 1);
      expect(gamesPlayed.first, gamePlayed1);

      gamesPlayed = await FindTheGrandmasterMovesGamesPlayedDao(database: db).getByAnalyzedGame(analyzedGamesInBundle[1]);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 1);
      expect(gamesPlayed.first, gamePlayed2);

      gamesPlayed = await FindTheGrandmasterMovesGamesPlayedDao(database: db).getByAnalyzedGame(analyzedGamesInBundle[2]);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed, isEmpty);

      gamesPlayed = await FindTheGrandmasterMovesGamesPlayedDao(database: db).getByGrandmaster(grandmaster);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 2);
      expect(gamesPlayed.first, gamePlayed2);
      expect(gamesPlayed[1], gamePlayed1);

      gamesPlayed = await FindTheGrandmasterMovesGamesPlayedDao(database: db).getByPlayedDay(testDateTime1);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 2);
      expect(gamesPlayed.first, gamePlayed2);
      expect(gamesPlayed[1], gamePlayed1);

      gamesPlayed = await FindTheGrandmasterMovesGamesPlayedDao(database: db).getByPlayedDay(testDateTime2);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 2);
      expect(gamesPlayed.first, gamePlayed2);
      expect(gamesPlayed[1], gamePlayed1);

      gamesPlayed = await FindTheGrandmasterMovesGamesPlayedDao(database: db).getByPlayedDay(testDateTime3);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed, isEmpty);

      gamesPlayed = await FindTheGrandmasterMovesGamesPlayedDao(database: db).getByPlayedDateInRange(testDateTime1, testDateTime3);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 2);
      expect(gamesPlayed.first, gamePlayed2);
      expect(gamesPlayed[1], gamePlayed1);

      newestGamePlayed = await FindTheGrandmasterMovesGamesPlayedDao(database: db).getNewest();
      expect(newestGamePlayed, isNotNull);
      expect(newestGamePlayed, gamePlayed2);

      // Inserts third game played
      await FindTheGrandmasterMovesGamesPlayedDao(database: db).insert(gamePlayed3);

      // Test retrieving all three games played

      gamesPlayed = await FindTheGrandmasterMovesGamesPlayedDao(database: db).getByAnalyzedGame(analyzedGamesInBundle.first);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 1);
      expect(gamesPlayed.first, gamePlayed1);

      gamesPlayed = await FindTheGrandmasterMovesGamesPlayedDao(database: db).getByAnalyzedGame(analyzedGamesInBundle[1]);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 1);
      expect(gamesPlayed.first, gamePlayed2);

      gamesPlayed = await FindTheGrandmasterMovesGamesPlayedDao(database: db).getByAnalyzedGame(analyzedGamesInBundle[2]);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 1);
      expect(gamesPlayed.first, gamePlayed3);

      gamesPlayed = await FindTheGrandmasterMovesGamesPlayedDao(database: db).getByGrandmaster(grandmaster);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 3);
      expect(gamesPlayed[0], gamePlayed3);
      expect(gamesPlayed[1], gamePlayed2);
      expect(gamesPlayed[2], gamePlayed1);

      gamesPlayed = await FindTheGrandmasterMovesGamesPlayedDao(database: db).getByPlayedDay(testDateTime1);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 2);
      expect(gamesPlayed.first, gamePlayed2);
      expect(gamesPlayed[1], gamePlayed1);

      gamesPlayed = await FindTheGrandmasterMovesGamesPlayedDao(database: db).getByPlayedDay(testDateTime2);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 2);
      expect(gamesPlayed.first, gamePlayed2);
      expect(gamesPlayed[1], gamePlayed1);

      gamesPlayed = await FindTheGrandmasterMovesGamesPlayedDao(database: db).getByPlayedDay(testDateTime3);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 1);
      expect(gamesPlayed.first, gamePlayed3);

      gamesPlayed = await FindTheGrandmasterMovesGamesPlayedDao(database: db).getByPlayedDateInRange(testDateTime1, testDateTime3);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 3);
      expect(gamesPlayed[0], gamePlayed3);
      expect(gamesPlayed[1], gamePlayed2);
      expect(gamesPlayed[2], gamePlayed1);

      gamesPlayed = await FindTheGrandmasterMovesGamesPlayedDao(database: db).getByPlayedDateInRange(testDateTime1, testDateTime2);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 2);
      expect(gamesPlayed[0], gamePlayed2);
      expect(gamesPlayed[1], gamePlayed1);

      newestGamePlayed = await FindTheGrandmasterMovesGamesPlayedDao(database: db).getNewest();
      expect(newestGamePlayed, isNotNull);
      expect(newestGamePlayed, gamePlayed3);

      // Delete all games played
      await FindTheGrandmasterMovesGamesPlayedDao(database: db).deleteAll();

      // Test that we can not retrieve any games played anymore

      gamesPlayed = await FindTheGrandmasterMovesGamesPlayedDao(database: db).getByAnalyzedGame(analyzedGamesInBundle.first);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed, isEmpty);

      gamesPlayed = await FindTheGrandmasterMovesGamesPlayedDao(database: db).getByGrandmaster(grandmaster);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed, isEmpty);

      gamesPlayed = await FindTheGrandmasterMovesGamesPlayedDao(database: db).getByPlayedDay(testDateTime1);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed, isEmpty);

      gamesPlayed = await FindTheGrandmasterMovesGamesPlayedDao(database: db).getByPlayedDay(testDateTime2);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed, isEmpty);

      gamesPlayed = await FindTheGrandmasterMovesGamesPlayedDao(database: db).getByPlayedDay(testDateTime3);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed, isEmpty);

      gamesPlayed = await FindTheGrandmasterMovesGamesPlayedDao(database: db).getByPlayedDateInRange(testDateTime1, testDateTime3);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed, isEmpty);

      newestGamePlayed = await FindTheGrandmasterMovesGamesPlayedDao(database: db).getNewest();
      expect(newestGamePlayed, isNull);
    });
  });
}
