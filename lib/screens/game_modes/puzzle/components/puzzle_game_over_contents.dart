import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/components/game_subtitle_text.dart';
import 'package:guess_the_move/components/game_title_text.dart';
import 'package:guess_the_move/components/titled_container.dart';
import 'package:guess_the_move/components/utils/show_alert_dialog.dart';
import 'package:guess_the_move/components/utils/show_loading_dialog.dart';
import 'package:guess_the_move/model/analyzed_game.dart';
import 'package:guess_the_move/model/analyzed_games_bundle.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/model/puzzle_game_played.dart';
import 'package:guess_the_move/repository/analyzed_games_repository.dart';
import 'package:guess_the_move/repository/dao/puzzle_games_played_dao.dart';
import 'package:guess_the_move/screens/game_modes/components/game_highscore_data.dart';
import 'package:guess_the_move/screens/game_modes/components/summary/replay_button.dart';
import 'package:guess_the_move/screens/game_modes/puzzle/puzzle_screen.dart';
import 'package:guess_the_move/theme/theme.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class PuzzleGameOverContents extends StatelessWidget {
  final String? titleText;
  final EdgeInsets padding;
  final AnalyzedGamesBundle analyzedGamesOriginBundle;
  final List<PuzzlePlayed> puzzlesPlayed;
  final int playedDateTimestamp;
  final UserSettingsState userSettingsState;

  PuzzleGameOverContents(
      {this.titleText = 'Spiel beendet',
      this.padding = const EdgeInsets.symmetric(vertical: 20),
      required this.analyzedGamesOriginBundle,
      required this.puzzlesPlayed,
      required this.playedDateTimestamp,
      required this.userSettingsState,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: TitledContainer(
        title: titleText,
        titleSize: 22,
        subtitle: 'Puzzle',
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
                gameMode: GameModeEnum.puzzleMode,
                onTap: () => _onTapReplayButton(context),
              ),
              _buildPuzzlesPlayed(context),
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
              color: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[GameModeEnum.puzzleMode]!.accentColor,
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
    final pointsScore = getPuzzleGamePointsScore(puzzlesPlayed);
    final movesGuessedCorrect = getPuzzleGameMovesGuessedCorrect(puzzlesPlayed);
    final totalMovesGuessed = getPuzzleGameTotalMovesGuessed(puzzlesPlayed);

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
    final pointsScore = getPuzzleGamePointsScore(puzzlesPlayed);

    return FutureBuilder<PuzzleGamePlayed?>(
      future: PuzzleGamesPlayedDao().getHighscoreGamePlayedByAnalyzedGamesBundle(analyzedGamesOriginBundle),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return CircularProgressIndicator();
        }

        final newHighscoreReached = !snapshot.hasData || pointsScore >= getPuzzleGamePointsScore(snapshot.data!.puzzlesPlayed);

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

        final highscorePointsScore = getPuzzleGamePointsScore(snapshot.data!.puzzlesPlayed);
        final highscoreCorrectMovesPlayedAmount = getPuzzleGameMovesGuessedCorrect(snapshot.data!.puzzlesPlayed);
        final highscoreTotalMovesPlayedAmount = getPuzzleGameTotalMovesGuessed(snapshot.data!.puzzlesPlayed);

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
              points: highscorePointsScore,
              correctMovesPlayedAmount: highscoreCorrectMovesPlayedAmount,
              totalMovesPlayedAmount: highscoreTotalMovesPlayedAmount,
            ),
          ],
        );
      },
    );
  }

  Widget _buildPuzzlesPlayed(final BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              'Gespielte Puzzles',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: appTheme(context, userSettingsState.userSettings.themeMode).textColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Container(height: 10),
          ..._builPuzzlesPlayedBoxes(context),
        ],
      ),
    );
  }

  List<Widget> _builPuzzlesPlayedBoxes(final BuildContext context) {
    return puzzlesPlayed.map((puzzle) {
      final fullMoveNumber = puzzle.puzzleMove.ply ~/ 2;
      final turnText = puzzle.puzzleMove.turn == GrandmasterSide.white ? 'Weiß' : 'Schwarz';
      final puzzleTypeText = puzzle.puzzleMove.actualMove.moveType == AnalyzedMoveType.critical
          ? AnalyzedMoveType.critical.name
          : 'Matt in ${puzzle.puzzleMove.actualMove.signedCPScore.substring(1, puzzle.puzzleMove.actualMove.signedCPScore.length)}';

      final titleText = '${puzzle.gamePlayedInfo.whitePlayer.getFirstAndLastName()} vs ${puzzle.gamePlayedInfo.blackPlayer.getFirstAndLastName()}\n'
          'Zug $fullMoveNumber $turnText ($puzzleTypeText)';

      return Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: appTheme(context, userSettingsState.userSettings.themeMode).cardBackgroundColor,
        ),
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GameTitleText(
              userSettingsState,
              GameModeEnum.puzzleMode,
              titleText,
              textAlign: TextAlign.center,
            ),
            Container(height: 10),
            GameSubtitleText(userSettingsState, puzzle.gamePlayedInfo.gameInfoString),
            if (puzzle.gamePlayedInfo.whitePlayerRating != '-') GameSubtitleText(userSettingsState, 'ELO Weiß: ${puzzle.gamePlayedInfo.whitePlayerRating}'),
            if (puzzle.gamePlayedInfo.blackPlayerRating != '-') GameSubtitleText(userSettingsState, 'ELO Schwarz: ${puzzle.gamePlayedInfo.blackPlayerRating}'),
            Container(height: 20),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: TextButton.icon(
                    icon: Icon(Icons.analytics_outlined, color: appTheme(context, userSettingsState.userSettings.themeMode).scaffoldBackgroundColor),
                    onPressed: () => _onShowPuzzlePlayedSummary(context, puzzle),
                    style: TextButton.styleFrom(
                      backgroundColor: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[GameModeEnum.puzzleMode]!.accentColor,
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
    }).toList();
  }

  void _onTapReplayButton(final BuildContext context) async {
    showLoadingDialog(context, userSettingsState, 'Das Spiel wird geladen');

    final allGamesInBundle = await loadAnalyzedGamesInBundle(analyzedGamesOriginBundle);

    Navigator.pop(context);

    if (allGamesInBundle.isEmpty) {
      showAlertDialog(context, 'Fehler', 'Das Spiel konnte nicht geladen werden.');
      return;
    }

    pushNewScreen(
      context,
      screen: PuzzleScreen(analyzedGameOriginBundle: analyzedGamesOriginBundle, analyzedGamesInBundle: allGamesInBundle),
      withNavBar: false,
      customPageRoute: MaterialPageRoute(
        builder: (_) => PuzzleScreen(analyzedGameOriginBundle: analyzedGamesOriginBundle, analyzedGamesInBundle: allGamesInBundle),
      ),
    );
  }

  void _onShowPuzzlePlayedSummary(final BuildContext context, final PuzzlePlayed puzzle) {
    final tipsUsedAmount = (puzzle.showPieceTypeTipUsed ? 1 : 0) + (puzzle.showActualPieceTipUsed ? 1 : 0) + (puzzle.showActualMoveTipUsed ? 1 : 0);

    var evaluation = '' + 'Falsche Versuche: ${puzzle.wrongTries}\n' + 'Tipps genutzt: $tipsUsedAmount / 3\n';

    if (puzzle.wasCorrectMovePlayed()) {
      final secondsNeeded = (puzzle.timeNeededInMilliseconds! / 1000).toString().split('.');
      final secondsNeededTrimmed = secondsNeeded[0] + '.' + (secondsNeeded.length > 1 ? secondsNeeded[1].substring(0, min(secondsNeeded[1].length, 2)) : '') + 's';

      evaluation += ''
              'Korrekten Zug gespielt nach $secondsNeededTrimmed \n' +
          'Punkte erhalten: ${puzzle.pointsGiven}';
    } else {
      evaluation += 'Korrekten Zug nicht gefunden';
    }

    showAlertDialog(
      context,
      'Puzzle Auswertung',
      'Spielepaket:\n${analyzedGamesOriginBundle.getInfoText()}\n\n' +
          '$evaluation\n\n' +
          'Gespielt am:\n${germanDateTimeFormatShort.format(DateTime.fromMillisecondsSinceEpoch(playedDateTimestamp))}',
      confirmText: 'Schließen',
    );
  }
}
