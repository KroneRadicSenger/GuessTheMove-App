import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/components/game_subtitle_text.dart';
import 'package:guess_the_move/components/game_title_text.dart';
import 'package:guess_the_move/components/loading_button.dart';
import 'package:guess_the_move/components/utils/show_draggable_modal_bottom_sheet.dart';
import 'package:guess_the_move/model/analyzed_game.dart';
import 'package:guess_the_move/model/analyzed_games_bundle.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/model/player.dart';
import 'package:guess_the_move/model/time_battle_game_played.dart';
import 'package:guess_the_move/repository/analyzed_games_repository.dart';
import 'package:guess_the_move/repository/dao/time_battle_games_played_dao.dart';
import 'package:guess_the_move/screens/game_modes/components/game_highscore_data.dart';
import 'package:guess_the_move/screens/game_modes/time_battle/components/time_battle_game_over_contents.dart';
import 'package:guess_the_move/theme/theme.dart';

class SelectTimeElement extends StatelessWidget {
  final Player grandmaster;
  final AnalyzedGamesBundle analyzedGameOriginBundle;
  final int initialTimeInSeconds;
  final Function(int, Future<List<AnalyzedGame>>) onSelectTime;

  const SelectTimeElement({Key? key, required this.grandmaster, required this.analyzedGameOriginBundle, required this.initialTimeInSeconds, required this.onSelectTime})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserSettingsBloc, UserSettingsState>(
      builder: (context, state) => FutureBuilder<TimeBattleGamePlayed?>(
        future: TimeBattleGamesPlayedDao().getHighscoreGamePlayedByAnalyzedGamesBundleAndInitialTimeInSeconds(analyzedGameOriginBundle, initialTimeInSeconds),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return LoadingButton();
          }

          final timeElementName;
          if (initialTimeInSeconds > 60 && initialTimeInSeconds % 60 == 0) {
            timeElementName = (initialTimeInSeconds ~/ 60).toString() + ' Minuten';
          } else {
            timeElementName = initialTimeInSeconds.toString() + ' Sekunden';
          }

          return TextButton(
            onPressed: () => _onTap(context),
            style: TextButton.styleFrom(
              backgroundColor: appTheme(context, state.userSettings.themeMode).cardBackgroundColor,
              primary: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    flex: 8,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GameTitleText(state, GameModeEnum.timeBattle, timeElementName),
                        ..._buildHighscoreInfo(context, state, snapshot.data),
                      ],
                    ),
                  ),
                  if (snapshot.hasData)
                    IconButton(
                      icon: Icon(
                        Icons.info_outline_rounded,
                        color: appTheme(context, state.userSettings.themeMode).textColor,
                        size: 28,
                      ),
                      onPressed: () => _onTapInfoIcon(context, state, snapshot.data!),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildHighscoreInfo(final BuildContext context, final UserSettingsState userSettingsState, final TimeBattleGamePlayed? highscoreGamePlayed) {
    if (highscoreGamePlayed == null) {
      return [
        GameSubtitleText(userSettingsState, 'Noch nicht gespielt', showBulletPoint: false),
      ];
    }

    return [
      Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Highscore:',
                style: TextStyle(
                  fontSize: 14,
                  color: appTheme(context, userSettingsState.userSettings.themeMode).textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '(${germanDateTimeFormatShort.format(DateTime.fromMillisecondsSinceEpoch(highscoreGamePlayed.playedDateTimestamp))})',
                style: TextStyle(
                  fontSize: 12,
                  color: appTheme(context, userSettingsState.userSettings.themeMode).textColor,
                ),
              ),
            ],
          ),
          Container(width: 20),
          GameHighscoreData(
            userSettingsState: userSettingsState,
            points: highscoreGamePlayed.totalPointsGivenAmount,
            correctMovesPlayedAmount: highscoreGamePlayed.correctMovesPlayedAmount,
            totalMovesPlayedAmount: highscoreGamePlayed.totalMovesPlayedAmount,
          ),
        ],
      ),
    ];
  }

  void _onTap(final BuildContext context) async {
    final gamesInBundleFuture = loadAnalyzedGamesInBundle(analyzedGameOriginBundle);
    onSelectTime(initialTimeInSeconds, gamesInBundleFuture);
  }

  void _onTapInfoIcon(final BuildContext context, final UserSettingsState userSettingsState, final TimeBattleGamePlayed highscoreGamePlayed) {
    showDraggableModalBottomSheet(
      context,
      userSettingsState,
      null,
      TimeBattleGameOverContents(
        titleText: "Highscore Spiel",
        padding: const EdgeInsets.only(bottom: 10),
        analyzedGamesOriginBundle: highscoreGamePlayed.analyzedGameOriginBundle,
        gamesPlayedInfo: highscoreGamePlayed.gamesPlayedInfo,
        gamesSummaryData: highscoreGamePlayed.analyzedGamesPlayedSummaryData,
        playedDateTimestamp: highscoreGamePlayed.playedDateTimestamp,
        userSettingsState: userSettingsState,
        initialTimeInSeconds: initialTimeInSeconds,
        totalMovesGuessed: highscoreGamePlayed.totalMovesPlayedAmount,
        movesGuessedCorrect: highscoreGamePlayed.correctMovesPlayedAmount,
      ),
    );
  }
}
