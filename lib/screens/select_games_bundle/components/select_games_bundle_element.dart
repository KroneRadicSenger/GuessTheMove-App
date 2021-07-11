import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/puzzle_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/components/game_subtitle_text.dart';
import 'package:guess_the_move/components/game_title_text.dart';
import 'package:guess_the_move/components/loading_button.dart';
import 'package:guess_the_move/components/utils/show_draggable_modal_bottom_sheet.dart';
import 'package:guess_the_move/components/utils/show_loading_dialog.dart';
import 'package:guess_the_move/model/analyzed_game.dart';
import 'package:guess_the_move/model/analyzed_games_bundle.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/model/player.dart';
import 'package:guess_the_move/model/puzzle_game_played.dart';
import 'package:guess_the_move/repository/analyzed_games_repository.dart';
import 'package:guess_the_move/repository/dao/puzzle_games_played_dao.dart';
import 'package:guess_the_move/screens/game_modes/components/game_highscore_data.dart';
import 'package:guess_the_move/screens/game_modes/puzzle/components/puzzle_game_over_contents.dart';
import 'package:guess_the_move/screens/game_modes/puzzle/puzzle_screen.dart';
import 'package:guess_the_move/screens/select_lives/select_lives_screen.dart';
import 'package:guess_the_move/screens/select_time/select_time_screen.dart';
import 'package:guess_the_move/screens/settings/utils/show_confirmation_dialog.dart';
import 'package:guess_the_move/theme/theme.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class SelectGamesBundleElement extends StatelessWidget {
  final Player grandmaster;
  final AnalyzedGamesBundle bundle;
  final GameModeEnum gameMode;

  const SelectGamesBundleElement({Key? key, required this.grandmaster, required this.bundle, required this.gameMode}) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocBuilder<UserSettingsBloc, UserSettingsState>(
        builder: (context, state) {
          return TextButton(
            onPressed: () => _onTap(context, state),
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
              child: _buildContents(context, state),
            ),
          );
        },
      );

  Widget _buildContents(final BuildContext context, final UserSettingsState state) {
    if (gameMode != GameModeEnum.puzzleMode) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GameTitleText(state, gameMode, bundle.getDisplayName()),
          GameSubtitleText(state, bundle.getInfoText(), showBulletPoint: false),
        ],
      );
    }

    return FutureBuilder<PuzzleGamePlayed?>(
      future: PuzzleGamesPlayedDao().getHighscoreGamePlayedByAnalyzedGamesBundle(bundle),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return LoadingButton();
        }
        return Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              flex: 8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GameTitleText(state, gameMode, bundle.getDisplayName()),
                  GameSubtitleText(state, bundle.getInfoText(), showBulletPoint: false),
                  Container(height: 10),
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
        );
      },
    );
  }

  void _onTap(final BuildContext context, final UserSettingsState userSettingsState) async {
    switch (gameMode) {
      case GameModeEnum.findTheGrandmasterMoves:
        throw StateError('Unsupported gamemode');
      case GameModeEnum.timeBattle:
        pushNewScreen(
          context,
          screen: SelectTimeScreen(
            grandmaster: grandmaster,
            analyzedGameOriginBundle: bundle,
          ),
          customPageRoute: MaterialPageRoute(
            builder: (_) => SelectTimeScreen(
              grandmaster: grandmaster,
              analyzedGameOriginBundle: bundle,
            ),
          ),
        );
        break;
      case GameModeEnum.survivalMode:
        pushNewScreen(
          context,
          screen: SelectLivesScreen(
            grandmaster: grandmaster,
            analyzedGameOriginBundle: bundle,
          ),
          customPageRoute: MaterialPageRoute(
            builder: (_) => SelectLivesScreen(
              grandmaster: grandmaster,
              analyzedGameOriginBundle: bundle,
            ),
          ),
        );
        break;
      case GameModeEnum.puzzleMode:
        showLoadingDialog(context, userSettingsState, 'Das Spiel wird geladen');

        final allGamesInBundle = await loadAnalyzedGamesInBundle(bundle);

        if (!PuzzleBloc.hasPuzzle(allGamesInBundle)) {
          Navigator.of(context, rootNavigator: true).pop();
          showConfirmationDialog(
            context,
            gameMode,
            userSettingsState,
            () {},
            'Fehler',
            'In diesem Spielepaket konnte kein passendes Puzzle gefunden werden.',
            onlyConfirm: true,
            confirmationText: 'Ok',
          );
          return;
        }

        Navigator.of(context, rootNavigator: true).pop();

        pushNewScreen(
          context,
          screen: PuzzleScreen(analyzedGameOriginBundle: bundle, analyzedGamesInBundle: allGamesInBundle),
          withNavBar: false,
          customPageRoute: MaterialPageRoute(
            builder: (_) => PuzzleScreen(analyzedGameOriginBundle: bundle, analyzedGamesInBundle: allGamesInBundle),
          ),
        );
        break;
    }
  }

  List<Widget> _buildHighscoreInfo(final BuildContext context, final UserSettingsState userSettingsState, final PuzzleGamePlayed? highscoreGamePlayed) {
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
            points: getPuzzleGamePointsScore(highscoreGamePlayed.puzzlesPlayed),
            correctMovesPlayedAmount: getPuzzleGameMovesGuessedCorrect(highscoreGamePlayed.puzzlesPlayed),
            totalMovesPlayedAmount: getPuzzleGameTotalMovesGuessed(highscoreGamePlayed.puzzlesPlayed),
          ),
        ],
      ),
    ];
  }

  void _onTapInfoIcon(final BuildContext context, final UserSettingsState userSettingsState, final PuzzleGamePlayed highscoreGamePlayed) {
    showDraggableModalBottomSheet(
      context,
      userSettingsState,
      null,
      PuzzleGameOverContents(
        titleText: 'Highscore Spiel',
        padding: const EdgeInsets.only(bottom: 10),
        analyzedGamesOriginBundle: highscoreGamePlayed.analyzedGameOriginBundle,
        puzzlesPlayed: highscoreGamePlayed.puzzlesPlayed,
        playedDateTimestamp: highscoreGamePlayed.playedDateTimestamp,
        userSettingsState: userSettingsState,
      ),
    );
  }
}
