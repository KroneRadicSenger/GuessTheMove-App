import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/components/text_with_accent_field.dart';
import 'package:guess_the_move/components/titled_container.dart';
import 'package:guess_the_move/components/utils/show_alert_dialog.dart';
import 'package:guess_the_move/components/utils/show_loading_dialog.dart';
import 'package:guess_the_move/model/analyzed_game.dart';
import 'package:guess_the_move/model/analyzed_games_bundle.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/model/player.dart';
import 'package:guess_the_move/model/summary_data.dart';
import 'package:guess_the_move/repository/analyzed_games_repository.dart';
import 'package:guess_the_move/screens/game_modes/components/summary/game_info_button.dart';
import 'package:guess_the_move/screens/game_modes/components/summary/replay_button.dart';
import 'package:guess_the_move/screens/game_modes/components/summary/summary_points_given_graph.dart';
import 'package:guess_the_move/screens/game_modes/find_the_grandmaster_moves/find_the_grandmaster_moves_screen.dart';
import 'package:guess_the_move/theme/theme.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class GameSummaryBottomArea extends StatelessWidget {
  final String analyzedGameId;
  final AnalyzedGamesBundle analyzedGameOriginBundle;
  final String gamePlayedInfoString;
  final SummaryData summaryData;
  final int playedDateTimestamp;
  final Player whitePlayer;
  final Player blackPlayer;
  final GameModeEnum gameMode;
  final UserSettingsState userSettingsState;
  final EdgeInsets padding;

  const GameSummaryBottomArea(this.analyzedGameId, this.analyzedGameOriginBundle, this.gamePlayedInfoString, this.summaryData, this.whitePlayer, this.blackPlayer, this.gameMode,
      this.userSettingsState, this.playedDateTimestamp,
      {this.padding = const EdgeInsets.symmetric(vertical: 40, horizontal: 20), Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var grandmasterMovesPlayedPercentageString = '-';
    var bestMovesPlayedPercentageString = '-';

    if (summaryData.guessEvaluatedList.isNotEmpty) {
      var grandmasterMovesPlayedPercentage = summaryData.getGrandmasterMovesGuessedAmount() / summaryData.getTotalMovesGuessedAmount() * 100.0;
      grandmasterMovesPlayedPercentageString = grandmasterMovesPlayedPercentage.toString();
      grandmasterMovesPlayedPercentageString = grandmasterMovesPlayedPercentageString.substring(0, min(grandmasterMovesPlayedPercentageString.length, 5)) + '%';

      var bestMovesPlayedPercentage = summaryData.getBestMovesGuessedAmount() / summaryData.getTotalMovesGuessedAmount() * 100.0;
      bestMovesPlayedPercentageString = bestMovesPlayedPercentage.toString();
      bestMovesPlayedPercentageString = bestMovesPlayedPercentageString.substring(0, min(bestMovesPlayedPercentageString.length, 5)) + '%';
    }

    return Padding(
      padding: padding,
      child: TitledContainer(
        title: 'Spielzusammenfassung',
        subtitle: 'Finde die Großmeisterzüge',
        titleSize: 22,
        subtitleSize: 13,
        subtitleSpacing: 6,
        subtitleAboveTitle: true,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (summaryData.guessEvaluatedList.isNotEmpty) SummaryPointsGivenGraph(summaryData: summaryData, gameMode: gameMode, userSettings: userSettingsState.userSettings),
              ReplayButton(
                text: 'Spiel erneut tranieren',
                userSettingsState: userSettingsState,
                gameMode: gameMode,
                onTap: () => _onPressReplayGame(context),
                margin: const EdgeInsets.only(top: 20),
              ),
              GameInfoButton(
                text: 'Spielinformationen anzeigen',
                userSettingsState: userSettingsState,
                gameMode: gameMode,
                onTap: () => _onPressShowGameInfo(context),
                margin: const EdgeInsets.only(top: 10, bottom: 15),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSummaryBox(
                    context,
                    'Erzielte Punkte',
                    [
                      SvgPicture.asset(
                        'assets/svg/two-coins.svg',
                        width: 28,
                        height: 28,
                        color: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[gameMode]!.accentColor,
                      ),
                      Container(width: 10),
                      Text(
                        summaryData.getPointsGivenTotalAmount().toString(),
                        style: TextStyle(
                          color: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[gameMode]!.accentColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                    margin: const EdgeInsets.only(top: 10),
                  )
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSummaryBox(
                    context,
                    'GM Zug gespielt',
                    [
                      Text(
                        grandmasterMovesPlayedPercentageString,
                        style: TextStyle(
                          color: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[gameMode]!.accentColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                    margin: const EdgeInsets.only(top: 15, right: 10),
                  ),
                  _buildSummaryBox(
                    context,
                    'Besten Zug gespielt',
                    [
                      Text(
                        bestMovesPlayedPercentageString,
                        style: TextStyle(
                          color: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[gameMode]!.accentColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                    margin: const EdgeInsets.only(top: 15, left: 10),
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: _buildAnalyzedMoveTypesData(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAnalyzedMoveTypesData(final BuildContext context) {
    return summaryData
        .getMovesGuessesAmountsByAnalyzedMoveType()
        .keys
        .map(
          (final AnalyzedMoveType moveType) => TextWithAccentField(
            gameMode: gameMode,
            text: '${moveType.name} gespielt',
            userSettingsState: userSettingsState,
            accentBoxText: summaryData.getMovesGuessesAmountsByAnalyzedMoveType()[moveType].toString(),
            accentBoxTextBold: true,
            accentBoxInAccentColor: false,
          ),
        )
        .toList();
  }

  Widget _buildSummaryBox(final BuildContext context, final String title, final List<Widget> value,
      {final EdgeInsets margin = const EdgeInsets.symmetric(horizontal: 10, vertical: 15)}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(18)),
          color: appTheme(context, userSettingsState.userSettings.themeMode).cardBackgroundColor,
          /*gradient: LinearGradient(
            colors: [
              appTheme(context, _userSettings.themeMode).scaffoldBackgroundColor,
              appTheme(context, _userSettings.themeMode).cardBackgroundColor,
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),*/
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: appTheme(context, userSettingsState.userSettings.themeMode).textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: value,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onPressReplayGame(final BuildContext context) async {
    showLoadingDialog(context, userSettingsState, 'Das Spiel wird geladen');

    await loadAnalyzedGamesInBundle(analyzedGameOriginBundle);
    final analyzedGame = getAnalyzedGameByBundleAndId(analyzedGameOriginBundle, analyzedGameId);

    Navigator.pop(context);

    if (analyzedGame == null) {
      showAlertDialog(context, 'Fehler', 'Das Spiel konnte nicht geladen werden.');
    } else {
      pushNewScreen(
        context,
        screen: FindTheGrandmasterMovesScreen(analyzedGame: analyzedGame, analyzedGameOriginBundle: analyzedGameOriginBundle),
        withNavBar: false,
        customPageRoute: MaterialPageRoute(builder: (_) => FindTheGrandmasterMovesScreen(analyzedGame: analyzedGame, analyzedGameOriginBundle: analyzedGameOriginBundle)),
      );
    }
  }

  void _onPressShowGameInfo(final BuildContext context) async {
    showAlertDialog(
      context,
      'Spielinformationen',
      '${whitePlayer.getFirstAndLastName()} vs ${blackPlayer.getFirstAndLastName()}\n\n' +
          '$gamePlayedInfoString\n\n' +
          'Gespielt am:\n${germanDateTimeFormatShort.format(DateTime.fromMillisecondsSinceEpoch(playedDateTimestamp))}',
      confirmText: 'Schließen',
    );
  }
}
