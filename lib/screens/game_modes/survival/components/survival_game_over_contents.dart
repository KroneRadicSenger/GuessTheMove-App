import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/components/game_subtitle_text.dart';
import 'package:guess_the_move/components/game_title_text.dart';
import 'package:guess_the_move/components/titled_container.dart';
import 'package:guess_the_move/components/utils/show_alert_dialog.dart';
import 'package:guess_the_move/components/utils/show_draggable_modal_bottom_sheet.dart';
import 'package:guess_the_move/components/utils/show_loading_dialog.dart';
import 'package:guess_the_move/main.dart';
import 'package:guess_the_move/model/analyzed_game.dart';
import 'package:guess_the_move/model/analyzed_games_bundle.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/model/game_played_info.dart';
import 'package:guess_the_move/model/player.dart';
import 'package:guess_the_move/model/summary_data.dart';
import 'package:guess_the_move/model/survival_game_played.dart';
import 'package:guess_the_move/repository/analyzed_games_repository.dart';
import 'package:guess_the_move/repository/dao/survival_games_played_dao.dart';
import 'package:guess_the_move/screens/game_modes/components/game_highscore_data.dart';
import 'package:guess_the_move/screens/game_modes/components/summary/game_info_button.dart';
import 'package:guess_the_move/screens/game_modes/components/summary/replay_button.dart';
import 'package:guess_the_move/screens/game_modes/components/summary/summary_bottom_area.dart';
import 'package:guess_the_move/screens/game_modes/survival/survival_screen.dart';
import 'package:guess_the_move/theme/theme.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class SurvivalGameOverContents extends StatelessWidget {
  final String? titleText;
  final EdgeInsets padding;
  final AnalyzedGamesBundle analyzedGamesOriginBundle;
  final List<AnalyzedGame>? analyzedGamesPlayed;
  final List<GamePlayedInfo>? gamesPlayedInfo;
  final List<SummaryData> gamesSummaryData;
  final int playedDateTimestamp;
  final UserSettingsState userSettingsState;
  final int amountLives;
  final int totalMovesGuessed;
  final int movesGuessedCorrect;

  SurvivalGameOverContents(
      {this.titleText = 'Du hast keine Leben mehr',
      this.padding = const EdgeInsets.symmetric(vertical: 20),
      required this.analyzedGamesOriginBundle,
      this.analyzedGamesPlayed,
      this.gamesPlayedInfo,
      required this.gamesSummaryData,
      required this.playedDateTimestamp,
      required this.userSettingsState,
      required this.amountLives,
      required this.totalMovesGuessed,
      required this.movesGuessedCorrect,
      Key? key})
      : assert(analyzedGamesPlayed != null || gamesPlayedInfo != null, 'Either analyzed games played or games played info must not be null!'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: TitledContainer(
        title: titleText,
        titleSize: 22,
        subtitle: 'Überleben',
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
              _buildGameOverResults(context),
              ReplayButton(
                text: 'Nochmal spielen',
                userSettingsState: userSettingsState,
                gameMode: GameModeEnum.survivalMode,
                onTap: () => _onTapReplayButton(context),
              ),
              GameInfoButton(
                text: 'Spielinformationen anzeigen',
                userSettingsState: userSettingsState,
                gameMode: GameModeEnum.survivalMode,
                onTap: () => _onPressShowGameInfo(context),
                margin: const EdgeInsets.only(bottom: 15, left: 10, right: 10),
              ),
              _buildGamesPlayed(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameOverResults(final BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(18)),
        color: appTheme(context, userSettingsState.userSettings.themeMode).cardBackgroundColor,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[GameModeEnum.survivalMode]!.accentColor,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: _buildScoreBoxContents(context),
            ),
          ),
          Container(height: 10),
          Container(
            decoration: BoxDecoration(
              color: appTheme(context, userSettingsState.userSettings.themeMode).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: _buildHighscoreBoxContents(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBoxContents(final BuildContext context) {
    final pointsScore = gamesSummaryData.map((d) => d.getPointsGivenTotalAmount()).reduce((value, element) => value + element);

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Ergebnis',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: appTheme(context, userSettingsState.userSettings.themeMode).scaffoldBackgroundColor),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset('assets/svg/two-coins.svg', width: 20, height: 20, color: appTheme(context, userSettingsState.userSettings.themeMode).scaffoldBackgroundColor),
                Container(
                  margin: const EdgeInsets.only(left: 10),
                  child: Text(
                    '$pointsScore',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: appTheme(context, userSettingsState.userSettings.themeMode).scaffoldBackgroundColor,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset('assets/svg/confirmed.svg', width: 18, height: 18, color: appTheme(context, userSettingsState.userSettings.themeMode).scaffoldBackgroundColor),
                Container(
                  margin: const EdgeInsets.only(left: 10),
                  child: Text(
                    '$movesGuessedCorrect / $totalMovesGuessed',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: appTheme(context, userSettingsState.userSettings.themeMode).scaffoldBackgroundColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHighscoreBoxContents(final BuildContext context) {
    final pointsScore = gamesSummaryData.map((d) => d.getPointsGivenTotalAmount()).reduce((value, element) => value + element);

    return FutureBuilder<SurvivalGamePlayed?>(
      future: SurvivalGamesPlayedDao().getHighscoreGamePlayedByAnalyzedGamesBundleAndAmountLives(analyzedGamesOriginBundle, amountLives),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return CircularProgressIndicator();
        }

        final newHighscoreReached = !snapshot.hasData || pointsScore >= snapshot.data!.totalPointsGivenAmount;

        if (newHighscoreReached) {
          return Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/svg/stars-stack.svg', width: 20, height: 20, color: appTheme(context, userSettingsState.userSettings.themeMode).textColor),
              Container(
                margin: const EdgeInsets.only(left: 10),
                child: Text('Neuer Highscore!'),
              )
            ],
          );
        }

        return Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Highscore'),
                Text(
                  '(${germanDateTimeFormatShort.format(DateTime.fromMillisecondsSinceEpoch(snapshot.data!.playedDateTimestamp))})',
                  style: TextStyle(fontSize: 10),
                ),
              ],
            ),
            GameHighscoreData(
              userSettingsState: userSettingsState,
              points: snapshot.data!.totalPointsGivenAmount,
              correctMovesPlayedAmount: snapshot.data!.correctMovesPlayedAmount,
              totalMovesPlayedAmount: snapshot.data!.totalMovesPlayedAmount,
            ),
          ],
        );
      },
    );
  }

  Widget _buildGamesPlayed(final BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              'Gespielte Partien',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: appTheme(context, userSettingsState.userSettings.themeMode).textColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Container(height: 10),
          ..._buildGamesPlayedBoxes(context),
        ],
      ),
    );
  }

  List<Widget> _buildGamesPlayedBoxes(final BuildContext context) {
    if (analyzedGamesPlayed != null) {
      return analyzedGamesPlayed!.map((game) {
        return _buildGamePlayedBox(context, analyzedGamesPlayed!.indexOf(game), game.whitePlayer, game.blackPlayer, [
          GameTitleText(userSettingsState, GameModeEnum.survivalMode, '${game.whitePlayer.getFirstAndLastName()} vs ${game.blackPlayer.getFirstAndLastName()}'),
          GameSubtitleText(userSettingsState, game.gameAnalysis.opening.name.toString()),
          GameSubtitleText(userSettingsState, game.gameInfo.toString()),
          if (game.whitePlayerRating != '-') GameSubtitleText(userSettingsState, 'ELO Weiß: ${game.whitePlayerRating}'),
          if (game.blackPlayerRating != '-') GameSubtitleText(userSettingsState, 'ELO Schwarz: ${game.blackPlayerRating}'),
        ]);
      }).toList();
    }

    return gamesPlayedInfo!.map((gamePlayedInfo) {
      return _buildGamePlayedBox(context, gamesPlayedInfo!.indexOf(gamePlayedInfo), gamePlayedInfo.whitePlayer, gamePlayedInfo.blackPlayer, [
        GameTitleText(userSettingsState, GameModeEnum.survivalMode, '${gamePlayedInfo.whitePlayer.getFirstAndLastName()} vs ${gamePlayedInfo.blackPlayer.getFirstAndLastName()}'),
        GameSubtitleText(userSettingsState, gamePlayedInfo.gameInfoString),
        if (gamePlayedInfo.whitePlayerRating != '-') GameSubtitleText(userSettingsState, 'ELO Weiß: ${gamePlayedInfo.whitePlayerRating}'),
        if (gamePlayedInfo.blackPlayerRating != '-') GameSubtitleText(userSettingsState, 'ELO Schwarz: ${gamePlayedInfo.blackPlayerRating}'),
      ]);
    }).toList();
  }

  Widget _buildGamePlayedBox(final BuildContext context, final int gameIndex, final Player whitePlayer, final Player blackPlayer, final List<Widget> gameTexts) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: appTheme(context, userSettingsState.userSettings.themeMode).cardBackgroundColor,
      ),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...gameTexts,
          Container(height: 20),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: TextButton.icon(
                  icon: Icon(Icons.analytics_outlined, color: appTheme(context, userSettingsState.userSettings.themeMode).scaffoldBackgroundColor),
                  onPressed: () => _onShowGamePlayedSummary(context, gameIndex, whitePlayer, blackPlayer),
                  style: TextButton.styleFrom(
                    backgroundColor: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[GameModeEnum.survivalMode]!.accentColor,
                    primary: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  label: Text('Auswertung anzeigen', style: TextStyle(color: appTheme(context, userSettingsState.userSettings.themeMode).scaffoldBackgroundColor)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onTapReplayButton(final BuildContext context) async {
    showLoadingDialog(context, userSettingsState, 'Das Spiel wird geladen');

    final allGamesInBundle = await loadAnalyzedGamesInBundle(analyzedGamesOriginBundle);

    Navigator.pop(context);

    if (allGamesInBundle.isEmpty) {
      showAlertDialog(context, 'Fehler', 'Das Spiel konnte nicht geladen werden.');
      return;
    }

    var newRandomGame = allGamesInBundle[MyApp.random.nextInt(allGamesInBundle.length)];

    pushNewScreen(
      context,
      screen: SurvivalScreen(
        analyzedGame: newRandomGame,
        analyzedGameOriginBundle: analyzedGamesOriginBundle,
        amountLives: amountLives,
      ),
      withNavBar: false,
      customPageRoute: MaterialPageRoute(
        builder: (_) => SurvivalScreen(
          analyzedGame: newRandomGame,
          analyzedGameOriginBundle: analyzedGamesOriginBundle,
          amountLives: amountLives,
        ),
      ),
    );
  }

  void _onPressShowGameInfo(final BuildContext context) {
    showAlertDialog(
      context,
      'Spielinformationen',
      'Spielepaket:\n${analyzedGamesOriginBundle.getInfoText()}\n\n' +
          'Anzahl Leben:\n$amountLives\n\n' +
          'Gespielt am:\n${germanDateTimeFormatShort.format(DateTime.fromMillisecondsSinceEpoch(playedDateTimestamp))}',
      confirmText: 'Schließen',
    );
  }

  void _onShowGamePlayedSummary(final BuildContext context, final int gameIndex, final Player whitePlayer, final Player blackPlayer) {
    final analyzedGameId = analyzedGamesPlayed != null ? analyzedGamesPlayed![gameIndex].id : gamesPlayedInfo![gameIndex].analyzedGameId;
    final gameInfo = analyzedGamesPlayed != null ? analyzedGamesPlayed![gameIndex].gameInfo.toString() : gamesPlayedInfo![gameIndex].gameInfoString;

    showDraggableModalBottomSheet(
      context,
      userSettingsState,
      null,
      GameSummaryBottomArea(
        analyzedGameId,
        analyzedGamesOriginBundle,
        gameInfo,
        gamesSummaryData[gameIndex],
        whitePlayer,
        blackPlayer,
        GameModeEnum.survivalMode,
        userSettingsState,
        playedDateTimestamp,
        padding: const EdgeInsets.symmetric(horizontal: 20),
      ),
    );
  }
}
