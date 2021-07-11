import 'dart:async';
import 'dart:math';

import 'package:cupertino_will_pop_scope/cupertino_will_pop_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/find_the_grandmaster_moves_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/model/analyzed_game.dart';
import 'package:guess_the_move/model/analyzed_games_bundle.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/screens/game_modes/components/chess_board/chessboard_model.dart';
import 'package:guess_the_move/screens/game_modes/components/game_bottom_navigation_bar.dart';
import 'package:guess_the_move/screens/game_modes/time_battle/components/time_battle_floating_action_button.dart';
import 'package:guess_the_move/screens/game_modes/time_battle/components/time_battle_game_contents.dart';
import 'package:guess_the_move/screens/game_modes/time_battle/components/time_battle_header.dart';
import 'package:guess_the_move/screens/game_modes/time_battle/components/time_battle_pause_screen.dart';
import 'package:guess_the_move/screens/game_modes/time_battle/components/time_battle_progress_indicator.dart';
import 'package:guess_the_move/screens/game_modes/utils/show_exit_game_dialog.dart';
import 'package:guess_the_move/screens/game_modes/utils/show_toast_message.dart';
import 'package:guess_the_move/theme/theme.dart';

class TimeBattleScreen extends StatefulWidget {
  final AnalyzedGame analyzedGame;
  final AnalyzedGamesBundle analyzedGameOriginBundle;
  final int initialTimeInSeconds;

  TimeBattleScreen({Key? key, required this.analyzedGame, required this.analyzedGameOriginBundle, required this.initialTimeInSeconds}) : super(key: key);

  @override
  _TimeBattleScreenState createState() => _TimeBattleScreenState();
}

class _TimeBattleScreenState extends State<TimeBattleScreen> with TickerProviderStateMixin {
  final ChessBoardController _chessBoardController = ChessBoardController();
  late AnimationController _timerAnimationController;

  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  FindTheGrandmasterMovesIngameState? _lastIngameState;
  int _currentGameCount = 1;
  bool _gameStarted = false;
  bool _gameEnded = false;
  int _totalPointsGiven = 0;
  int _totalMovesPlayed = 0;
  int _correctMovesPlayed = 0;

  @override
  void initState() {
    super.initState();
    _timerAnimationController = AnimationController(
      vsync: this, // the SingleTickerProviderStateMixin
      duration: Duration(seconds: widget.initialTimeInSeconds),
    );
    _timerAnimationController.addStatusListener((final AnimationStatus status) {
      if (status == AnimationStatus.completed) _onTimerRunOut();
    });
    _timerAnimationController.stop();
  }

  @override
  void dispose() {
    _timerAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<UserSettingsBloc, UserSettingsState>(
        builder: (context, userSettingsState) => BlocProvider<FindTheGrandmasterMovesBloc>(
          create: (_) => _initializeGameBloc(userSettingsState),
          child: BlocListener<FindTheGrandmasterMovesBloc, FindTheGrandmasterMovesState>(
            listener: (context, newState) => _onBlocStateChange(context, userSettingsState, newState),
            listenWhen: _listenWhenBlocStateChanges,
            child: BlocBuilder<FindTheGrandmasterMovesBloc, FindTheGrandmasterMovesState>(
              builder: (context, state) => ConditionalWillPopScope(
                onWillPop: () => _onWillPop(userSettingsState),
                shouldAddCallbacks: !(state is FindTheGrandmasterMovesTimeBattleGameOver),
                child: Theme(
                  data: buildMaterialThemeData(context, userSettingsState, GameModeEnum.timeBattle),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[GameModeEnum.timeBattle]!.backgroundGradient,
                    ),
                    child: Scaffold(
                      key: _scaffoldKey,
                      backgroundColor: Colors.transparent,
                      body: SafeArea(
                        bottom: false,
                        child: TimeBattleGameContents(
                          chessBoardController: _chessBoardController,
                          ingameHeader: TimeBattleHeader(
                            totalMovesGuessed: _totalMovesPlayed,
                            movesGuessedCorrect: _correctMovesPlayed,
                            onPressHome: () => _onWillPop(userSettingsState),
                          ),
                          initialTimeInSeconds: widget.initialTimeInSeconds,
                          totalMovesGuessed: _totalMovesPlayed,
                          movesGuessedCorrect: _correctMovesPlayed,
                        ),
                      ),
                      floatingActionButton: TimeBattleFloatingActionButton(onPause: () {
                        _onPause(context.read<FindTheGrandmasterMovesBloc>(), state, userSettingsState);
                      }),
                      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
                      bottomNavigationBar: GameBottomNavigationBar(
                        currentGameCount: _currentGameCount,
                        onLastGameInBundleFinished: _onTimerRunOut,
                        progressIndicator: TimeBattleCountdownTimer(
                          animationController: _timerAnimationController,
                          userSettingsState: userSettingsState,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  FindTheGrandmasterMovesBloc _initializeGameBloc(final UserSettingsState userSettingsState) {
    var initialState =
        FindTheGrandmasterMovesShowingOpening(widget.analyzedGame, GameModeEnum.timeBattle, widget.analyzedGameOriginBundle, widget.analyzedGame.gameAnalysis.analyzedMoves[0]);
    var bloc = FindTheGrandmasterMovesBloc(initialState, GameModeEnum.timeBattle, _chessBoardController, userSettingsState.userSettings);
    bloc.screenStateHistory.add(initialState);
    return bloc;
  }

  bool _listenWhenBlocStateChanges(final FindTheGrandmasterMovesState previousState, final FindTheGrandmasterMovesState newState) {
    if (previousState.analyzedGame != newState.analyzedGame) {
      return true;
    }

    if (_gameEnded || newState is FindTheGrandmasterMovesShowingOpening) {
      return false;
    }

    // Summary state
    if (newState is FindTheGrandmasterMovesPostgameState) {
      _gameEnded = true;
      return true;
    }

    if (newState is FindTheGrandmasterMovesTimeBattleGameOver) {
      return false;
    }

    final newIngameState = newState as FindTheGrandmasterMovesIngameState;

    // First ingame state
    if (previousState is FindTheGrandmasterMovesShowingOpening && _lastIngameState == null) {
      _lastIngameState = newIngameState;
      return true;
    }

    // New opponent playing or guessing state
    if (_lastIngameState == null || newIngameState.move.ply > _lastIngameState!.move.ply) {
      _lastIngameState = newIngameState;
      return true;
    }

    // New guess evaluated state
    if (_lastIngameState != null &&
        _lastIngameState is FindTheGrandmasterMovesGuessingMove &&
        newIngameState is FindTheGrandmasterMovesGuessEvaluated &&
        newIngameState.move.ply == _lastIngameState!.move.ply) {
      _lastIngameState = newIngameState;
      return true;
    }

    return false;
  }

  void _onBlocStateChange(final BuildContext context, final UserSettingsState userSettingsState, final FindTheGrandmasterMovesState state) {
    // current game is finished
    if (state is FindTheGrandmasterMovesPostgameState) {
      _timerAnimationController.stop();
      return;
    }

    // guess was evaluated
    if (state is FindTheGrandmasterMovesGuessEvaluated) {
      setState(() {
        _totalMovesPlayed++;
        _totalPointsGiven += state.pointsGiven;
      });

      if (state.pointsGiven == bestMovePlayedPointsGiven) {
        showToastMessage(context, GameModeEnum.timeBattle, userSettingsState, Icons.check_circle, 'Super! Zeit wiederhergestellt');
        _timerAnimationController.forward(from: max(0, _timerAnimationController.value - 0.2));

        setState(() {
          _correctMovesPlayed++;
        });
      } else if (state.pointsGiven == mediocreMovePlayedPointsGiven) {
        showToastMessage(context, GameModeEnum.timeBattle, userSettingsState, Icons.remove_circle_outlined, 'Mittelmäßig!');
      } else if (state.pointsGiven == badMovePlayedPointsGiven) {
        showToastMessage(context, GameModeEnum.timeBattle, userSettingsState, Icons.cancel, 'Fehler! Zeit abgezogen');
        _timerAnimationController.forward(from: min(1, _timerAnimationController.value + 0.3));
      }
      return;
    }

    final ingameState = state as FindTheGrandmasterMovesIngameState;

    // new game started
    if (ingameState.move.ply == 0) {
      setState(() {
        _chessBoardController.reset!();
        _chessBoardController.removeMoveArrow!();
        _gameEnded = false;
        _lastIngameState = null;
        _currentGameCount++;
      });
      return;
    }

    // opening ended
    if (ingameState.isFirstMoveAfterOpening()) {
      if (_gameStarted) {
        setState(() {
          _timerAnimationController.forward();
        });
        showToastMessage(context, GameModeEnum.timeBattle, userSettingsState, Icons.timer, 'Deine Zeit läuft nun weiter!');
        return;
      }

      setState(() {
        _gameStarted = true;
        _timerAnimationController.reset();
        _timerAnimationController.forward();
      });

      final startTimeDisplayName;
      if (widget.initialTimeInSeconds > 60 && widget.initialTimeInSeconds % 60 == 0) {
        startTimeDisplayName = (widget.initialTimeInSeconds ~/ 60).toString() + 'min';
      } else {
        startTimeDisplayName = widget.initialTimeInSeconds.toString() + 's';
      }

      showToastMessage(context, GameModeEnum.timeBattle, userSettingsState, Icons.timer, 'Deine $startTimeDisplayName laufen ab jetzt!');
    }
  }

  void _onPause(final FindTheGrandmasterMovesBloc bloc, final FindTheGrandmasterMovesState state, final UserSettingsState userSettingsState) {
    _timerAnimationController.stop();

    final ingameState = state as FindTheGrandmasterMovesIngameState;

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) => TimeBattlePauseScreen(
          userSettingsState: userSettingsState,
          fullMoveNumber: ingameState.getFullMoveNumber(),
          turn: ingameState.getTurn(),
          initialTimeInSeconds: widget.initialTimeInSeconds,
          timeInSecondsLeft: ((1 - _timerAnimationController.value) * widget.initialTimeInSeconds).ceil(),
          totalPointsGiven: _totalPointsGiven,
          totalMovesPlayed: _totalMovesPlayed,
          correctMovesPlayed: _correctMovesPlayed,
          onResume: () {
            Navigator.pop(context);
            _timerAnimationController.forward();
            showToastMessage(context, GameModeEnum.timeBattle, userSettingsState, Icons.timer, 'Deine Zeit läuft wieder');
          },
          onEndGame: () => _onWillPop(userSettingsState, inPauseScreen: true),
        ),
      ),
    );
  }

  void _onTimerRunOut() {
    _scaffoldKey.currentContext!.read<FindTheGrandmasterMovesBloc>().add(FindTheGrandmasterMovesEndTimeBattleGameEvent(
          initialTimeInSeconds: widget.initialTimeInSeconds,
          totalPointsGivenAmount: _totalPointsGiven,
          totalMovesPlayedAmount: _totalMovesPlayed,
          correctMovesPlayedAmount: _correctMovesPlayed,
        ));
  }

  Future<bool> _onWillPop(final UserSettingsState userSettingsState, {bool inPauseScreen = false}) async {
    showExitGameDialog(
      context,
      GameModeEnum.timeBattle,
      userSettingsState,
      () {
        if (inPauseScreen) {
          Navigator.pop(context);
        }
        Navigator.pop(context);
        _timerAnimationController.forward(from: 1);
      },
    );
    // prevent page from being popped
    return false;
  }
}
