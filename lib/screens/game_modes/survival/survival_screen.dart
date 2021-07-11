import 'dart:async';
import 'dart:math';

import 'package:cupertino_will_pop_scope/cupertino_will_pop_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:guess_the_move/bloc/find_the_grandmaster_moves_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/model/analyzed_game.dart';
import 'package:guess_the_move/model/analyzed_games_bundle.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/screens/game_modes/components/chess_board/chessboard_model.dart';
import 'package:guess_the_move/screens/game_modes/components/game_bottom_navigation_bar.dart';
import 'package:guess_the_move/screens/game_modes/survival/components/survival_floating_action_button.dart';
import 'package:guess_the_move/screens/game_modes/survival/components/survival_game_contents.dart';
import 'package:guess_the_move/screens/game_modes/survival/components/survival_header.dart';
import 'package:guess_the_move/screens/game_modes/survival/components/survival_progress_indicator.dart';
import 'package:guess_the_move/screens/game_modes/utils/show_exit_game_dialog.dart';
import 'package:guess_the_move/theme/theme.dart';

class SurvivalScreen extends StatefulWidget {
  final AnalyzedGame analyzedGame;
  final AnalyzedGamesBundle analyzedGameOriginBundle;
  final int amountLives;

  SurvivalScreen({Key? key, required this.analyzedGame, required this.analyzedGameOriginBundle, required this.amountLives}) : super(key: key);

  @override
  _SurvivalScreenState createState() => _SurvivalScreenState();
}

class _SurvivalScreenState extends State<SurvivalScreen> with TickerProviderStateMixin {
  final ChessBoardController _chessBoardController = ChessBoardController();
  late AnimationController _timerAnimationController;
  late FToast _fToast;

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
    _fToast = FToast();
    _fToast.init(context);
    _timerAnimationController = AnimationController(
      vsync: this, // the SingleTickerProviderStateMixin
      duration: Duration(seconds: widget.amountLives),
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
                onWillPop: () => _onWillPop(context.read<FindTheGrandmasterMovesBloc>(), userSettingsState),
                shouldAddCallbacks: !(state is FindTheGrandmasterMovesSurvivalGameOver),
                child: Theme(
                  data: buildMaterialThemeData(context, userSettingsState, GameModeEnum.survivalMode),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[GameModeEnum.survivalMode]!.backgroundGradient,
                    ),
                    child: Scaffold(
                      key: _scaffoldKey,
                      backgroundColor: Colors.transparent,
                      body: SafeArea(
                        bottom: false,
                        child: SurvivalGameContents(
                          chessBoardController: _chessBoardController,
                          ingameHeader: SurvivalHeader(
                            totalMovesGuessed: _totalMovesPlayed,
                            movesGuessedCorrect: _correctMovesPlayed,
                            onPressHome: () => _onWillPop(context.read<FindTheGrandmasterMovesBloc>(), userSettingsState),
                          ),
                          amountLives: widget.amountLives,
                          totalMovesGuessed: _totalMovesPlayed,
                          movesGuessedCorrect: _correctMovesPlayed,
                        ),
                      ),
                      floatingActionButton: SurvivalFloatingActionButton(),
                      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
                      bottomNavigationBar: GameBottomNavigationBar(
                        currentGameCount: _currentGameCount,
                        onLastGameInBundleFinished: _onTimerRunOut,
                        progressIndicator: SurvivalLiveBar(
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
        FindTheGrandmasterMovesShowingOpening(widget.analyzedGame, GameModeEnum.survivalMode, widget.analyzedGameOriginBundle, widget.analyzedGame.gameAnalysis.analyzedMoves[0]);
    var bloc = FindTheGrandmasterMovesBloc(initialState, GameModeEnum.survivalMode, _chessBoardController, userSettingsState.userSettings);
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

    if (newState is FindTheGrandmasterMovesSurvivalGameOver) {
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
        setState(() {
          _correctMovesPlayed++;
        });
      } else if (state.pointsGiven == mediocreMovePlayedPointsGiven) {
      } else if (state.pointsGiven == badMovePlayedPointsGiven) {
        _timerAnimationController.value = min(1, _timerAnimationController.value + 1 / widget.amountLives);
        _showToastMessage(userSettingsState, Icons.block_sharp, 'Du hast ein Leben verloren!');
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
        setState(() {});
        return;
      }

      setState(() {
        _gameStarted = true;
        _timerAnimationController.reset();
      });
    }
  }

  void _onTimerRunOut() {
    _scaffoldKey.currentContext!.read<FindTheGrandmasterMovesBloc>().add(FindTheGrandmasterMovesEndSurvivalGameEvent(
          amountLives: widget.amountLives,
          totalPointsGivenAmount: _totalPointsGiven,
          totalMovesPlayedAmount: _totalMovesPlayed,
          correctMovesPlayedAmount: _correctMovesPlayed,
        ));
  }

  void _showToastMessage(final UserSettingsState userSettingsState, final IconData icon, final String message) {
    _fToast.removeQueuedCustomToasts();

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[GameModeEnum.survivalMode]!.accentColor,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(25.0),
        color: appTheme(context, userSettingsState.userSettings.themeMode).cardBackgroundColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[GameModeEnum.survivalMode]!.accentColor,
          ),
          SizedBox(
            width: 12.0,
          ),
          Text(
            message,
            style: TextStyle(
              color: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[GameModeEnum.survivalMode]!.accentColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );

    _fToast.showToast(
      child: toast,
      positionedToastBuilder: (context, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Container(
                margin: EdgeInsets.only(bottom: bottomPadding + 70),
                child: child,
              ),
            ),
          ],
        );
      },
      toastDuration: Duration(seconds: 2),
    );
  }

  Future<bool> _onWillPop(final FindTheGrandmasterMovesBloc bloc, final UserSettingsState userSettingsState) async {
    showExitGameDialog(
      context,
      GameModeEnum.survivalMode,
      userSettingsState,
      () {
        Navigator.pop(context);
        bloc.add(
          FindTheGrandmasterMovesEndSurvivalGameEvent(
            amountLives: widget.amountLives,
            totalPointsGivenAmount: _totalPointsGiven,
            totalMovesPlayedAmount: _totalMovesPlayed,
            correctMovesPlayedAmount: _correctMovesPlayed,
          ),
        );
      },
    );
    // prevent page from being popped
    return false;
  }
}
