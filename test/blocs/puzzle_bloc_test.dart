import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guess_the_move/bloc/points_bloc.dart';
import 'package:guess_the_move/bloc/puzzle_bloc.dart';
import 'package:guess_the_move/model/analyzed_games_bundle.dart';
import 'package:guess_the_move/model/player.dart';
import 'package:guess_the_move/model/points.dart';
import 'package:guess_the_move/model/user_settings.dart';
import 'package:guess_the_move/repository/analyzed_games_repository.dart';
import 'package:guess_the_move/repository/dao/points_dao.dart';
import 'package:guess_the_move/repository/players_and_bundles_repository.dart';
import 'package:guess_the_move/screens/game_modes/components/chess_board/chessboard_model.dart';
import 'package:guess_the_move/screens/game_modes/puzzle/components/puzzle_timer.dart';
import 'package:sembast/sembast.dart';

import '../dao/utils/test_database_provider.dart';

const timeNeededToGuessMove = 10000;

class ChessBoardControllerMock extends ChessBoardController {
  ChessBoardHasNext? hasNext = () => true;
  ChessBoardHasPrevious? hasPrevious = () => true;
  ChessBoardForward? forward = () {};
  ChessBoardBackward? backward = () {};
  ChessBoardMakeMove? makeMove = (_) {};
  ChessBoardUndoLastMove? undoLastMove = () {};
  ChessBoardShowMoveArrow? showMoveArrow = (_) {};
  ChessBoardRemoveMoveArrow? removeMoveArrow = () {};
  ChessBoardGetNextPly? getNextPly = () => 0;
  ChessBoardGetChessMoveFromSan? getChessMoveFromSan;
  ChessBoardGetLibraryBoard? getLibraryBoard;
  ChessBoardReset? reset = () {};
}

class PuzzleTimerControllerMock extends PuzzleTimerController {
  PuzzleTimerGetTimePassedInMilliseconds? getTimePassedInMilliseconds = () => timeNeededToGuessMove;
  PuzzleTimerPause? pause = () {};
  PuzzleTimerResume? resume = () {};
}

// Run tests with 'flutter test ./test/blocs/puzzle_bloc_test.dart' from main app directory

void main() async {
  /* ------------------------------------------------------------------------------------------------*/
  /*                                            SETUP                                                */
  /* ------------------------------------------------------------------------------------------------*/

  TestWidgetsFlutterBinding.ensureInitialized();

  final grandmaster = Player('Carlsen, Magnus', '-');
  final analyzedGamesBundle =
      (await getAnalyzedGamesBundlesForGrandmaster(grandmaster)).firstWhere((bundle) => bundle is AnalyzedGamesBundleByGrandmasterAndYear && bundle.year == 2020);
  final analyzedGamesInBundle = await loadAnalyzedGamesInBundle(analyzedGamesBundle);

  final puzzleTimerController = PuzzleTimerControllerMock();
  final chessBoardController = ChessBoardControllerMock();

  final testDbPath = 'puzzleblocpointstest.db';

  final dbProvider = TestDatabaseProvider();
  late Database testDb;

  setUp(() async {
    testDb = await dbProvider.open(testDbPath);
    await PointsDao(database: testDb).insert(initialPoints);
  });

  tearDown(() async {
    await testDb.close();
    await dbProvider.delete(testDbPath);
  });

  debugPrint('Running Puzzle bloc tests..');

  var error;
  final handleError = (e, stack) {
    error = e;
    // Uncomment to show errors in log
    // debugPrint(e.toString());
    // debugPrintStack(stackTrace: stack);
  };

  final initialState = PuzzleBloc.buildNewPuzzleState(analyzedGamesBundle, analyzedGamesInBundle, []);

  /* ------------------------------------------------------------------------------------------------*/
  /*                                       TESTS FOR SETUP                                           */
  /* ------------------------------------------------------------------------------------------------*/
  group("bloc utils tests", () {
    test('Magnus Carlsen 2020 bundle has valid puzzle states contained', () {
      expect(PuzzleBloc.hasPuzzle(analyzedGamesInBundle), isTrue);
    });

    test('Magnus Carlsen 2020 bundle delivers valid initial state', () {
      expect(initialState, isNotNull);
    });
  });

  group("bloc test", () {
    /* ------------------------------------------------------------------------------------------------*/
    /*                                       MATCHERS AND UTILS                                        */
    /* ------------------------------------------------------------------------------------------------*/

    Matcher _getGuessingMoveMatcher(
      final bool isNewPuzzle,
      final bool wasAlreadySolved,
      final int wrongTries,
      final bool showPieceTypeTipUsed,
      final bool showActualPieceTipUsed,
      final bool showActualMoveTipUsed,
    ) {
      return isA<PuzzleGuessMove>()
          .having((state) => state.isNewPuzzle, 'Is new puzzle', isNewPuzzle)
          .having((state) => state.wasAlreadySolved, 'Was already solved', wasAlreadySolved)
          .having((state) => state.wrongTries, 'Wrong tries', wrongTries)
          .having((state) => state.showPieceTypeTipUsed, 'Show piece type tip used', showPieceTypeTipUsed)
          .having((state) => state.showActualPieceTipUsed, 'Show actual piece tip used', showActualPieceTipUsed)
          .having((state) => state.showActualMoveTipUsed, 'Show actual move tip used', showActualMoveTipUsed);
    }

    Matcher _getCorrectMoveMatcher(
      final bool wasAlreadySolved,
      final int wrongTries,
      final bool showPieceTypeTipUsed,
      final bool showActualPieceTipUsed,
      final bool showActualMoveTipUsed,
      final int pointsGiven,
      final String playedMove,
      final int timeNeededInMilliseconds,
    ) {
      return isA<PuzzleCorrectMove>()
          .having((state) => state.wasAlreadySolved, 'Was already solved', wasAlreadySolved)
          .having((state) => state.wrongTries, 'Wrong tries', wrongTries)
          .having((state) => state.showPieceTypeTipUsed, 'Show piece type tip used', showPieceTypeTipUsed)
          .having((state) => state.showActualPieceTipUsed, 'Show actual piece tip used', showActualPieceTipUsed)
          .having((state) => state.showActualMoveTipUsed, 'Show actual move tip used', showActualMoveTipUsed)
          .having((state) => state.pointsGiven, 'Points given', pointsGiven)
          .having((state) => state.playedMove, 'Played move', playedMove)
          .having((state) => state.timeNeededInMilliseconds, 'Time needed in milliseconds', timeNeededInMilliseconds);
    }

    Matcher _getWrongMoveMatcher(
      final bool wasAlreadySolved,
      final int wrongTries,
      final bool showPieceTypeTipUsed,
      final bool showActualPieceTipUsed,
      final bool showActualMoveTipUsed,
      final String playedMove,
    ) {
      return isA<PuzzleWrongMove>()
          .having((state) => state.wasAlreadySolved, 'Was already solved', wasAlreadySolved)
          .having((state) => state.wrongTries, 'Wrong tries', wrongTries)
          .having((state) => state.showPieceTypeTipUsed, 'Show piece type tip used', showPieceTypeTipUsed)
          .having((state) => state.showActualPieceTipUsed, 'Show actual piece tip used', showActualPieceTipUsed)
          .having((state) => state.showActualMoveTipUsed, 'Show actual move tip used', showActualMoveTipUsed)
          .having((state) => state.playedMove, 'Played move', playedMove);
    }

    Matcher _getSummaryMatcher(final int puzzlesPlayedAmount) {
      return isA<PuzzleGameOver>().having((state) => state.puzzlesPlayed.length, 'Puzzles played amount', puzzlesPlayedAmount);
    }

    Future<void> _waitForPointsUpdate(final int amount) async {
      // wait for points bloc to add received points to database
      while ((await PointsDao(database: testDb).get()).amount != amount) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }

    Future<void> _setPoints(final int amount) async {
      await PointsDao(database: testDb).update(Points(amount));
      await _waitForPointsUpdate(amount);
    }

    final _buildPuzzleBloc = () {
      final bloc = PuzzleBloc(
        initialState!,
        puzzleTimerController,
        chessBoardController,
        analyzedGamesBundle,
        analyzedGamesInBundle,
        initialUserSettings,
        handleError: handleError,
        database: testDb,
      );
      return bloc;
    };

    /* ------------------------------------------------------------------------------------------------*/
    /*                                      SINGLE PUZZLE TESTS                                        */
    /* ------------------------------------------------------------------------------------------------*/

    test('Verify initial state is correct guessing state', () {
      expect(initialState, _getGuessingMoveMatcher(true, false, 0, false, false, false));
    });

    var puzzleGuessState;

    blocTest(
      'PuzzleBloc guess correct immediately',
      build: _buildPuzzleBloc,
      act: (final PuzzleBloc bloc) {
        puzzleGuessState = bloc.state;
        bloc.add(PuzzlePlayMoveEvent((bloc.state as PuzzleGuessMove).puzzleMove.actualMove.move.san, PointsBloc(database: testDb)));
      },
      expect: () => [
        _getCorrectMoveMatcher(
          true,
          0,
          false,
          false,
          false,
          PuzzleBloc.maxPointsForCorrectPuzzleMove,
          (puzzleGuessState as PuzzleGuessMove).puzzleMove.actualMove.move.san,
          timeNeededToGuessMove,
        )
      ],
      verify: (_) async {
        // wait for points bloc to add received points to database
        while ((await PointsDao(database: testDb).get()).amount == 0) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
        expect((await PointsDao(database: testDb).get()).amount, PuzzleBloc.maxPointsForCorrectPuzzleMove);
      },
    );

    blocTest(
      'PuzzleBloc guess correct after trying to reveal one tip but we do not have enough points for it',
      build: _buildPuzzleBloc,
      act: (final PuzzleBloc bloc) {
        puzzleGuessState = bloc.state;
        bloc.add(PuzzleShowNextTipEvent(null, PointsBloc(database: testDb)));
        bloc.add(PuzzlePlayMoveEvent((bloc.state as PuzzleGuessMove).puzzleMove.actualMove.move.san, PointsBloc(database: testDb)));
      },
      expect: () => [
        _getGuessingMoveMatcher(true, false, 0, false, false, false),
        _getCorrectMoveMatcher(
          true,
          0,
          false,
          false,
          false,
          PuzzleBloc.maxPointsForCorrectPuzzleMove,
          (puzzleGuessState as PuzzleGuessMove).puzzleMove.actualMove.move.san,
          timeNeededToGuessMove,
        )
      ],
      verify: (_) async {
        // wait for points bloc to add received points to database
        while ((await PointsDao(database: testDb).get()).amount == 0) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
        expect((await PointsDao(database: testDb).get()).amount, PuzzleBloc.maxPointsForCorrectPuzzleMove);
      },
    );

    blocTest(
      'PuzzleBloc guess correct after revealing one tip',
      build: _buildPuzzleBloc,
      act: (final PuzzleBloc bloc) async {
        puzzleGuessState = bloc.state;

        await _setPoints(PuzzleBloc.buyNextTipPrice);

        bloc.add(PuzzleShowNextTipEvent(null, PointsBloc(database: testDb, initialPoints: PuzzleBloc.buyNextTipPrice)));
        bloc.add(PuzzlePlayMoveEvent((bloc.state as PuzzleGuessMove).puzzleMove.actualMove.move.san, PointsBloc(database: testDb, initialPoints: 0)));
      },
      expect: () => [
        _getGuessingMoveMatcher(true, false, 0, true, false, false),
        _getCorrectMoveMatcher(
          true,
          0,
          true,
          false,
          false,
          PuzzleBloc.maxPointsForCorrectPuzzleMove,
          (puzzleGuessState as PuzzleGuessMove).puzzleMove.actualMove.move.san,
          timeNeededToGuessMove,
        )
      ],
      verify: (_) async {
        // wait for points bloc to add received points to database
        while ((await PointsDao(database: testDb).get()).amount == 0) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
        expect((await PointsDao(database: testDb).get()).amount, PuzzleBloc.maxPointsForCorrectPuzzleMove);
      },
    );

    /* ------------------------------------------------------------------------------------------------*/
    /*                                   MULTIPLE PUZZLES TESTS                                        */
    /* ------------------------------------------------------------------------------------------------*/

    List<String> movesPlayedSanList = [];

    var currentPuzzleMove;
    var alternativeMoves;
    var wrongMoveSan;
    var correctMoveSan;

    Future<int> _playPuzzle(final PuzzleBloc bloc, final int initialPoints, final int wrongTriesAmount, final bool endWithCorrectTry, final bool revealAllTipsInCorrectTry) async {
      currentPuzzleMove = (bloc.state as PuzzleGuessMove).puzzleMove;
      alternativeMoves = currentPuzzleMove.alternativeMoves;
      wrongMoveSan = alternativeMoves.isNotEmpty ? alternativeMoves.first.move.san : 'wrong-move-san';
      correctMoveSan = currentPuzzleMove.actualMove.move.san;

      for (var i = 0; i < wrongTriesAmount; i++) {
        if (i > 0) {
          bloc.add(PuzzleRetryCurrentPuzzleEvent());
        }

        movesPlayedSanList.add(wrongMoveSan);
        bloc.add(PuzzlePlayMoveEvent(wrongMoveSan, PointsBloc(database: testDb, initialPoints: initialPoints)));
      }

      if (endWithCorrectTry) {
        if (wrongTriesAmount > 0) {
          bloc.add(PuzzleRetryCurrentPuzzleEvent());
        }

        if (revealAllTipsInCorrectTry) {
          bloc.add(PuzzleShowNextTipEvent(null, PointsBloc(database: testDb, initialPoints: initialPoints)));
          await _waitForPointsUpdate(initialPoints - 1 * PuzzleBloc.buyNextTipPrice);
          bloc.add(PuzzleShowNextTipEvent(null, PointsBloc(database: testDb, initialPoints: initialPoints - 1 * PuzzleBloc.buyNextTipPrice)));
          await _waitForPointsUpdate(initialPoints - 2 * PuzzleBloc.buyNextTipPrice);
          bloc.add(PuzzleShowNextTipEvent(null, PointsBloc(database: testDb, initialPoints: initialPoints - 2 * PuzzleBloc.buyNextTipPrice)));
          await _waitForPointsUpdate(initialPoints - 3 * PuzzleBloc.buyNextTipPrice);
        }

        final currentPoints = revealAllTipsInCorrectTry ? initialPoints - 3 * PuzzleBloc.buyNextTipPrice : initialPoints;

        movesPlayedSanList.add(correctMoveSan);
        bloc.add(
          PuzzlePlayMoveEvent(
            correctMoveSan,
            PointsBloc(database: testDb, initialPoints: currentPoints),
          ),
        );

        final newPoints = currentPoints + PuzzleBloc.maxPointsForCorrectPuzzleMove - wrongTriesAmount * PuzzleBloc.discountPointsForWrongTry;
        await _waitForPointsUpdate(newPoints);

        return newPoints;
      }

      return initialPoints;
    }

    Future<void> _showNextPuzzle(final PuzzleBloc bloc) async {
      bloc.add(PuzzleShowNextPuzzleEvent());

      // wait for new puzzle state
      while (!(bloc.state is PuzzleGuessMove) || (bloc.state as PuzzleGuessMove).puzzleMove == currentPuzzleMove) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }

    List<Matcher> _getPuzzleMatchers(final int indexOffset, final int wrongTriesAmount, final bool endWithCorrectTry, final bool revealAllTipsInCorrectTry) {
      List<Matcher> puzzleMatchers = [];

      for (var i = 0; i < wrongTriesAmount; i++) {
        if (i > 0) {
          puzzleMatchers.add(
            _getGuessingMoveMatcher(false, false, i, false, false, false),
          );
        }
        puzzleMatchers.add(
          _getWrongMoveMatcher(
            false,
            i + 1,
            false,
            false,
            false,
            movesPlayedSanList[indexOffset + i],
          ),
        );
      }

      if (endWithCorrectTry) {
        if (wrongTriesAmount > 0) {
          puzzleMatchers.add(
            _getGuessingMoveMatcher(false, false, wrongTriesAmount, false, false, false),
          );
        }

        if (revealAllTipsInCorrectTry) {
          puzzleMatchers.addAll([
            _getGuessingMoveMatcher(wrongTriesAmount == 0, false, wrongTriesAmount, true, false, false),
            _getGuessingMoveMatcher(wrongTriesAmount == 0, false, wrongTriesAmount, true, true, false),
            _getGuessingMoveMatcher(wrongTriesAmount == 0, false, wrongTriesAmount, true, true, true),
          ]);
        }

        puzzleMatchers.add(
          _getCorrectMoveMatcher(
            true,
            wrongTriesAmount,
            revealAllTipsInCorrectTry,
            revealAllTipsInCorrectTry,
            revealAllTipsInCorrectTry,
            PuzzleBloc.maxPointsForCorrectPuzzleMove - PuzzleBloc.discountPointsForWrongTry * wrongTriesAmount,
            movesPlayedSanList[indexOffset + wrongTriesAmount],
            timeNeededToGuessMove,
          ),
        );
      }

      return puzzleMatchers;
    }

    blocTest(
      'PuzzleBloc guess correct after revealing all tips',
      build: _buildPuzzleBloc,
      act: (final PuzzleBloc bloc) async {
        movesPlayedSanList = [];
        await _setPoints(PuzzleBloc.buyNextTipPrice * 3);
        await _playPuzzle(bloc, PuzzleBloc.buyNextTipPrice * 3, 0, true, true);
      },
      expect: () => _getPuzzleMatchers(0, 0, true, true),
      verify: (_) async {
        expect((await PointsDao(database: testDb).get()).amount, PuzzleBloc.maxPointsForCorrectPuzzleMove);
      },
    );

    blocTest(
      'PuzzleBloc guess wrong, retry and then guess correct',
      build: _buildPuzzleBloc,
      act: (final PuzzleBloc bloc) async {
        await _setPoints(0);
        movesPlayedSanList = [];
        await _playPuzzle(bloc, 0, 1, true, false);
      },
      expect: () => _getPuzzleMatchers(0, 1, true, false),
      verify: (_) async {
        expect((await PointsDao(database: testDb).get()).amount, PuzzleBloc.maxPointsForCorrectPuzzleMove - PuzzleBloc.discountPointsForWrongTry * 1);
      },
    );

    blocTest(
      'PuzzleBloc guess wrong two times, retry, use all three tips and then guess correct',
      build: _buildPuzzleBloc,
      act: (final PuzzleBloc bloc) async {
        final currentPoints = 3 * PuzzleBloc.buyNextTipPrice;
        await _setPoints(currentPoints);
        movesPlayedSanList = [];
        await _playPuzzle(bloc, currentPoints, 2, true, true);
      },
      expect: () => _getPuzzleMatchers(0, 2, true, true),
      verify: (_) async {
        expect(
          (await PointsDao(database: testDb).get()).amount,
          PuzzleBloc.maxPointsForCorrectPuzzleMove - PuzzleBloc.discountPointsForWrongTry * 2,
        );
      },
    );

    blocTest(
      'PuzzleBloc play four puzzles and end game',
      build: _buildPuzzleBloc,
      act: (final PuzzleBloc bloc) async {
        await _setPoints(0);

        movesPlayedSanList = [];

        var currentPoints = 0;

        currentPoints = await _playPuzzle(bloc, currentPoints, 2, true, false);
        await _showNextPuzzle(bloc);
        currentPoints = await _playPuzzle(bloc, currentPoints, 1, true, false);
        await _showNextPuzzle(bloc);
        currentPoints = await _playPuzzle(bloc, currentPoints, 3, true, true);
        await _showNextPuzzle(bloc);
        currentPoints = await _playPuzzle(bloc, currentPoints, 1, false, false);

        bloc.add(PuzzleEndGameEvent());
      },
      expect: () => [
        ..._getPuzzleMatchers(0, 2, true, false),
        _getGuessingMoveMatcher(true, false, 0, false, false, false),
        ..._getPuzzleMatchers(3, 1, true, false),
        _getGuessingMoveMatcher(true, false, 0, false, false, false),
        ..._getPuzzleMatchers(5, 3, true, true),
        _getGuessingMoveMatcher(true, false, 0, false, false, false),
        ..._getPuzzleMatchers(9, 1, false, false),
        _getSummaryMatcher(4),
      ],
      verify: (_) async {
        expect(
          (await PointsDao(database: testDb).get()).amount,
          3 * PuzzleBloc.maxPointsForCorrectPuzzleMove - 6 * PuzzleBloc.discountPointsForWrongTry - 3 * PuzzleBloc.buyNextTipPrice,
        );
      },
    );

    blocTest(
      'PuzzleBloc play two puzzles and retry second puzzle after it has already been solved',
      build: _buildPuzzleBloc,
      act: (final PuzzleBloc bloc) async {
        await _setPoints(0);

        movesPlayedSanList = [];

        var currentPoints = 0;

        currentPoints = await _playPuzzle(bloc, currentPoints, 2, true, false);
        await _showNextPuzzle(bloc);
        currentPoints = await _playPuzzle(bloc, currentPoints, 1, true, true);

        bloc.add(PuzzleRetryCurrentPuzzleEvent());

        var correctMove = movesPlayedSanList.last;
        movesPlayedSanList.add(correctMove);
        bloc.add(PuzzlePlayMoveEvent(correctMove, PointsBloc(database: testDb, initialPoints: 40)));

        bloc.add(PuzzleEndGameEvent());
      },
      expect: () => [
        ..._getPuzzleMatchers(0, 2, true, false),
        _getGuessingMoveMatcher(true, false, 0, false, false, false),
        ..._getPuzzleMatchers(3, 1, true, true),
        _getGuessingMoveMatcher(false, true, 1, true, true, true),
        _getCorrectMoveMatcher(true, 1, true, true, true, 0, movesPlayedSanList.last, timeNeededToGuessMove),
        _getSummaryMatcher(2),
      ],
      verify: (_) async {
        expect(
          (await PointsDao(database: testDb).get()).amount,
          2 * PuzzleBloc.maxPointsForCorrectPuzzleMove - 3 * PuzzleBloc.discountPointsForWrongTry - 3 * PuzzleBloc.buyNextTipPrice,
        );
      },
    );
  });
}
