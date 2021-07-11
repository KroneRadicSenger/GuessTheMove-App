import 'package:cupertino_will_pop_scope/cupertino_will_pop_scope.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/find_the_grandmaster_moves_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/guess_the_move_app.dart';
import 'package:guess_the_move/model/analyzed_game.dart';
import 'package:guess_the_move/model/analyzed_games_bundle.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/screens/game_modes/components/chess_board/chessboard_model.dart';
import 'package:guess_the_move/screens/game_modes/components/game_bottom_navigation_bar.dart';
import 'package:guess_the_move/screens/game_modes/find_the_grandmaster_moves/components/find_the_grandmaster_moves_floating_action_button.dart';
import 'package:guess_the_move/screens/game_modes/find_the_grandmaster_moves/components/find_the_grandmaster_moves_game_contents.dart';
import 'package:guess_the_move/screens/game_modes/find_the_grandmaster_moves/components/find_the_grandmaster_moves_header.dart';
import 'package:guess_the_move/screens/game_modes/find_the_grandmaster_moves/components/find_the_grandmaster_moves_progress_indicator.dart';
import 'package:guess_the_move/screens/game_modes/utils/show_exit_game_dialog.dart';
import 'package:guess_the_move/theme/theme.dart';

class FindTheGrandmasterMovesScreen extends StatefulWidget {
  final AnalyzedGame analyzedGame;
  final AnalyzedGamesBundle analyzedGameOriginBundle;

  FindTheGrandmasterMovesScreen({required this.analyzedGame, required this.analyzedGameOriginBundle, Key? key}) : super(key: key);

  @override
  _FindTheGrandmasterMovesScreenState createState() => _FindTheGrandmasterMovesScreenState();
}

class _FindTheGrandmasterMovesScreenState extends State<FindTheGrandmasterMovesScreen> {
  final ChessBoardController chessBoardController = ChessBoardController();

  @override
  Widget build(BuildContext context) => BlocBuilder<UserSettingsBloc, UserSettingsState>(
        builder: (context, userSettingsState) => BlocProvider<FindTheGrandmasterMovesBloc>(
          create: (_) => _initializeGameBloc(userSettingsState),
          child: BlocBuilder<FindTheGrandmasterMovesBloc, FindTheGrandmasterMovesState>(
            builder: (context, state) {
              return ConditionalWillPopScope(
                onWillPop: () => _onWillPop(context, userSettingsState),
                shouldAddCallbacks: !(state is FindTheGrandmasterMovesShowingSummary),
                child: Theme(
                  data: buildMaterialThemeData(context, userSettingsState, GameModeEnum.findTheGrandmasterMoves),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[GameModeEnum.findTheGrandmasterMoves]!.backgroundGradient,
                    ),
                    child: Scaffold(
                      backgroundColor: Colors.transparent,
                      body: SafeArea(
                        bottom: false,
                        child: FindTheGrandmasterMovesGameContents(
                          chessBoardController: chessBoardController,
                          ingameHeader: FindTheGrandmasterMovesHeader(
                            onPressHome: () => _onWillPop(context, userSettingsState),
                          ),
                        ),
                      ),
                      floatingActionButton: FindTheGrandmasterMovesFloatingActionButton(
                        chessBoardController: chessBoardController,
                      ),
                      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
                      bottomNavigationBar: GameBottomNavigationBar(
                        progressIndicator: FindTheGrandmasterMovesProgressIndicator(userSettingsState: userSettingsState),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );

  FindTheGrandmasterMovesBloc _initializeGameBloc(final UserSettingsState userSettingsState) {
    var initialState = FindTheGrandmasterMovesShowingOpening(
        widget.analyzedGame, GameModeEnum.findTheGrandmasterMoves, widget.analyzedGameOriginBundle, widget.analyzedGame.gameAnalysis.analyzedMoves[0]);
    var bloc = FindTheGrandmasterMovesBloc(initialState, GameModeEnum.findTheGrandmasterMoves, chessBoardController, userSettingsState.userSettings);
    bloc.screenStateHistory.add(initialState);
    return bloc;
  }

  Future<bool> _onWillPop(final BuildContext context, final UserSettingsState userSettingsState) async {
    showExitGameDialog(
      context,
      GameModeEnum.findTheGrandmasterMoves,
      userSettingsState,
      () {
        Navigator.of(context).pushAndRemoveUntil(
          CupertinoPageRoute(
            builder: (BuildContext context) {
              return GuessTheMoveApp();
            },
          ),
          (_) => false,
        );
      },
    );
    // prevent page from being popped
    return false;
  }
}
