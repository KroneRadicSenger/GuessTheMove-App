import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/puzzle_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/components/titled_container.dart';
import 'package:guess_the_move/components/utils/show_loading_dialog.dart';
import 'package:guess_the_move/main.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/repository/analyzed_games_repository.dart';
import 'package:guess_the_move/repository/players_and_bundles_repository.dart';
import 'package:guess_the_move/screens/game_modes/puzzle/puzzle_screen.dart';
import 'package:guess_the_move/screens/select_grandmaster/select_grandmaster_screen.dart';
import 'package:guess_the_move/screens/settings/utils/show_confirmation_dialog.dart';
import 'package:guess_the_move/theme/theme.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class Content extends StatelessWidget {
  @override
  Widget build(BuildContext context) => BlocBuilder<UserSettingsBloc, UserSettingsState>(
        builder: (context, state) => Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: appTheme(context, state.userSettings.themeMode).scaffoldBackgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(30.0),
                topRight: const Radius.circular(30.0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(scaffoldPaddingHorizontal, 40, scaffoldPaddingHorizontal, 0),
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: TitledContainer.multipleChildren(
                  title: 'Wie möchtest du spielen?',
                  subtitle: 'Puzzle',
                  subtitleAboveTitle: true,
                  titleSize: 20,
                  showBackArrow: true,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(height: 40),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _onPressQuickPlay(context, state),
                            icon: Icon(Icons.shuffle, size: 28),
                            label: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                'Schnelles Spiel',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(height: 15),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => SelectGrandmasterScreen(gameMode: GameModeEnum.puzzleMode)),
                              );
                            },
                            icon: Icon(Icons.videogame_asset, size: 24),
                            label: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              child: Text(
                                'Puzzles in Spielepaket',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  void _onPressQuickPlay(final BuildContext context, final UserSettingsState state) async {
    showLoadingDialog(context, state, 'Das Spiel wird geladen');

    // TODO Check if puzzle exists in chosen bundle, if not, continue with next bundle
    // TODO if no bundle with puzzle exists, show error dialog

    final allAnalyzedGamesBundles = await getAllAnalyzedGamesBundles();

    // get a random analyzed games bundle starting index
    final randomAnalyzedGamesBundleIndex = MyApp.random.nextInt(allAnalyzedGamesBundles.length);

    var randomAnalyzedGamesBundle;
    var allGamesInBundle;

    var bundleWithPuzzlesFound = false;

    // Search for first bundle that has at least one puzzle
    for (var tries = 0; tries < allAnalyzedGamesBundles.length; tries++) {
      final analyzedGamesBundleIndex = (randomAnalyzedGamesBundleIndex + tries) % (allAnalyzedGamesBundles.length);
      randomAnalyzedGamesBundle = allAnalyzedGamesBundles[analyzedGamesBundleIndex];
      allGamesInBundle = await loadAnalyzedGamesInBundle(randomAnalyzedGamesBundle);
      if (PuzzleBloc.hasPuzzle(allGamesInBundle)) {
        bundleWithPuzzlesFound = true;
        break;
      }
    }

    if (!bundleWithPuzzlesFound) {
      Navigator.of(context, rootNavigator: true).pop();
      showConfirmationDialog(
        context,
        GameModeEnum.puzzleMode,
        state,
        () => Navigator.of(context).pop(),
        'Fehler',
        'Es konnte kein Spielepaket mit einem passenden Puzzle gefunden werden.',
        onlyConfirm: true,
        confirmationText: 'Ok',
      );
      return;
    }

    Navigator.of(context, rootNavigator: true).pop();

    pushNewScreen(
      context,
      screen: PuzzleScreen(analyzedGameOriginBundle: randomAnalyzedGamesBundle, analyzedGamesInBundle: allGamesInBundle),
      withNavBar: false,
      customPageRoute: MaterialPageRoute(
        builder: (_) => PuzzleScreen(analyzedGameOriginBundle: randomAnalyzedGamesBundle, analyzedGamesInBundle: allGamesInBundle),
      ),
    );
  }
}
