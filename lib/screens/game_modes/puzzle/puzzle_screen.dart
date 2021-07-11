import 'package:cupertino_will_pop_scope/cupertino_will_pop_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/puzzle_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/model/analyzed_game.dart';
import 'package:guess_the_move/model/analyzed_games_bundle.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/screens/game_modes/components/chess_board/chessboard_model.dart';
import 'package:guess_the_move/screens/game_modes/puzzle/components/puzzle_floating_action_button.dart';
import 'package:guess_the_move/screens/game_modes/puzzle/components/puzzle_game_bottom_navigation_bar.dart';
import 'package:guess_the_move/screens/game_modes/puzzle/components/puzzle_game_contents.dart';
import 'package:guess_the_move/screens/game_modes/puzzle/components/puzzle_pause_screen.dart';
import 'package:guess_the_move/screens/game_modes/puzzle/components/puzzle_timer.dart';
import 'package:guess_the_move/screens/game_modes/utils/show_exit_game_dialog.dart';
import 'package:guess_the_move/screens/game_modes/utils/show_toast_message.dart';
import 'package:guess_the_move/theme/theme.dart';

class PuzzleScreen extends StatefulWidget {
  final AnalyzedGamesBundle analyzedGameOriginBundle;
  final List<AnalyzedGame> analyzedGamesInBundle;

  PuzzleScreen({required this.analyzedGameOriginBundle, required this.analyzedGamesInBundle, Key? key}) : super(key: key);

  @override
  _PuzzleScreenState createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  final PuzzleTimerController _puzzleTimerController = PuzzleTimerController();
  final ChessBoardController _chessBoardController = ChessBoardController();

  @override
  Widget build(BuildContext context) => BlocBuilder<UserSettingsBloc, UserSettingsState>(
        builder: (context, userSettingsState) => Theme(
          data: buildMaterialThemeData(context, userSettingsState, GameModeEnum.puzzleMode),
          child: Container(
            decoration: BoxDecoration(
              gradient: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[GameModeEnum.puzzleMode]!.backgroundGradient,
            ),
            child: BlocProvider<PuzzleBloc>(
              create: (_) => _initializeGameBloc(userSettingsState),
              child: BlocBuilder<PuzzleBloc, PuzzleState>(
                builder: (context, state) => ConditionalWillPopScope(
                  onWillPop: () => _onWillPop(context.read<PuzzleBloc>(), userSettingsState),
                  shouldAddCallbacks: !(state is PuzzleGameOver),
                  child: Scaffold(
                    backgroundColor: Colors.transparent,
                    body: SafeArea(
                      bottom: false,
                      child: PuzzleGameContents(
                        puzzleTimerController: _puzzleTimerController,
                        chessBoardController: _chessBoardController,
                        onPause: () {
                          _onPause(context.read<PuzzleBloc>(), state, userSettingsState);
                        },
                        onPressHome: () => _onWillPop(context.read<PuzzleBloc>(), userSettingsState),
                      ),
                    ),
                    floatingActionButton: PuzzleFloatingActionButton(
                      chessBoardController: _chessBoardController,
                    ),
                    floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
                    bottomNavigationBar: PuzzleGameBottomNavigationBar(),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  PuzzleBloc _initializeGameBloc(final UserSettingsState userSettingsState) {
    final initialState = PuzzleBloc.buildNewPuzzleState(widget.analyzedGameOriginBundle, widget.analyzedGamesInBundle, []);
    return PuzzleBloc(initialState!, _puzzleTimerController, _chessBoardController, widget.analyzedGameOriginBundle, widget.analyzedGamesInBundle, userSettingsState.userSettings);
  }

  void _onPause(final PuzzleBloc bloc, final PuzzleState state, final UserSettingsState userSettingsState) {
    _puzzleTimerController.pause!();

    final ingameState = state as PuzzleIngameState;

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) => PuzzlePauseScreen(
          bloc: bloc,
          userSettingsState: userSettingsState,
          wrongTries: ingameState.wrongTries,
          wasAlreadySolved: ingameState.wasAlreadySolved,
          timePassedInMilliseconds: _puzzleTimerController.getTimePassedInMilliseconds!(),
          onResume: () {
            Navigator.pop(context);
            _puzzleTimerController.resume!();
            showToastMessage(context, GameModeEnum.puzzleMode, userSettingsState, Icons.timer, 'Deine Zeit läuft wieder');
          },
          onEndGame: () => _onWillPop(bloc, userSettingsState, inPauseScreen: true),
        ),
      ),
    );
  }

  Future<bool> _onWillPop(final PuzzleBloc bloc, final UserSettingsState userSettingsState, {bool inPauseScreen = false}) async {
    showExitGameDialog(
      context,
      GameModeEnum.puzzleMode,
      userSettingsState,
      () {
        if (inPauseScreen) {
          Navigator.pop(context);
        }
        Navigator.pop(context);
        bloc.add(PuzzleEndGameEvent());
      },
    );
    // prevent page from being popped
    return false;
  }
}
