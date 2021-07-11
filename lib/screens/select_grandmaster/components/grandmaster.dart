import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/components/game_subtitle_text.dart';
import 'package:guess_the_move/components/game_title_text.dart';
import 'package:guess_the_move/model/analyzed_games_bundle.dart';
import 'package:guess_the_move/model/find_the_grandmaster_moves_game_played.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/model/player.dart';
import 'package:guess_the_move/repository/dao/find_the_grandmaster_moves_games_played_dao.dart';
import 'package:guess_the_move/repository/players_and_bundles_repository.dart';
import 'package:guess_the_move/screens/select_games/select_games_screen.dart';
import 'package:guess_the_move/screens/select_games_bundle/select_games_bundle_screen.dart';
import 'package:guess_the_move/theme/theme.dart';
import 'package:percent_indicator/percent_indicator.dart';

class Grandmaster extends StatelessWidget {
  final Player player;
  final GameModeEnum gameMode;

  Grandmaster({required this.player, required this.gameMode, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocBuilder<UserSettingsBloc, UserSettingsState>(
        builder: (context, state) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            child: Stack(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(top: 7, right: gameMode == GameModeEnum.findTheGrandmasterMoves ? 40 : 0),
                        child: TextButton(
                          onPressed: () => _onPress(context),
                          style: TextButton.styleFrom(
                            backgroundColor: appTheme(context, state.userSettings.themeMode).cardBackgroundColor,
                            primary: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 40),
                              child: FutureBuilder(
                                future: getAnalyzedGamesBundlesForGrandmaster(player),
                                builder: (final BuildContext context, final AsyncSnapshot<List<AnalyzedGamesBundle>> snapshot) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      GameTitleText(state, gameMode, '${player.getFirstAndLastName()}'),
                                      GameSubtitleText(
                                        state,
                                        snapshot.hasData ? 'Früheste Spiele von ${_getEarliestBundleYear(snapshot.data!)}' : '',
                                        showBulletPoint: false,
                                      ),
                                      GameSubtitleText(
                                        state,
                                        'Aktuellste ELO: ${player.latestEloRating}',
                                        showBulletPoint: false,
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (gameMode == GameModeEnum.findTheGrandmasterMoves) _buildGamesPlayedProgress(context, state),
              ],
            ),
          );
        },
      );

  Widget _buildGamesPlayedProgress(final BuildContext context, final UserSettingsState state) {
    return FutureBuilder<int>(
      future: getTotalAnalyzedGamesAmountForGrandmaster(player),
      builder: (final context, final snapshot) {
        final totalGrandmasterGamesAmount = !snapshot.hasData ? 1 : snapshot.data!;

        return FutureBuilder<List<FindTheGrandmasterMovesGamePlayed>>(
          future: FindTheGrandmasterMovesGamesPlayedDao().getByGrandmaster(player),
          builder: (final context, final snapshot) {
            final distinctGamesPlayedAmount = !snapshot.hasData ? 0 : snapshot.data!.map((gamePlayed) => gamePlayed.analyzedGameId).toSet().length;

            return Stack(
              children: [
                Align(
                  alignment: const Alignment(1.0, 0.5),
                  child: CircularPercentIndicator(
                    radius: 90.0,
                    lineWidth: 8.0,
                    animation: true,
                    percent: distinctGamesPlayedAmount.toDouble() / totalGrandmasterGamesAmount.toDouble(),
                    circularStrokeCap: CircularStrokeCap.round,
                    progressColor: appTheme(context, state.userSettings.themeMode).gameModeThemes[gameMode]!.accentColor,
                    backgroundColor: appTheme(context, state.userSettings.themeMode).cardBackgroundColor,
                  ),
                ),
                Align(
                  alignment: const Alignment(1.0, 0.5),
                  child: Container(
                    width: 74,
                    height: 74,
                    margin: EdgeInsets.only(top: 8, right: 8),
                    decoration: BoxDecoration(color: appTheme(context, state.userSettings.themeMode).scaffoldBackgroundColor, borderRadius: BorderRadius.circular(40)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          !snapshot.hasData ? '' : '$distinctGamesPlayedAmount\nvon\n$totalGrandmasterGamesAmount',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: appTheme(context, state.userSettings.themeMode).textColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _onPress(final BuildContext context) {
    switch (gameMode) {
      case GameModeEnum.findTheGrandmasterMoves:
        Navigator.push(context, MaterialPageRoute(builder: (_) => SelectGamesScreen(grandmaster: player, gameMode: gameMode)));
        break;
      case GameModeEnum.timeBattle:
      case GameModeEnum.survivalMode:
      case GameModeEnum.puzzleMode:
        Navigator.push(context, MaterialPageRoute(builder: (_) => SelectGamesBundleScreen(grandmaster: player, gameMode: gameMode)));
        break;
    }
  }

  int _getEarliestBundleYear(final List<AnalyzedGamesBundle> analyzedGamesBundles) {
    return analyzedGamesBundles
        .where((bundle) => bundle.getType() == AnalyzedGamesBundleType.byGrandmasterAndYear)
        .map((bundle) => (bundle as AnalyzedGamesBundleByGrandmasterAndYear).year)
        .reduce(min);
  }
}
