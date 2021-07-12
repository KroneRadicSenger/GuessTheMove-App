import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guess_the_move/model/analyzed_game.dart';
import 'package:guess_the_move/model/analyzed_games_bundle.dart';
import 'package:guess_the_move/model/game_played_info.dart';
import 'package:guess_the_move/model/player.dart';
import 'package:guess_the_move/model/summary_data.dart';
import 'package:guess_the_move/model/time_battle_game_played.dart';
import 'package:guess_the_move/repository/analyzed_games_repository.dart';
import 'package:guess_the_move/repository/dao/time_battle_games_played_dao.dart';
import 'package:guess_the_move/repository/players_and_bundles_repository.dart';
import 'package:sembast/sembast.dart';

import 'utils/test_database_provider.dart';

const testDatabasePath = 'test/dao/db/timebattlegamesplayeddaotest.db';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TimeBattleGamesPlayedDao test', () {
    final dbProvider = TestDatabaseProvider();
    late Database db;

    late Player grandmaster;
    late AnalyzedGamesBundle analyzedGamesBundle;
    late List<AnalyzedGame> analyzedGamesInBundle;

    final DateTime testDateTime1 = DateTime(2020, 05, 05, 17, 30);
    final DateTime testDateTime2 = DateTime(2020, 05, 05, 18, 30);
    final DateTime testDateTime3 = DateTime(2020, 07, 05, 10, 30);

    final initialTimeInSeconds1 = 5;
    final initialTimeInSeconds2 = 5;
    final initialTimeInSeconds3 = 10;

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

    debugPrint('Running TimeBattleGamesPlayedDao tests..');

    test('no data is retrieved before inserting data', () async {
      var gamesPlayed = await TimeBattleGamesPlayedDao(database: db).getAll();
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed, isEmpty);

      gamesPlayed = await TimeBattleGamesPlayedDao(database: db).getByAnalyzedGamesBundleAndInitialTimeInSeconds(analyzedGamesBundle, initialTimeInSeconds1);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed, isEmpty);

      gamesPlayed = await TimeBattleGamesPlayedDao(database: db).getByAnalyzedGamesBundleAndInitialTimeInSeconds(analyzedGamesBundle, initialTimeInSeconds2);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed, isEmpty);

      gamesPlayed = await TimeBattleGamesPlayedDao(database: db).getByAnalyzedGamesBundleAndInitialTimeInSeconds(analyzedGamesBundle, initialTimeInSeconds3);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed, isEmpty);

      gamesPlayed = await TimeBattleGamesPlayedDao(database: db).getByGrandmaster(grandmaster);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed, isEmpty);

      gamesPlayed = await TimeBattleGamesPlayedDao(database: db).getByPlayedDay(testDateTime1);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed, isEmpty);

      gamesPlayed = await TimeBattleGamesPlayedDao(database: db).getByPlayedDay(testDateTime2);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed, isEmpty);

      gamesPlayed = await TimeBattleGamesPlayedDao(database: db).getByPlayedDay(testDateTime3);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed, isEmpty);

      gamesPlayed = await TimeBattleGamesPlayedDao(database: db).getByPlayedDateInRange(testDateTime1, testDateTime3);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed, isEmpty);

      final newestGamePlayed = await TimeBattleGamesPlayedDao(database: db).getNewest();
      expect(newestGamePlayed, isNull);

      var highscoreGamePlayed =
          await TimeBattleGamesPlayedDao(database: db).getHighscoreGamePlayedByAnalyzedGamesBundleAndInitialTimeInSeconds(analyzedGamesBundle, initialTimeInSeconds1);
      expect(highscoreGamePlayed, isNull);

      highscoreGamePlayed =
          await TimeBattleGamesPlayedDao(database: db).getHighscoreGamePlayedByAnalyzedGamesBundleAndInitialTimeInSeconds(analyzedGamesBundle, initialTimeInSeconds2);
      expect(highscoreGamePlayed, isNull);

      highscoreGamePlayed =
          await TimeBattleGamesPlayedDao(database: db).getHighscoreGamePlayedByAnalyzedGamesBundleAndInitialTimeInSeconds(analyzedGamesBundle, initialTimeInSeconds3);
      expect(highscoreGamePlayed, isNull);
    });

    test('insert and retrieve games played', () async {
      final gamePlayed1 = TimeBattleGamePlayed(
        grandmaster: grandmaster,
        initialTimeInSeconds: initialTimeInSeconds1,
        analyzedGameOriginBundle: analyzedGamesBundle,
        analyzedGamesPlayedIds: [analyzedGamesInBundle.first.id],
        analyzedGamesPlayedSummaryData: [SummaryData([])],
        correctMovesPlayedAmount: 10,
        totalMovesPlayedAmount: 15,
        totalPointsGivenAmount: 1000,
        gamesPlayedInfo: [
          GamePlayedInfo(
            analyzedGameId: analyzedGamesInBundle.first.id,
            blackPlayer: analyzedGamesInBundle.first.blackPlayer,
            whitePlayer: analyzedGamesInBundle.first.whitePlayer,
            blackPlayerRating: analyzedGamesInBundle.first.blackPlayerRating,
            whitePlayerRating: analyzedGamesInBundle.first.whitePlayerRating,
            gameInfoString: analyzedGamesInBundle.first.gameInfo.toString(),
            grandmasterSide: analyzedGamesInBundle.first.gameAnalysis.grandmasterSide,
          ),
        ],
        playedDateTimestamp: testDateTime1.millisecondsSinceEpoch,
      );

      final gamePlayed2 = TimeBattleGamePlayed(
        grandmaster: grandmaster,
        initialTimeInSeconds: initialTimeInSeconds2,
        analyzedGameOriginBundle: analyzedGamesBundle,
        analyzedGamesPlayedIds: [analyzedGamesInBundle[1].id],
        analyzedGamesPlayedSummaryData: [SummaryData([])],
        correctMovesPlayedAmount: 11,
        totalMovesPlayedAmount: 16,
        totalPointsGivenAmount: 1500,
        gamesPlayedInfo: [
          GamePlayedInfo(
            analyzedGameId: analyzedGamesInBundle[1].id,
            blackPlayer: analyzedGamesInBundle[1].blackPlayer,
            whitePlayer: analyzedGamesInBundle[1].whitePlayer,
            blackPlayerRating: analyzedGamesInBundle[1].blackPlayerRating,
            whitePlayerRating: analyzedGamesInBundle[1].whitePlayerRating,
            gameInfoString: analyzedGamesInBundle[1].gameInfo.toString(),
            grandmasterSide: analyzedGamesInBundle[1].gameAnalysis.grandmasterSide,
          ),
        ],
        playedDateTimestamp: testDateTime2.millisecondsSinceEpoch,
      );

      final gamePlayed3 = TimeBattleGamePlayed(
        grandmaster: grandmaster,
        initialTimeInSeconds: initialTimeInSeconds3,
        analyzedGameOriginBundle: analyzedGamesBundle,
        analyzedGamesPlayedIds: [analyzedGamesInBundle[2].id],
        analyzedGamesPlayedSummaryData: [SummaryData([])],
        correctMovesPlayedAmount: 10,
        totalMovesPlayedAmount: 15,
        totalPointsGivenAmount: 1000,
        gamesPlayedInfo: [
          GamePlayedInfo(
            analyzedGameId: analyzedGamesInBundle[2].id,
            blackPlayer: analyzedGamesInBundle[2].blackPlayer,
            whitePlayer: analyzedGamesInBundle[2].whitePlayer,
            blackPlayerRating: analyzedGamesInBundle[2].blackPlayerRating,
            whitePlayerRating: analyzedGamesInBundle[2].whitePlayerRating,
            gameInfoString: analyzedGamesInBundle[2].gameInfo.toString(),
            grandmasterSide: analyzedGamesInBundle[2].gameAnalysis.grandmasterSide,
          ),
        ],
        playedDateTimestamp: testDateTime3.millisecondsSinceEpoch,
      );

      // Inserts first game played
      await TimeBattleGamesPlayedDao(database: db).insert(gamePlayed1);

      // Test retrieving this first game played

      var gamesPlayed = await TimeBattleGamesPlayedDao(database: db).getAll();
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed!.length, 1);
      expect(gamesPlayed.first, gamePlayed1);

      gamesPlayed = await TimeBattleGamesPlayedDao(database: db).getByAnalyzedGamesBundleAndInitialTimeInSeconds(analyzedGamesBundle, initialTimeInSeconds1);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 1);
      expect(gamesPlayed.first, gamePlayed1);

      gamesPlayed = await TimeBattleGamesPlayedDao(database: db).getByAnalyzedGamesBundleAndInitialTimeInSeconds(analyzedGamesBundle, initialTimeInSeconds2);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 1);
      expect(gamesPlayed.first, gamePlayed1);

      gamesPlayed = await TimeBattleGamesPlayedDao(database: db).getByAnalyzedGamesBundleAndInitialTimeInSeconds(analyzedGamesBundle, initialTimeInSeconds3);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed, isEmpty);

      gamesPlayed = await TimeBattleGamesPlayedDao(database: db).getByGrandmaster(grandmaster);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 1);
      expect(gamesPlayed.first, gamePlayed1);

      gamesPlayed = await TimeBattleGamesPlayedDao(database: db).getByPlayedDay(testDateTime1);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 1);
      expect(gamesPlayed.first, gamePlayed1);

      gamesPlayed = await TimeBattleGamesPlayedDao(database: db).getByPlayedDay(testDateTime2);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 1);
      expect(gamesPlayed.first, gamePlayed1);

      gamesPlayed = await TimeBattleGamesPlayedDao(database: db).getByPlayedDay(testDateTime3);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed, isEmpty);

      gamesPlayed = await TimeBattleGamesPlayedDao(database: db).getByPlayedDateInRange(testDateTime1, testDateTime3);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 1);
      expect(gamesPlayed.first, gamePlayed1);

      var newestGamePlayed = await TimeBattleGamesPlayedDao(database: db).getNewest();
      expect(newestGamePlayed, isNotNull);
      expect(newestGamePlayed, gamePlayed1);

      var highscoreGamePlayed =
          await TimeBattleGamesPlayedDao(database: db).getHighscoreGamePlayedByAnalyzedGamesBundleAndInitialTimeInSeconds(analyzedGamesBundle, initialTimeInSeconds1);
      expect(highscoreGamePlayed, isNotNull);
      expect(highscoreGamePlayed, gamePlayed1);

      highscoreGamePlayed =
          await TimeBattleGamesPlayedDao(database: db).getHighscoreGamePlayedByAnalyzedGamesBundleAndInitialTimeInSeconds(analyzedGamesBundle, initialTimeInSeconds2);
      expect(highscoreGamePlayed, isNotNull);
      expect(highscoreGamePlayed, gamePlayed1);

      highscoreGamePlayed =
          await TimeBattleGamesPlayedDao(database: db).getHighscoreGamePlayedByAnalyzedGamesBundleAndInitialTimeInSeconds(analyzedGamesBundle, initialTimeInSeconds3);
      expect(highscoreGamePlayed, isNull);

      // Inserts second game played
      await TimeBattleGamesPlayedDao(database: db).insert(gamePlayed2);

      // Test retrieving first and second game played

      gamesPlayed = await TimeBattleGamesPlayedDao(database: db).getAll();
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed!.length, 2);
      expect(gamesPlayed.first, gamePlayed2);
      expect(gamesPlayed[1], gamePlayed1);

      gamesPlayed = await TimeBattleGamesPlayedDao(database: db).getByAnalyzedGamesBundleAndInitialTimeInSeconds(analyzedGamesBundle, initialTimeInSeconds1);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 2);
      expect(gamesPlayed.first, gamePlayed2);
      expect(gamesPlayed[1], gamePlayed1);

      gamesPlayed = await TimeBattleGamesPlayedDao(database: db).getByAnalyzedGamesBundleAndInitialTimeInSeconds(analyzedGamesBundle, initialTimeInSeconds2);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 2);
      expect(gamesPlayed.first, gamePlayed2);
      expect(gamesPlayed[1], gamePlayed1);

      gamesPlayed = await TimeBattleGamesPlayedDao(database: db).getByAnalyzedGamesBundleAndInitialTimeInSeconds(analyzedGamesBundle, initialTimeInSeconds3);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed, isEmpty);

      gamesPlayed = await TimeBattleGamesPlayedDao(database: db).getByGrandmaster(grandmaster);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 2);
      expect(gamesPlayed.first, gamePlayed2);
      expect(gamesPlayed[1], gamePlayed1);

      gamesPlayed = await TimeBattleGamesPlayedDao(database: db).getByPlayedDay(testDateTime1);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 2);
      expect(gamesPlayed.first, gamePlayed2);
      expect(gamesPlayed[1], gamePlayed1);

      gamesPlayed = await TimeBattleGamesPlayedDao(database: db).getByPlayedDay(testDateTime2);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 2);
      expect(gamesPlayed.first, gamePlayed2);
      expect(gamesPlayed[1], gamePlayed1);

      gamesPlayed = await TimeBattleGamesPlayedDao(database: db).getByPlayedDay(testDateTime3);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed, isEmpty);

      gamesPlayed = await TimeBattleGamesPlayedDao(database: db).getByPlayedDateInRange(testDateTime1, testDateTime3);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 2);
      expect(gamesPlayed.first, gamePlayed2);
      expect(gamesPlayed[1], gamePlayed1);

      newestGamePlayed = await TimeBattleGamesPlayedDao(database: db).getNewest();
      expect(newestGamePlayed, isNotNull);
      expect(newestGamePlayed, gamePlayed2);

      highscoreGamePlayed =
          await TimeBattleGamesPlayedDao(database: db).getHighscoreGamePlayedByAnalyzedGamesBundleAndInitialTimeInSeconds(analyzedGamesBundle, initialTimeInSeconds1);
      expect(highscoreGamePlayed, isNotNull);
      expect(highscoreGamePlayed, gamePlayed2);

      highscoreGamePlayed =
          await TimeBattleGamesPlayedDao(database: db).getHighscoreGamePlayedByAnalyzedGamesBundleAndInitialTimeInSeconds(analyzedGamesBundle, initialTimeInSeconds2);
      expect(highscoreGamePlayed, isNotNull);
      expect(highscoreGamePlayed, gamePlayed2);

      highscoreGamePlayed =
          await TimeBattleGamesPlayedDao(database: db).getHighscoreGamePlayedByAnalyzedGamesBundleAndInitialTimeInSeconds(analyzedGamesBundle, initialTimeInSeconds3);
      expect(highscoreGamePlayed, isNull);

      // Inserts third game played
      await TimeBattleGamesPlayedDao(database: db).insert(gamePlayed3);

      // Test retrieving all three games played

      gamesPlayed = await TimeBattleGamesPlayedDao(database: db).getAll();
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed!.length, 3);
      expect(gamesPlayed.first, gamePlayed3);
      expect(gamesPlayed[1], gamePlayed2);
      expect(gamesPlayed[2], gamePlayed1);

      gamesPlayed = await TimeBattleGamesPlayedDao(database: db).getByAnalyzedGamesBundleAndInitialTimeInSeconds(analyzedGamesBundle, initialTimeInSeconds1);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 2);
      expect(gamesPlayed.first, gamePlayed2);
      expect(gamesPlayed[1], gamePlayed1);

      gamesPlayed = await TimeBattleGamesPlayedDao(database: db).getByAnalyzedGamesBundleAndInitialTimeInSeconds(analyzedGamesBundle, initialTimeInSeconds2);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 2);
      expect(gamesPlayed.first, gamePlayed2);
      expect(gamesPlayed[1], gamePlayed1);

      gamesPlayed = await TimeBattleGamesPlayedDao(database: db).getByAnalyzedGamesBundleAndInitialTimeInSeconds(analyzedGamesBundle, initialTimeInSeconds3);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 1);
      expect(gamesPlayed.first, gamePlayed3);

      gamesPlayed = await TimeBattleGamesPlayedDao(database: db).getByGrandmaster(grandmaster);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 3);
      expect(gamesPlayed[0], gamePlayed3);
      expect(gamesPlayed[1], gamePlayed2);
      expect(gamesPlayed[2], gamePlayed1);

      gamesPlayed = await TimeBattleGamesPlayedDao(database: db).getByPlayedDay(testDateTime1);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 2);
      expect(gamesPlayed.first, gamePlayed2);
      expect(gamesPlayed[1], gamePlayed1);

      gamesPlayed = await TimeBattleGamesPlayedDao(database: db).getByPlayedDay(testDateTime2);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 2);
      expect(gamesPlayed.first, gamePlayed2);
      expect(gamesPlayed[1], gamePlayed1);

      gamesPlayed = await TimeBattleGamesPlayedDao(database: db).getByPlayedDay(testDateTime3);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 1);
      expect(gamesPlayed.first, gamePlayed3);

      gamesPlayed = await TimeBattleGamesPlayedDao(database: db).getByPlayedDateInRange(testDateTime1, testDateTime3);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 3);
      expect(gamesPlayed[0], gamePlayed3);
      expect(gamesPlayed[1], gamePlayed2);
      expect(gamesPlayed[2], gamePlayed1);

      gamesPlayed = await TimeBattleGamesPlayedDao(database: db).getByPlayedDateInRange(testDateTime1, testDateTime2);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 2);
      expect(gamesPlayed[0], gamePlayed2);
      expect(gamesPlayed[1], gamePlayed1);

      newestGamePlayed = await TimeBattleGamesPlayedDao(database: db).getNewest();
      expect(newestGamePlayed, isNotNull);
      expect(newestGamePlayed, gamePlayed3);

      highscoreGamePlayed =
          await TimeBattleGamesPlayedDao(database: db).getHighscoreGamePlayedByAnalyzedGamesBundleAndInitialTimeInSeconds(analyzedGamesBundle, initialTimeInSeconds1);
      expect(highscoreGamePlayed, isNotNull);
      expect(highscoreGamePlayed, gamePlayed2);

      highscoreGamePlayed =
          await TimeBattleGamesPlayedDao(database: db).getHighscoreGamePlayedByAnalyzedGamesBundleAndInitialTimeInSeconds(analyzedGamesBundle, initialTimeInSeconds2);
      expect(highscoreGamePlayed, isNotNull);
      expect(highscoreGamePlayed, gamePlayed2);

      highscoreGamePlayed =
          await TimeBattleGamesPlayedDao(database: db).getHighscoreGamePlayedByAnalyzedGamesBundleAndInitialTimeInSeconds(analyzedGamesBundle, initialTimeInSeconds3);
      expect(highscoreGamePlayed, isNotNull);
      expect(highscoreGamePlayed, gamePlayed3);

      // Delete all games played
      await TimeBattleGamesPlayedDao(database: db).deleteAll();

      // Test that we can not retrieve any games played anymore

      gamesPlayed = await TimeBattleGamesPlayedDao(database: db).getAll();
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed, isEmpty);

      gamesPlayed = await TimeBattleGamesPlayedDao(database: db).getByAnalyzedGamesBundleAndInitialTimeInSeconds(analyzedGamesBundle, initialTimeInSeconds1);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed, isEmpty);

      gamesPlayed = await TimeBattleGamesPlayedDao(database: db).getByAnalyzedGamesBundleAndInitialTimeInSeconds(analyzedGamesBundle, initialTimeInSeconds2);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed, isEmpty);

      gamesPlayed = await TimeBattleGamesPlayedDao(database: db).getByAnalyzedGamesBundleAndInitialTimeInSeconds(analyzedGamesBundle, initialTimeInSeconds3);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed, isEmpty);

      gamesPlayed = await TimeBattleGamesPlayedDao(database: db).getByGrandmaster(grandmaster);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed, isEmpty);

      gamesPlayed = await TimeBattleGamesPlayedDao(database: db).getByPlayedDay(testDateTime1);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed, isEmpty);

      gamesPlayed = await TimeBattleGamesPlayedDao(database: db).getByPlayedDay(testDateTime2);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed, isEmpty);

      gamesPlayed = await TimeBattleGamesPlayedDao(database: db).getByPlayedDay(testDateTime3);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed, isEmpty);

      gamesPlayed = await TimeBattleGamesPlayedDao(database: db).getByPlayedDateInRange(testDateTime1, testDateTime3);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed, isEmpty);

      newestGamePlayed = await TimeBattleGamesPlayedDao(database: db).getNewest();
      expect(newestGamePlayed, isNull);

      highscoreGamePlayed =
          await TimeBattleGamesPlayedDao(database: db).getHighscoreGamePlayedByAnalyzedGamesBundleAndInitialTimeInSeconds(analyzedGamesBundle, initialTimeInSeconds1);
      expect(highscoreGamePlayed, isNull);

      highscoreGamePlayed =
          await TimeBattleGamesPlayedDao(database: db).getHighscoreGamePlayedByAnalyzedGamesBundleAndInitialTimeInSeconds(analyzedGamesBundle, initialTimeInSeconds2);
      expect(highscoreGamePlayed, isNull);

      highscoreGamePlayed =
          await TimeBattleGamesPlayedDao(database: db).getHighscoreGamePlayedByAnalyzedGamesBundleAndInitialTimeInSeconds(analyzedGamesBundle, initialTimeInSeconds3);
      expect(highscoreGamePlayed, isNull);
    });
  });
}
