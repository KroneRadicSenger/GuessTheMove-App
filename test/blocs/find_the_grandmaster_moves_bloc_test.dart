import 'dart:math';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guess_the_move/bloc/find_the_grandmaster_moves_bloc.dart';
import 'package:guess_the_move/bloc/points_bloc.dart';
import 'package:guess_the_move/model/analyzed_game.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/model/player.dart';
import 'package:guess_the_move/model/user_settings.dart';
import 'package:guess_the_move/repository/analyzed_games_repository.dart';
import 'package:guess_the_move/repository/dao/find_the_grandmaster_moves_games_played_dao.dart';
import 'package:guess_the_move/repository/dao/points_dao.dart';
import 'package:guess_the_move/repository/players_and_bundles_repository.dart';
import 'package:guess_the_move/screens/game_modes/components/chess_board/chessboard_model.dart';
import 'package:sembast/sembast.dart';

import '../dao/utils/test_database_provider.dart';

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

// Run tests with 'flutter test ./test/blocs/find_the_grandmaster_moves_bloc_test.dart' from main app directory

void main() async {
  /* ------------------------------------------------------------------------------------------------*/
  /*                                            SETUP                                                */
  /* ------------------------------------------------------------------------------------------------*/

  TestWidgetsFlutterBinding.ensureInitialized();

  final grandmaster = Player('Carlsen, Magnus', '-');
  final analyzedGamesBundle = (await getAnalyzedGamesBundlesForGrandmaster(grandmaster)).first;
  final analyzedGamesInBundle = await loadAnalyzedGamesInBundle(analyzedGamesBundle);

  int analyzedGameIndex = new Random().nextInt(analyzedGamesInBundle.length);
  final analyzedGame = analyzedGamesInBundle.elementAt(analyzedGameIndex);
  final gameMode = GameModeEnum.findTheGrandmasterMoves;
  final firstMove = analyzedGame.gameAnalysis.analyzedMoves.first;
  final chessBoardController = ChessBoardControllerMock();

  final initialState = FindTheGrandmasterMovesShowingOpening(analyzedGame, gameMode, analyzedGamesBundle, firstMove);

  final testDbPath = 'findthegrandmastermovesbloctest.db';

  final dbProvider = TestDatabaseProvider();
  late Database testDb;

  setUp(() async {
    testDb = await dbProvider.open(testDbPath);
  });

  tearDown(() async {
    await testDb.close();
    await dbProvider.delete(testDbPath);
  });

  debugPrint('Running FindTheGrandmasterMoves bloc tests..');

  var error;
  final handleError = (e, stack) {
    error = e;
    // Uncomment to show errors in log
    // debugPrint(e.toString());
    // debugPrintStack(stackTrace: stack);
  };

  final _buildFindTheGrandmasterMovesBloc = () {
    final bloc = FindTheGrandmasterMovesBloc(
      initialState,
      gameMode,
      chessBoardController,
      initialUserSettings,
      handleError: handleError,
      database: testDb,
    );
    bloc.screenStateHistory.add(initialState);
    return bloc;
  };

  debugPrint('Game: ${analyzedGame.id}');

  group("bloc test", () {
    /* ------------------------------------------------------------------------------------------------*/
    /*                                       OPENING TESTS                                             */
    /* ------------------------------------------------------------------------------------------------*/

    test('FindTheGrandmasterMovesBloc throws Exception when going back in first state', () async {
      final testBloc = _buildFindTheGrandmasterMovesBloc();
      testBloc.add(FindTheGrandmasterMovesGoToPreviousStateEvent());
      await Future.delayed(const Duration(seconds: 2), () {});
      expect(error, isA<StateError>());
      error = null;
    });

    Matcher _getOpeningMoveMatcher(final int ply, final bool isLastOpeningMove) {
      return isA<FindTheGrandmasterMovesShowingOpening>()
          .having((state) => state.move.ply, 'Opening move ply', ply)
          .having((state) => state.isLastOpeningMove(), 'Is last opening move', isLastOpeningMove);
    }

    final openingMovesLength = analyzedGame.gameAnalysis.opening.moves.split(' ').length;

    int _goForwardToLastOpeningState(final FindTheGrandmasterMovesBloc bloc, final int currentPly) {
      final int stepsForward = openingMovesLength - 1 - currentPly;
      for (var i = 0; i < stepsForward; i++) {
        bloc.add(FindTheGrandmasterMovesGoToNextStateEvent());
      }
      return currentPly + stepsForward;
    }

    int _goBackToFirstState(final FindTheGrandmasterMovesBloc bloc, final int currentPly) {
      for (var i = 0; i < currentPly; i++) {
        bloc.add(FindTheGrandmasterMovesGoToPreviousStateEvent());
      }
      return 0;
    }

    if (openingMovesLength >= 2) {
      blocTest(
        'FindTheGrandmasterMovesBloc go to second opening state',
        build: _buildFindTheGrandmasterMovesBloc,
        act: (final FindTheGrandmasterMovesBloc bloc) {
          bloc.add(FindTheGrandmasterMovesGoToNextStateEvent());
        },
        expect: () => [_getOpeningMoveMatcher(1, openingMovesLength == 2)],
      );

      blocTest(
        'FindTheGrandmasterMovesBloc go forward to second opening state and back to first opening state',
        build: _buildFindTheGrandmasterMovesBloc,
        act: (final FindTheGrandmasterMovesBloc bloc) {
          bloc.add(FindTheGrandmasterMovesGoToNextStateEvent());
          bloc.add(FindTheGrandmasterMovesGoToPreviousStateEvent());
        },
        expect: () => [_getOpeningMoveMatcher(1, openingMovesLength == 2), _getOpeningMoveMatcher(0, openingMovesLength == 1)],
      );

      blocTest(
        'FindTheGrandmasterMovesBloc go to last opening state',
        build: _buildFindTheGrandmasterMovesBloc,
        act: (final FindTheGrandmasterMovesBloc bloc) {
          _goForwardToLastOpeningState(bloc, 0);
        },
        skip: openingMovesLength - 2,
        expect: () => [_getOpeningMoveMatcher(openingMovesLength - 1, true)],
      );

      blocTest(
        'FindTheGrandmasterMovesBloc go to last opening state and back to first state',
        build: _buildFindTheGrandmasterMovesBloc,
        act: (final FindTheGrandmasterMovesBloc bloc) {
          var currentPly = 0;
          currentPly = _goForwardToLastOpeningState(bloc, currentPly);
          currentPly = _goBackToFirstState(bloc, currentPly);
        },
        skip: (openingMovesLength - 1) + (openingMovesLength - 2),
        expect: () => [_getOpeningMoveMatcher(0, openingMovesLength == 1)],
      );

      blocTest(
        'FindTheGrandmasterMovesBloc go to last opening state, back to first state and finally to last opening state again',
        build: _buildFindTheGrandmasterMovesBloc,
        act: (final FindTheGrandmasterMovesBloc bloc) {
          var currentPly = 0;
          currentPly = _goForwardToLastOpeningState(bloc, currentPly);
          currentPly = _goBackToFirstState(bloc, currentPly);
          currentPly = _goForwardToLastOpeningState(bloc, currentPly);
        },
        skip: (openingMovesLength - 1) + (openingMovesLength - 1) + (openingMovesLength - 2),
        expect: () => [_getOpeningMoveMatcher(openingMovesLength - 1, true)],
      );
    }

    /* ------------------------------------------------------------------------------------------------*/
    /*                                       INGAME TESTS                                              */
    /* ------------------------------------------------------------------------------------------------*/

    bool _isGMTurn(final int currentPly) {
      if ((analyzedGame.gameAnalysis.grandmasterSide == GrandmasterSide.white && currentPly % 2 == 0) ||
          (analyzedGame.gameAnalysis.grandmasterSide == GrandmasterSide.black && currentPly % 2 == 1)) {
        return true;
      }
      return false;
    }

    bool _grandmasterMovePlayed(final EvaluatedMove moveTaken, final int ply) {
      return analyzedGame.gameAnalysis.analyzedMoves[ply].actualMove.move.san == moveTaken.move.san;
    }

    bool _bestMovePlayed(final AnalyzedMoveType moveTakenType) {
      return moveTakenType == AnalyzedMoveType.best ||
          moveTakenType == AnalyzedMoveType.critical ||
          moveTakenType == AnalyzedMoveType.brilliant ||
          moveTakenType == AnalyzedMoveType.gameChanger;
    }

    bool _badMovePlayed(final AnalyzedMoveType moveTakenType) {
      return moveTakenType == AnalyzedMoveType.blunder || moveTakenType == AnalyzedMoveType.mistake || moveTakenType == AnalyzedMoveType.inaccuracy;
    }

    int _getPointsGiven(final int ply, final EvaluatedMove move) {
      int pointsGiven = 0;

      if (_grandmasterMovePlayed(move, ply) || _bestMovePlayed(move.moveType)) {
        pointsGiven = bestMovePlayedPointsGiven;
      } else if (_badMovePlayed(move.moveType)) {
        pointsGiven = badMovePlayedPointsGiven;
      } else {
        pointsGiven = mediocreMovePlayedPointsGiven;
      }
      return pointsGiven;
    }

    Map<int, EvaluatedMove> _goForwardFromLastOpeningStateToIngameState(final FindTheGrandmasterMovesBloc bloc, final int endAtPly) {
      final Map<int, EvaluatedMove> movesTakenByPly = {};

      for (var ply = openingMovesLength; ply < endAtPly; ply++) {
        bloc.add(FindTheGrandmasterMovesGoToNextStateEvent());
        if (_isGMTurn(ply)) {
          final alternativeMoves = analyzedGame.gameAnalysis.analyzedMoves[ply].alternativeMoves;
          final move = alternativeMoves.isNotEmpty ? alternativeMoves[0] : analyzedGame.gameAnalysis.analyzedMoves[ply].actualMove;
          bloc.add(FindTheGrandmasterMovesSelectGuessEvent(move));
          movesTakenByPly[ply] = move;
          bloc.add(FindTheGrandmasterMovesSubmitGuessEvent(PointsBloc(database: testDb)));
        } else {
          bloc.add(FindTheGrandmasterMovesRevealOpponentMoveEvent());
        }
      }

      return movesTakenByPly;
    }

    int _getAmountOfStatesToSkipIngame(final int currentPly) {
      var skips = openingMovesLength - 1;
      for (var ply = openingMovesLength; ply <= currentPly; ply++) {
        if (_isGMTurn(ply)) {
          skips += 3; // guessing state, preview guess move state, guess evaluated state
        } else {
          skips += 2; // opponent playing state unrevealed, opponent playing state revealed
        }
      }
      skips--;

      return skips;
    }

    void _collectPointsAndGoToNextGuessingState(final FindTheGrandmasterMovesBloc bloc, final int ply, final PointsBloc pointsBloc) {
      for (int i = ply; i < ply + 2; i++) {
        if (_isGMTurn(i)) {
          final move = analyzedGame.gameAnalysis.analyzedMoves[i].actualMove;
          bloc.add(FindTheGrandmasterMovesSelectGuessEvent(move));
          bloc.add(FindTheGrandmasterMovesSubmitGuessEvent(pointsBloc));
        } else {
          bloc.add(FindTheGrandmasterMovesRevealOpponentMoveEvent());
        }
        bloc.add(FindTheGrandmasterMovesGoToNextStateEvent());
      }
    }

    Future<PointsBloc> _guessOneMoveCorrectAndBuyTipAtNextGuessingMove(final FindTheGrandmasterMovesBloc bloc) async {
      _goForwardToLastOpeningState(bloc, 0);
      bloc.add(FindTheGrandmasterMovesGoToNextStateEvent());
      // skip: openingMovesLength

      int ply = openingMovesLength;
      if (!_isGMTurn(openingMovesLength)) {
        bloc.add(FindTheGrandmasterMovesRevealOpponentMoveEvent());
        bloc.add(FindTheGrandmasterMovesGoToNextStateEvent());
        ply++;
        // skip += 2
      }

      final pointsBloc = PointsBloc(database: testDb);

      final pointsBefore = await PointsDao(database: testDb).get();

      _collectPointsAndGoToNextGuessingState(bloc, ply, pointsBloc);
      // skip += 5

      // wait for points bloc to add received points to database
      while ((await PointsDao(database: testDb).get()) == pointsBefore) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      bloc.add(FindTheGrandmasterMovesShowNextTipEvent(null, pointsBloc));

      return pointsBloc;
    }

    Matcher _getIngameMoveMatcher(final int ply, final bool isFirstIngameMoveAfterOpening) {
      return isA<FindTheGrandmasterMovesIngameState>()
          .having((state) => state.move.ply, 'Ingame move ply', ply)
          .having((state) => state.isFirstMoveAfterOpening(), 'Is first ingame move after opening', isFirstIngameMoveAfterOpening);
    }

    Matcher _getGuessEvaluatedMatcher(final int ply, final int pointsGiven) {
      return isA<FindTheGrandmasterMovesGuessEvaluated>()
          .having((state) => state.move.ply, 'Ingame move ply', ply)
          .having((state) => state.pointsGiven, 'Points given were calculated correctly', pointsGiven);
    }

    Matcher _getOpponentMoveMatcher(final int ply, final bool moveRevealed) {
      return isA<FindTheGrandmasterMovesOpponentPlayingMove>()
          .having((state) => state.move.ply, 'Ingame move ply', ply)
          .having((state) => state.moveRevealed, 'Ingame move revealed', moveRevealed);
    }

    Matcher _getGuessingMoveMatcher(final int ply, {removeWorstAnswerTipUsed = false, showPieceTypeTipUsed = false, showActualPieceTipUsed = false}) {
      return isA<FindTheGrandmasterMovesGuessingMove>()
          .having((state) => state.move.ply, 'Ingame move ply', ply)
          .having((state) => state.showPieceTypeTipUsed, 'Ingame show piece type tip used', showPieceTypeTipUsed)
          .having((state) => state.showActualPieceTipUsed, 'Ingame show actual piece tip used', showActualPieceTipUsed)
          .having((state) => state.removeWorstAnswerTipUsed, 'Ingame remove worst answer tip used', removeWorstAnswerTipUsed);
    }

    Matcher _getNextMoveStateMatcher(final int lastPly, {moveRevealed = true}) {
      var matcher;

      if (_isGMTurn(lastPly) && lastPly == analyzedGame.gameAnalysis.analyzedMoves.length - 1) {
        final alternativeMoves = analyzedGame.gameAnalysis.analyzedMoves[lastPly].alternativeMoves;
        final move = alternativeMoves.isNotEmpty ? alternativeMoves.first : analyzedGame.gameAnalysis.analyzedMoves[lastPly].actualMove;

        final pointsGivenCorrect = _getPointsGiven(lastPly, move);
        matcher = _getGuessEvaluatedMatcher(lastPly, pointsGivenCorrect);
      } else if (_isGMTurn(lastPly) && lastPly < analyzedGame.gameAnalysis.analyzedMoves.length - 1) {
        matcher = _getIngameMoveMatcher(lastPly, openingMovesLength == lastPly);
      } else {
        matcher = _getOpponentMoveMatcher(lastPly, moveRevealed);
      }

      return matcher;
    }

    blocTest(
      'FindTheGrandmasterMovesBloc go to first ingame state',
      build: _buildFindTheGrandmasterMovesBloc,
      act: (final FindTheGrandmasterMovesBloc bloc) {
        var currentPly = 0;
        currentPly = _goForwardToLastOpeningState(bloc, currentPly);
        bloc.add(FindTheGrandmasterMovesGoToNextStateEvent());
      },
      skip: openingMovesLength - 1,
      expect: () => [_getIngameMoveMatcher(openingMovesLength, true)],
    );

    blocTest(
      'FindTheGrandmasterMovesBloc go forward to second ingame state and back to first ingame state',
      build: _buildFindTheGrandmasterMovesBloc,
      act: (final FindTheGrandmasterMovesBloc bloc) {
        _goForwardToLastOpeningState(bloc, 0);
        // go to first ingame state
        bloc.add(FindTheGrandmasterMovesGoToNextStateEvent());
        if (_isGMTurn(openingMovesLength)) {
          final alternativeMoves = analyzedGame.gameAnalysis.analyzedMoves[openingMovesLength].alternativeMoves;
          final move = alternativeMoves.isNotEmpty ? alternativeMoves[0] : analyzedGame.gameAnalysis.analyzedMoves[openingMovesLength].actualMove;
          bloc.add(FindTheGrandmasterMovesSelectGuessEvent(move));
          bloc.add(FindTheGrandmasterMovesSubmitGuessEvent(PointsBloc(database: testDb)));
        } else {
          bloc.add(FindTheGrandmasterMovesRevealOpponentMoveEvent());
          bloc.add(FindTheGrandmasterMovesGoToNextStateEvent());
        }
      },
      skip: openingMovesLength + 1,
      expect: () {
        final movePlayed = analyzedGame.gameAnalysis.analyzedMoves[openingMovesLength].alternativeMoves.isEmpty
            ? analyzedGame.gameAnalysis.analyzedMoves[openingMovesLength].actualMove
            : analyzedGame.gameAnalysis.analyzedMoves[openingMovesLength].alternativeMoves.first;

        return [
          _isGMTurn(openingMovesLength)
              ? _getGuessEvaluatedMatcher(openingMovesLength, _getPointsGiven(openingMovesLength, movePlayed))
              : isA<FindTheGrandmasterMovesGuessingMove>()
        ];
      },
    );

    blocTest(
      'FindTheGrandmasterMovesBloc go to last ingame move',
      build: _buildFindTheGrandmasterMovesBloc,
      act: (final FindTheGrandmasterMovesBloc bloc) {
        _goForwardToLastOpeningState(bloc, 0);
        _goForwardFromLastOpeningStateToIngameState(bloc, analyzedGame.gameAnalysis.analyzedMoves.length);
      },
      skip: _getAmountOfStatesToSkipIngame(analyzedGame.gameAnalysis.analyzedMoves.length - 1),
      expect: () {
        final lastPly = analyzedGame.gameAnalysis.analyzedMoves.length - 1;
        return [_getNextMoveStateMatcher(lastPly)];
      },
    );

    blocTest(
      'FindTheGrandmasterMovesBloc go forward to last ingame state, go back to first opening state and then forward to last ingame state',
      build: _buildFindTheGrandmasterMovesBloc,
      act: (final FindTheGrandmasterMovesBloc bloc) {
        _goForwardToLastOpeningState(bloc, 0);
        _goForwardFromLastOpeningStateToIngameState(bloc, analyzedGame.gameAnalysis.analyzedMoves.length);
        // Go back to first first opening move
        for (int i = 0; i < analyzedGame.gameAnalysis.analyzedMoves.length - 1; i++) {
          bloc.add(FindTheGrandmasterMovesGoToPreviousStateEvent());
        }
        for (int i = 0; i < analyzedGame.gameAnalysis.analyzedMoves.length - 1; i++) {
          bloc.add(FindTheGrandmasterMovesGoToNextStateEvent());
        }
      },
      skip: _getAmountOfStatesToSkipIngame(analyzedGame.gameAnalysis.analyzedMoves.length - 1) + 2 * (analyzedGame.gameAnalysis.analyzedMoves.length - 1),
      expect: () {
        final lastPly = analyzedGame.gameAnalysis.analyzedMoves.length - 1;
        return [_getNextMoveStateMatcher(lastPly)];
      },
    );

    blocTest(
      'FindTheGrandmasterMovesBloc go forward to mid game, back to first opening and go forward to next guessing/opponent state',
      build: _buildFindTheGrandmasterMovesBloc,
      act: (final FindTheGrandmasterMovesBloc bloc) {
        final midGamePly = (analyzedGame.gameAnalysis.analyzedMoves.length / 2).ceil();
        _goForwardToLastOpeningState(bloc, 0);
        _goForwardFromLastOpeningStateToIngameState(bloc, midGamePly);
        // Go back to first first opening move
        for (int i = 0; i < midGamePly - 1; i++) {
          bloc.add(FindTheGrandmasterMovesGoToPreviousStateEvent());
        }
        for (int i = 0; i < midGamePly; i++) {
          // skip guess evaluated state here, not - 1 at length
          bloc.add(FindTheGrandmasterMovesGoToNextStateEvent());
        }
      },
      skip: _getAmountOfStatesToSkipIngame((analyzedGame.gameAnalysis.analyzedMoves.length / 2).ceil() - 1) + 2 * (analyzedGame.gameAnalysis.analyzedMoves.length / 2).ceil() - 1,
      expect: () {
        final lastPly = (analyzedGame.gameAnalysis.analyzedMoves.length / 2).ceil();
        return [_getNextMoveStateMatcher(lastPly)];
      },
    );

    blocTest(
      'FindTheGrandmasterMovesBloc go to first guessing ingame state and try to buy tip, but there are not enough points',
      build: _buildFindTheGrandmasterMovesBloc,
      act: (final FindTheGrandmasterMovesBloc bloc) {
        _goForwardToLastOpeningState(bloc, 0);
        bloc.add(FindTheGrandmasterMovesGoToNextStateEvent());
        if (_isGMTurn(openingMovesLength)) {
          // use tip
          bloc.add(FindTheGrandmasterMovesShowNextTipEvent(null, PointsBloc(database: testDb)));
        } else {
          bloc.add(FindTheGrandmasterMovesRevealOpponentMoveEvent());
          bloc.add(FindTheGrandmasterMovesGoToNextStateEvent());
          bloc.add(FindTheGrandmasterMovesShowNextTipEvent(null, PointsBloc(database: testDb)));
        }
      },
      skip: _isGMTurn(openingMovesLength) ? openingMovesLength - 1 : openingMovesLength + 1,
      expect: () => [_getGuessingMoveMatcher(_isGMTurn(openingMovesLength) ? openingMovesLength : openingMovesLength + 1)], // All tips false, because tip could not be shown
    );

    blocTest(
      'FindTheGrandmasterMovesBloc guess first guessing move correctly and successfully buy one tip at next guessing state',
      build: _buildFindTheGrandmasterMovesBloc,
      act: (final FindTheGrandmasterMovesBloc bloc) async {
        await _guessOneMoveCorrectAndBuyTipAtNextGuessingMove(bloc);
      },
      skip: _isGMTurn(openingMovesLength) ? openingMovesLength + 5 : openingMovesLength + 7, // see skip comments
      expect: () => [
        _getGuessingMoveMatcher(_isGMTurn(openingMovesLength) ? openingMovesLength + 2 : openingMovesLength + 3, removeWorstAnswerTipUsed: true),
      ],
    );

    blocTest(
      'FindTheGrandmasterMovesBloc guess first guessing move correctly and successfully buy two tips at next guessing state',
      build: _buildFindTheGrandmasterMovesBloc,
      act: (final FindTheGrandmasterMovesBloc bloc) async {
        var pointsBloc = await _guessOneMoveCorrectAndBuyTipAtNextGuessingMove(bloc);
        bloc.add(FindTheGrandmasterMovesShowNextTipEvent(null, pointsBloc));
      },
      skip: _isGMTurn(openingMovesLength) ? openingMovesLength + 5 : openingMovesLength + 7, // see skip comments
      expect: () => [
        _getGuessingMoveMatcher(_isGMTurn(openingMovesLength) ? openingMovesLength + 2 : openingMovesLength + 3, removeWorstAnswerTipUsed: true),
        _getGuessingMoveMatcher(_isGMTurn(openingMovesLength) ? openingMovesLength + 2 : openingMovesLength + 3, removeWorstAnswerTipUsed: true, showPieceTypeTipUsed: true),
      ],
    );

    blocTest(
      'FindTheGrandmasterMovesBloc guess first guessing move correctly and successfully buy all tips at next guessing state',
      build: _buildFindTheGrandmasterMovesBloc,
      act: (final FindTheGrandmasterMovesBloc bloc) async {
        var pointsBloc = await _guessOneMoveCorrectAndBuyTipAtNextGuessingMove(bloc);
        bloc.add(FindTheGrandmasterMovesShowNextTipEvent(null, pointsBloc));
        bloc.add(FindTheGrandmasterMovesShowNextTipEvent(null, pointsBloc));
      },
      skip: _isGMTurn(openingMovesLength) ? openingMovesLength + 5 : openingMovesLength + 7, // see skip comments
      expect: () => [
        _getGuessingMoveMatcher(_isGMTurn(openingMovesLength) ? openingMovesLength + 2 : openingMovesLength + 3, removeWorstAnswerTipUsed: true),
        _getGuessingMoveMatcher(_isGMTurn(openingMovesLength) ? openingMovesLength + 2 : openingMovesLength + 3, removeWorstAnswerTipUsed: true, showPieceTypeTipUsed: true),
        _getGuessingMoveMatcher(_isGMTurn(openingMovesLength) ? openingMovesLength + 2 : openingMovesLength + 3,
            removeWorstAnswerTipUsed: true, showPieceTypeTipUsed: true, showActualPieceTipUsed: true),
      ],
    );

    blocTest(
      'FindTheGrandmasterMovesBloc buy a tip, go back one state and then forward one state, tip should still be revealed',
      build: _buildFindTheGrandmasterMovesBloc,
      act: (final FindTheGrandmasterMovesBloc bloc) async {
        await _guessOneMoveCorrectAndBuyTipAtNextGuessingMove(bloc);
        bloc.add(FindTheGrandmasterMovesGoToPreviousStateEvent());
        // skip += 2
        bloc.add(FindTheGrandmasterMovesGoToNextStateEvent());
      },
      skip: _isGMTurn(openingMovesLength) ? openingMovesLength + 7 : openingMovesLength + 9, // see skip comments
      expect: () => [_getGuessingMoveMatcher(_isGMTurn(openingMovesLength) ? openingMovesLength + 2 : openingMovesLength + 3, removeWorstAnswerTipUsed: true)],
    );

    blocTest(
      'FindTheGrandmasterMovesBloc buy two tips, go back one state and then forward one state, tips should still be revealed',
      build: _buildFindTheGrandmasterMovesBloc,
      act: (final FindTheGrandmasterMovesBloc bloc) async {
        var pointsBloc = await _guessOneMoveCorrectAndBuyTipAtNextGuessingMove(bloc);
        bloc.add(FindTheGrandmasterMovesShowNextTipEvent(null, pointsBloc)); // skip++
        bloc.add(FindTheGrandmasterMovesGoToPreviousStateEvent());
        // skip += 2
        bloc.add(FindTheGrandmasterMovesGoToNextStateEvent());
      },
      skip: _isGMTurn(openingMovesLength) ? openingMovesLength + 8 : openingMovesLength + 10, // see skip comments
      expect: () => [
        _getGuessingMoveMatcher(_isGMTurn(openingMovesLength) ? openingMovesLength + 2 : openingMovesLength + 3, removeWorstAnswerTipUsed: true, showPieceTypeTipUsed: true),
      ],
    );

    blocTest(
      'FindTheGrandmasterMovesBloc buy all tips, go back one state and then forward one state, tips should still be revealed',
      build: _buildFindTheGrandmasterMovesBloc,
      act: (final FindTheGrandmasterMovesBloc bloc) async {
        var pointsBloc = await _guessOneMoveCorrectAndBuyTipAtNextGuessingMove(bloc);
        bloc.add(FindTheGrandmasterMovesShowNextTipEvent(null, pointsBloc)); // skip++
        bloc.add(FindTheGrandmasterMovesShowNextTipEvent(null, pointsBloc)); // skip++
        bloc.add(FindTheGrandmasterMovesGoToPreviousStateEvent());
        // skip += 2
        bloc.add(FindTheGrandmasterMovesGoToNextStateEvent());
      },
      skip: _isGMTurn(openingMovesLength) ? openingMovesLength + 9 : openingMovesLength + 11, // see skip comments
      expect: () => [
        _getGuessingMoveMatcher(_isGMTurn(openingMovesLength) ? openingMovesLength + 2 : openingMovesLength + 3,
            removeWorstAnswerTipUsed: true, showPieceTypeTipUsed: true, showActualPieceTipUsed: true),
      ],
    );

    test('FindTheGrandmasterMovesBloc guess first guessing move correctly, successfully buy tips at next guessing state, error when all tips are revealed and you want another tip',
        () async {
      final bloc = _buildFindTheGrandmasterMovesBloc();
      var pointsBloc = await _guessOneMoveCorrectAndBuyTipAtNextGuessingMove(bloc);
      bloc.add(FindTheGrandmasterMovesShowNextTipEvent(null, pointsBloc));
      bloc.add(FindTheGrandmasterMovesShowNextTipEvent(null, pointsBloc));
      bloc.add(FindTheGrandmasterMovesShowNextTipEvent(null, pointsBloc));

      await Future.delayed(const Duration(seconds: 2), () {});
      expect(error, isA<StateError>()); //'No more next tip to show available.'
      error = null;
    });

    /* ------------------------------------------------------------------------------------------------*/
    /*                                    EVALUATION TESTS                                             */
    /* ------------------------------------------------------------------------------------------------*/

    Matcher _getShowingSummaryMatcher(final Map<AnalyzedMoveType, int> movesEvaluationMap, final int totalMovesGuessAmount, final int grandmasterMovesPlayedAmount,
        final int bestMovesPlayedAmount, final int totalPointsGivenAmount) {
      return isA<FindTheGrandmasterMovesShowingSummary>()
          .having((state) => state.data.getMovesGuessesAmountsByAnalyzedMoveType(), 'Analyzed move types amounts map', movesEvaluationMap)
          .having((state) => state.data.getTotalMovesGuessedAmount(), 'Total moves guessed', totalMovesGuessAmount)
          .having((state) => state.data.getBestMovesGuessedAmount(), 'Best moves guessed correct', bestMovesPlayedAmount)
          .having((state) => state.data.getGrandmasterMovesGuessedAmount(), 'Grandmaster moves guessed amount', grandmasterMovesPlayedAmount)
          .having((state) => state.data.getPointsGivenTotalAmount(), 'Total points given amount', totalPointsGivenAmount);
    }

    int _calculatePointsGivenTotalAmount(final Map<int, EvaluatedMove> movesTakenByPly) {
      return movesTakenByPly.entries.map((entry) => _getPointsGiven(entry.key, entry.value)).reduce((sum, pointsAmount) => sum + pointsAmount);
    }

    final Map<AnalyzedMoveType, int> movesEvaluationMap = {};
    for (final analyzedMoveType in AnalyzedMoveType.values) {
      if (analyzedMoveType == AnalyzedMoveType.book) {
        // opening book moves can not be guessed
        continue;
      }
      movesEvaluationMap[analyzedMoveType] = 0;
    }

    var totalMovesPlayedAmount;
    var grandmasterMovesPlayedAmount;
    var bestMovesPlayedAmount;
    var totalPointsGivenAmount;
    var findTheGrandmasterMovesGamesPlayedByAnalyzedGame;

    blocTest(
      'FindTheGrandmasterMovesBloc evaluation test',
      build: _buildFindTheGrandmasterMovesBloc,
      act: (final FindTheGrandmasterMovesBloc bloc) async {
        _goForwardToLastOpeningState(bloc, 0); // openingMovesLength - 1

        final movesTakenByPly = _goForwardFromLastOpeningStateToIngameState(bloc, analyzedGame.gameAnalysis.analyzedMoves.length);

        movesTakenByPly.values.forEach((move) => movesEvaluationMap[move.moveType] = (movesEvaluationMap[move.moveType] ?? 0) + 1);
        totalMovesPlayedAmount = movesEvaluationMap.values.reduce((sum, amount) => sum + amount);
        grandmasterMovesPlayedAmount = movesTakenByPly.entries.where((entry) => _grandmasterMovePlayed(entry.value, entry.key)).length;
        bestMovesPlayedAmount = movesEvaluationMap.entries.where((entry) => _bestMovePlayed(entry.key)).map((entry) => entry.value).reduce((sum, amount) => sum + amount);
        totalPointsGivenAmount = _calculatePointsGivenTotalAmount(movesTakenByPly);

        bloc.add(FindTheGrandmasterMovesGoToNextStateEvent());

        // wait for FindTheGrandmasterMovesGamesPlayedDao to insert played game
        while ((await FindTheGrandmasterMovesGamesPlayedDao(database: testDb).getByAnalyzedGame(analyzedGame)).isEmpty) {
          await Future.delayed(const Duration(milliseconds: 100));
        }

        findTheGrandmasterMovesGamesPlayedByAnalyzedGame = await FindTheGrandmasterMovesGamesPlayedDao(database: testDb).getByAnalyzedGame(analyzedGame);
      },
      skip: _getAmountOfStatesToSkipIngame(analyzedGame.gameAnalysis.analyzedMoves.length - 1) + 1,
      expect: () {
        expect(findTheGrandmasterMovesGamesPlayedByAnalyzedGame.length, 1);
        expect(findTheGrandmasterMovesGamesPlayedByAnalyzedGame.first.analyzedGameId, analyzedGame.id);
        expect(findTheGrandmasterMovesGamesPlayedByAnalyzedGame.first.analyzedGameOriginBundle, analyzedGamesBundle);
        expect(findTheGrandmasterMovesGamesPlayedByAnalyzedGame.first.info.analyzedGameId, analyzedGame.id);
        expect(findTheGrandmasterMovesGamesPlayedByAnalyzedGame.first.info.grandmasterSide, analyzedGame.gameAnalysis.grandmasterSide);
        expect(findTheGrandmasterMovesGamesPlayedByAnalyzedGame.first.info.blackPlayer, analyzedGame.blackPlayer);
        expect(findTheGrandmasterMovesGamesPlayedByAnalyzedGame.first.info.whitePlayer, analyzedGame.whitePlayer);
        expect(findTheGrandmasterMovesGamesPlayedByAnalyzedGame.first.info.gameInfoString, analyzedGame.gameInfo.toString());
        expect(findTheGrandmasterMovesGamesPlayedByAnalyzedGame.first.info.whitePlayerRating, analyzedGame.whitePlayerRating);
        expect(findTheGrandmasterMovesGamesPlayedByAnalyzedGame.first.info.blackPlayerRating, analyzedGame.blackPlayerRating);
        expect(findTheGrandmasterMovesGamesPlayedByAnalyzedGame.first.gameEvaluationData.getMovesGuessesAmountsByAnalyzedMoveType(), movesEvaluationMap);
        expect(findTheGrandmasterMovesGamesPlayedByAnalyzedGame.first.gameEvaluationData.getPointsGivenTotalAmount(), totalPointsGivenAmount);
        expect(findTheGrandmasterMovesGamesPlayedByAnalyzedGame.first.gameEvaluationData.getTotalMovesGuessedAmount(), totalMovesPlayedAmount);
        expect(findTheGrandmasterMovesGamesPlayedByAnalyzedGame.first.gameEvaluationData.getGrandmasterMovesGuessedAmount(), grandmasterMovesPlayedAmount);
        expect(findTheGrandmasterMovesGamesPlayedByAnalyzedGame.first.gameEvaluationData.getBestMovesGuessedAmount(), bestMovesPlayedAmount);

        return [_getShowingSummaryMatcher(movesEvaluationMap, totalMovesPlayedAmount, grandmasterMovesPlayedAmount, bestMovesPlayedAmount, totalPointsGivenAmount)];
      },
    );
  });
}
