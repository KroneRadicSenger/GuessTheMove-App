import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guess_the_move/bloc/puzzle_bloc.dart';
import 'package:guess_the_move/model/analyzed_game.dart';
import 'package:guess_the_move/model/analyzed_games_bundle.dart';
import 'package:guess_the_move/model/game_played_info.dart';
import 'package:guess_the_move/model/player.dart';
import 'package:guess_the_move/model/puzzle_game_played.dart';
import 'package:guess_the_move/repository/analyzed_games_repository.dart';
import 'package:guess_the_move/repository/dao/puzzle_games_played_dao.dart';
import 'package:guess_the_move/repository/players_and_bundles_repository.dart';
import 'package:sembast/sembast.dart';

import 'utils/test_database_provider.dart';

const testDatabasePath = 'test/dao/db/puzzlegamesplayeddaotest.db';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final random = Random();

  group('PuzzleGamesPlayedDao test', () {
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
      analyzedGamesBundle =
          (await getAnalyzedGamesBundlesForGrandmaster(grandmaster)).firstWhere((bundle) => bundle is AnalyzedGamesBundleByGrandmasterAndYear && bundle.year == 2020);
      analyzedGamesInBundle = await loadAnalyzedGamesInBundle(analyzedGamesBundle);
    });

    tearDown(() async {
      await db.close();
      return dbProvider.delete(testDatabasePath);
    });

    debugPrint('Running PuzzleGamesPlayedDao tests..');

    test('no data is retrieved before inserting data', () async {
      var gamesPlayed = await PuzzleGamesPlayedDao(database: db).getAll();
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed, isEmpty);

      gamesPlayed = await PuzzleGamesPlayedDao(database: db).getByAnalyzedGamesBundle(analyzedGamesBundle);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed, isEmpty);

      gamesPlayed = await PuzzleGamesPlayedDao(database: db).getByGrandmaster(grandmaster);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed, isEmpty);

      gamesPlayed = await PuzzleGamesPlayedDao(database: db).getByPlayedDay(testDateTime1);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed, isEmpty);

      gamesPlayed = await PuzzleGamesPlayedDao(database: db).getByPlayedDay(testDateTime2);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed, isEmpty);

      gamesPlayed = await PuzzleGamesPlayedDao(database: db).getByPlayedDay(testDateTime3);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed, isEmpty);

      gamesPlayed = await PuzzleGamesPlayedDao(database: db).getByPlayedDateInRange(testDateTime1, testDateTime3);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed, isEmpty);

      final newestGamePlayed = await PuzzleGamesPlayedDao(database: db).getNewest();
      expect(newestGamePlayed, isNull);

      var highscoreGamePlayed = await PuzzleGamesPlayedDao(database: db).getHighscoreGamePlayedByAnalyzedGamesBundle(analyzedGamesBundle);
      expect(highscoreGamePlayed, isNull);
    });

    test('insert and retrieve games played', () async {
      var gamePlayed1Puzzle1State = PuzzleBloc.buildNewPuzzleState(analyzedGamesBundle, analyzedGamesInBundle, []);
      var gamePlayed1Puzzle2State = PuzzleBloc.buildNewPuzzleState(analyzedGamesBundle, analyzedGamesInBundle, [gamePlayed1Puzzle1State!]);
      var gamePlayed1Puzzle3State = PuzzleBloc.buildNewPuzzleState(analyzedGamesBundle, analyzedGamesInBundle, [gamePlayed1Puzzle1State, gamePlayed1Puzzle2State!]);

      var allPuzzleStates = [gamePlayed1Puzzle1State, gamePlayed1Puzzle2State, gamePlayed1Puzzle3State!];

      var gamePlayed2Puzzle1State = PuzzleBloc.buildNewPuzzleState(analyzedGamesBundle, analyzedGamesInBundle, allPuzzleStates);
      var gamePlayed2Puzzle2State = PuzzleBloc.buildNewPuzzleState(analyzedGamesBundle, analyzedGamesInBundle, [...allPuzzleStates, gamePlayed2Puzzle1State!]);

      allPuzzleStates = [...allPuzzleStates, gamePlayed2Puzzle1State, gamePlayed2Puzzle2State!];

      var gamePlayed3Puzzle1State = PuzzleBloc.buildNewPuzzleState(analyzedGamesBundle, analyzedGamesInBundle, allPuzzleStates);
      var gamePlayed3Puzzle2State = PuzzleBloc.buildNewPuzzleState(analyzedGamesBundle, analyzedGamesInBundle, [...allPuzzleStates, gamePlayed3Puzzle1State!]);

      PuzzleGamePlayed _mapPuzzleStatesToPuzzleGamePlayed(final List<PuzzleIngameState> puzzleStates, final DateTime playTime, final int totalPointsGivenAmount) {
        return PuzzleGamePlayed(
          grandmaster: grandmaster,
          analyzedGameOriginBundle: analyzedGamesBundle,
          totalPointsGivenAmount: totalPointsGivenAmount,
          playedDateTimestamp: playTime.millisecondsSinceEpoch,
          puzzlesPlayed: puzzleStates.map((puzzleState) {
            final tipsUsedAmount = random.nextInt(3);

            return PuzzlePlayed(
              analyzedGameId: puzzleState.analyzedGame.id,
              gamePlayedInfo: GamePlayedInfo(
                analyzedGameId: puzzleState.analyzedGame.id,
                whitePlayer: puzzleState.analyzedGame.whitePlayer,
                blackPlayer: puzzleState.analyzedGame.blackPlayer,
                whitePlayerRating: puzzleState.analyzedGame.whitePlayerRating,
                blackPlayerRating: puzzleState.analyzedGame.blackPlayerRating,
                grandmasterSide: puzzleState.analyzedGame.gameAnalysis.grandmasterSide,
                gameInfoString: puzzleState.analyzedGame.gameInfo.toString(),
              ),
              puzzleMove: puzzleState.puzzleMove,
              startTime: playTime,
              wrongTries: random.nextInt(10),
              wasAlreadySolved: random.nextBool(),
              showPieceTypeTipUsed: tipsUsedAmount > 0,
              showActualPieceTipUsed: tipsUsedAmount > 1,
              showActualMoveTipUsed: tipsUsedAmount > 2,
            );
          }).toList(),
        );
      }

      final gamePlayed1 = _mapPuzzleStatesToPuzzleGamePlayed(
        [gamePlayed1Puzzle1State, gamePlayed1Puzzle2State, gamePlayed1Puzzle3State],
        testDateTime1,
        1000,
      );

      final gamePlayed2 = _mapPuzzleStatesToPuzzleGamePlayed(
        [gamePlayed2Puzzle1State, gamePlayed2Puzzle2State],
        testDateTime2,
        2000,
      );

      final gamePlayed3 = _mapPuzzleStatesToPuzzleGamePlayed(
        [gamePlayed3Puzzle1State, gamePlayed3Puzzle2State!],
        testDateTime3,
        1200,
      );

      // Inserts first game played
      await PuzzleGamesPlayedDao(database: db).insert(gamePlayed1);

      // Test retrieving this first game played

      var gamesPlayed = await PuzzleGamesPlayedDao(database: db).getAll();
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed!.length, 1);
      expect(gamesPlayed.first, gamePlayed1);

      gamesPlayed = await PuzzleGamesPlayedDao(database: db).getByAnalyzedGamesBundle(analyzedGamesBundle);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 1);
      expect(gamesPlayed[0], gamePlayed1);

      gamesPlayed = await PuzzleGamesPlayedDao(database: db).getByGrandmaster(grandmaster);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 1);
      expect(gamesPlayed[0], gamePlayed1);

      gamesPlayed = await PuzzleGamesPlayedDao(database: db).getByPlayedDay(testDateTime1);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 1);
      expect(gamesPlayed.first, gamePlayed1);

      gamesPlayed = await PuzzleGamesPlayedDao(database: db).getByPlayedDay(testDateTime2);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 1);
      expect(gamesPlayed.first, gamePlayed1);

      gamesPlayed = await PuzzleGamesPlayedDao(database: db).getByPlayedDay(testDateTime3);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed, isEmpty);

      gamesPlayed = await PuzzleGamesPlayedDao(database: db).getByPlayedDateInRange(testDateTime1, testDateTime3);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 1);
      expect(gamesPlayed.first, gamePlayed1);

      var newestGamePlayed = await PuzzleGamesPlayedDao(database: db).getNewest();
      expect(newestGamePlayed, isNotNull);
      expect(newestGamePlayed, gamePlayed1);

      var highscoreGamePlayed = await PuzzleGamesPlayedDao(database: db).getHighscoreGamePlayedByAnalyzedGamesBundle(analyzedGamesBundle);
      expect(highscoreGamePlayed, isNotNull);
      expect(highscoreGamePlayed, gamePlayed1);

      // Inserts second game played
      await PuzzleGamesPlayedDao(database: db).insert(gamePlayed2);

      // Test retrieving first and second game played

      gamesPlayed = await PuzzleGamesPlayedDao(database: db).getAll();
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed!.length, 2);
      expect(gamesPlayed.first, gamePlayed2);
      expect(gamesPlayed[1], gamePlayed1);

      gamesPlayed = await PuzzleGamesPlayedDao(database: db).getByAnalyzedGamesBundle(analyzedGamesBundle);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 2);
      expect(gamesPlayed.first, gamePlayed2);
      expect(gamesPlayed[1], gamePlayed1);

      gamesPlayed = await PuzzleGamesPlayedDao(database: db).getByGrandmaster(grandmaster);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 2);
      expect(gamesPlayed.first, gamePlayed2);
      expect(gamesPlayed[1], gamePlayed1);

      gamesPlayed = await PuzzleGamesPlayedDao(database: db).getByPlayedDay(testDateTime1);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 2);
      expect(gamesPlayed.first, gamePlayed2);
      expect(gamesPlayed[1], gamePlayed1);

      gamesPlayed = await PuzzleGamesPlayedDao(database: db).getByPlayedDay(testDateTime2);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 2);
      expect(gamesPlayed.first, gamePlayed2);
      expect(gamesPlayed[1], gamePlayed1);

      gamesPlayed = await PuzzleGamesPlayedDao(database: db).getByPlayedDay(testDateTime3);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed, isEmpty);

      gamesPlayed = await PuzzleGamesPlayedDao(database: db).getByPlayedDateInRange(testDateTime1, testDateTime3);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 2);
      expect(gamesPlayed.first, gamePlayed2);
      expect(gamesPlayed[1], gamePlayed1);

      newestGamePlayed = await PuzzleGamesPlayedDao(database: db).getNewest();
      expect(newestGamePlayed, isNotNull);
      expect(newestGamePlayed, gamePlayed2);

      highscoreGamePlayed = await PuzzleGamesPlayedDao(database: db).getHighscoreGamePlayedByAnalyzedGamesBundle(analyzedGamesBundle);
      expect(highscoreGamePlayed, isNotNull);
      expect(highscoreGamePlayed, gamePlayed2);

      // Inserts third game played
      await PuzzleGamesPlayedDao(database: db).insert(gamePlayed3);

      // Test retrieving all three games played

      gamesPlayed = await PuzzleGamesPlayedDao(database: db).getAll();
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed!.length, 3);
      expect(gamesPlayed.first, gamePlayed3);
      expect(gamesPlayed[1], gamePlayed2);
      expect(gamesPlayed[2], gamePlayed1);

      gamesPlayed = await PuzzleGamesPlayedDao(database: db).getByAnalyzedGamesBundle(analyzedGamesBundle);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 3);
      expect(gamesPlayed.first, gamePlayed3);
      expect(gamesPlayed[1], gamePlayed2);
      expect(gamesPlayed[2], gamePlayed1);

      gamesPlayed = await PuzzleGamesPlayedDao(database: db).getByGrandmaster(grandmaster);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 3);
      expect(gamesPlayed[0], gamePlayed3);
      expect(gamesPlayed[1], gamePlayed2);
      expect(gamesPlayed[2], gamePlayed1);

      gamesPlayed = await PuzzleGamesPlayedDao(database: db).getByPlayedDay(testDateTime1);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 2);
      expect(gamesPlayed.first, gamePlayed2);
      expect(gamesPlayed[1], gamePlayed1);

      gamesPlayed = await PuzzleGamesPlayedDao(database: db).getByPlayedDay(testDateTime2);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 2);
      expect(gamesPlayed.first, gamePlayed2);
      expect(gamesPlayed[1], gamePlayed1);

      gamesPlayed = await PuzzleGamesPlayedDao(database: db).getByPlayedDay(testDateTime3);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 1);
      expect(gamesPlayed.first, gamePlayed3);

      gamesPlayed = await PuzzleGamesPlayedDao(database: db).getByPlayedDateInRange(testDateTime1, testDateTime3);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 3);
      expect(gamesPlayed[0], gamePlayed3);
      expect(gamesPlayed[1], gamePlayed2);
      expect(gamesPlayed[2], gamePlayed1);

      gamesPlayed = await PuzzleGamesPlayedDao(database: db).getByPlayedDateInRange(testDateTime1, testDateTime2);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed.length, 2);
      expect(gamesPlayed[0], gamePlayed2);
      expect(gamesPlayed[1], gamePlayed1);

      newestGamePlayed = await PuzzleGamesPlayedDao(database: db).getNewest();
      expect(newestGamePlayed, isNotNull);
      expect(newestGamePlayed, gamePlayed3);

      highscoreGamePlayed = await PuzzleGamesPlayedDao(database: db).getHighscoreGamePlayedByAnalyzedGamesBundle(analyzedGamesBundle);
      expect(highscoreGamePlayed, isNotNull);
      expect(highscoreGamePlayed, gamePlayed2);

      // Delete all games played
      await PuzzleGamesPlayedDao(database: db).deleteAll();

      // Test that we can not retrieve any games played anymore

      gamesPlayed = await PuzzleGamesPlayedDao(database: db).getAll();
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed, isEmpty);

      gamesPlayed = await PuzzleGamesPlayedDao(database: db).getByAnalyzedGamesBundle(analyzedGamesBundle);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed, isEmpty);

      gamesPlayed = await PuzzleGamesPlayedDao(database: db).getByGrandmaster(grandmaster);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed, isEmpty);

      gamesPlayed = await PuzzleGamesPlayedDao(database: db).getByPlayedDay(testDateTime1);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed, isEmpty);

      gamesPlayed = await PuzzleGamesPlayedDao(database: db).getByPlayedDay(testDateTime2);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed, isEmpty);

      gamesPlayed = await PuzzleGamesPlayedDao(database: db).getByPlayedDay(testDateTime3);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed, isEmpty);

      gamesPlayed = await PuzzleGamesPlayedDao(database: db).getByPlayedDateInRange(testDateTime1, testDateTime3);
      expect(gamesPlayed, isNotNull);
      expect(gamesPlayed, isEmpty);

      newestGamePlayed = await PuzzleGamesPlayedDao(database: db).getNewest();
      expect(newestGamePlayed, isNull);

      highscoreGamePlayed = await PuzzleGamesPlayedDao(database: db).getHighscoreGamePlayedByAnalyzedGamesBundle(analyzedGamesBundle);
      expect(highscoreGamePlayed, isNull);
    });
  });
}
