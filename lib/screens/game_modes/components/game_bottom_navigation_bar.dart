import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/find_the_grandmaster_moves_bloc.dart';
import 'package:guess_the_move/bloc/points_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/repository/analyzed_games_repository.dart';
import 'package:guess_the_move/theme/theme.dart';

class GameBottomNavigationBar extends StatelessWidget {
  final Widget progressIndicator;
  final int? currentGameCount;
  final Function? onLastGameInBundleFinished;

  GameBottomNavigationBar({Key? key, required this.progressIndicator, this.onLastGameInBundleFinished, this.currentGameCount}) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocBuilder<FindTheGrandmasterMovesBloc, FindTheGrandmasterMovesState>(
        builder: (context, state) => BlocBuilder<UserSettingsBloc, UserSettingsState>(builder: (_, userSettingsState) {
          Future<void> _onItemTapped(int index) async {
            if (index == 0) {
              var gameBloc = context.read<FindTheGrandmasterMovesBloc>();
              var totalPlies = state.analyzedGame.gameAnalysis.analyzedMoves.length;
              var pliesBefore = state is FindTheGrandmasterMovesShowingSummary ? totalPlies : (state as FindTheGrandmasterMovesIngameState).move.ply;

              for (int i = 0; i < pliesBefore; i++) {
                gameBloc.add(FindTheGrandmasterMovesGoToPreviousStateEvent());
              }
            } else if (index == 1) {
              if (state is FindTheGrandmasterMovesShowingOpening && state.move.ply == 0) {
                // user can not go back in first state
                return;
              }
              context.read<FindTheGrandmasterMovesBloc>().add(FindTheGrandmasterMovesGoToPreviousStateEvent());
            } else if (index == 2) {
              if (state is FindTheGrandmasterMovesShowingSummary) {
                return;
              }
              if (state is FindTheGrandmasterMovesGuessingMove) {
                if (state is FindTheGrandmasterMovesGuessingPreviewGuessMove) {
                  // Send submit guess event to bloc
                  context.read<FindTheGrandmasterMovesBloc>().add(FindTheGrandmasterMovesSubmitGuessEvent(context.read<PointsBloc>()));
                  return;
                }

                // user has to make a guess to go to the next state
                return;
              }
              if (state is FindTheGrandmasterMovesOpponentPlayingMove && !state.moveRevealed) {
                // user has to reveal opponent move before going to the next state
                return;
              }
              if (state.gameMode == GameModeEnum.timeBattle &&
                  ((state is FindTheGrandmasterMovesGuessEvaluated && state.isLastMove()) || (state is FindTheGrandmasterMovesOpponentPlayingMove && state.isLastMove()))) {
                final bundle = state.analyzedGameOriginBundle;
                final allGamesInBundle = await loadAnalyzedGamesInBundle(bundle);

                if (currentGameCount == allGamesInBundle.length) {
                  onLastGameInBundleFinished!();
                  return;
                }
              }
              if (state.gameMode == GameModeEnum.survivalMode &&
                  ((state is FindTheGrandmasterMovesGuessEvaluated && state.isLastMove()) || (state is FindTheGrandmasterMovesOpponentPlayingMove && state.isLastMove()))) {
                final bundle = state.analyzedGameOriginBundle;
                final allGamesInBundle = await loadAnalyzedGamesInBundle(bundle);

                if (currentGameCount == allGamesInBundle.length) {
                  onLastGameInBundleFinished!();
                  return;
                }
              }
              context.read<FindTheGrandmasterMovesBloc>().add(FindTheGrandmasterMovesGoToNextStateEvent());
            } else if (index == 3) {
              if (state is FindTheGrandmasterMovesShowingSummary) {
                return;
              }

              var ingameState = state as FindTheGrandmasterMovesIngameState;
              var gameBloc = context.read<FindTheGrandmasterMovesBloc>();

              var currentPly = ingameState.move.ply;

              var lastState = gameBloc.screenStateHistory.last;
              var lastPly;
              if (lastState is FindTheGrandmasterMovesShowingSummary) {
                final lastIngameState = gameBloc.screenStateHistory[gameBloc.screenStateHistory.length - 2] as FindTheGrandmasterMovesIngameState;
                lastPly = lastIngameState.move.ply + 1;
              } else {
                lastPly = (lastState as FindTheGrandmasterMovesIngameState).move.ply;
              }

              for (int i = 0; i < (lastPly - currentPly); i++) {
                gameBloc.add(FindTheGrandmasterMovesGoToNextStateEvent());
              }
            }
          }

          var forwardButtonIsActive = state is FindTheGrandmasterMovesShowingOpening ||
              state is FindTheGrandmasterMovesGuessEvaluated ||
              state is FindTheGrandmasterMovesGuessingPreviewGuessMove ||
              (state is FindTheGrandmasterMovesOpponentPlayingMove && state.moveRevealed);

          var defaultButtonColor = appTheme(context, userSettingsState.userSettings.themeMode).textColor.withOpacity(.5);
          var forwardButtonColor =
              forwardButtonIsActive ? appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[state.gameMode]!.accentColor : defaultButtonColor;

          return BottomAppBar(
            color: appTheme(context, userSettingsState.userSettings.themeMode).navigationBarColor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                progressIndicator,
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: (state is FindTheGrandmasterMovesTimeBattleGameOver || state is FindTheGrandmasterMovesSurvivalGameOver)
                      ? [
                          IconButton(
                            icon: Container(height: 26),
                            padding: EdgeInsets.all(15),
                            onPressed: () {},
                          ),
                        ]
                      : <Widget>[
                          IconButton(
                            icon: Transform.rotate(
                              angle: 90 * pi / 180,
                              child: Icon(Icons.get_app, size: 26),
                            ),
                            padding: EdgeInsets.all(15),
                            color: defaultButtonColor,
                            onPressed: () => _onItemTapped(0),
                          ),
                          Container(
                            margin: EdgeInsets.only(right: 80),
                            child: IconButton(
                              icon: Transform.rotate(
                                angle: pi,
                                child: Icon(Icons.forward, size: 26),
                              ),
                              padding: EdgeInsets.all(15),
                              color: defaultButtonColor,
                              onPressed: () => _onItemTapped(1),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.forward, size: 26),
                            color: forwardButtonColor,
                            padding: EdgeInsets.all(15),
                            onPressed: () => _onItemTapped(2),
                          ),
                          IconButton(
                            icon: Transform.rotate(
                              angle: 270 * pi / 180,
                              child: Icon(Icons.get_app, size: 26),
                            ),
                            color: defaultButtonColor,
                            padding: EdgeInsets.all(15),
                            onPressed: () => _onItemTapped(3),
                          ),
                        ],
                ),
              ],
            ),
          );
        }),
      );
}
