import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/components/utils/show_draggable_modal_bottom_sheet.dart';
import 'package:guess_the_move/model/analyzed_game.dart';
import 'package:guess_the_move/model/analyzed_games_bundle.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/model/player.dart';
import 'package:guess_the_move/screens/select_games/components/last_played_grandmaster_games_modal_contents.dart';
import 'package:guess_the_move/screens/select_games/components/search_games_modal_contents.dart';
import 'package:guess_the_move/theme/theme.dart';

class GrandmasterGameListSpeedDialFab extends StatelessWidget {
  final Player grandmaster;
  final GameModeEnum gameMode;
  final AnalyzedGamesBundle selectedBundle;
  final Future<List<AnalyzedGame>> selectedBundleLoadFuture;
  final FilterOptions? currentFilterOptions;
  final Function(FilterOptions) onSubmitSearch;

  const GrandmasterGameListSpeedDialFab(
      {Key? key,
      required this.grandmaster,
      required this.gameMode,
      required this.selectedBundle,
      required this.selectedBundleLoadFuture,
      required this.currentFilterOptions,
      required this.onSubmitSearch})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserSettingsBloc, UserSettingsState>(
      builder: (context, state) => SpeedDial(
        marginEnd: 18,
        marginBottom: 20,
        icon: Icons.menu,
        activeIcon: Icons.clear,
        // label: Text("Open Speed Dial"),
        // activeLabel: Text("Close Speed Dial"),
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        visible: true,
        closeManually: false,
        renderOverlay: false,
        curve: Curves.bounceIn,
        tooltip: 'Menü',
        heroTag: 'games-menu-speed-dial',
        backgroundColor: appTheme(context, state.userSettings.themeMode).gameModeThemes[gameMode]!.accentColor,
        foregroundColor: appTheme(context, state.userSettings.themeMode).scaffoldBackgroundColor,
        elevation: 8.0,
        shape: CircleBorder(),
        // childMarginBottom: 2,
        // childMarginTop: 2,
        children: [
          SpeedDialChild(
            child: Icon(
              Icons.history,
              color: appTheme(context, state.userSettings.themeMode).scaffoldBackgroundColor,
            ),
            backgroundColor: appTheme(context, state.userSettings.themeMode).gameModeThemes[gameMode]!.accentColor,
            label: 'Zuletzt gespielt',
            labelBackgroundColor: appTheme(context, state.userSettings.themeMode).scaffoldBackgroundColor,
            onTap: () => _showLastPlayedGamesModal(context, state),
          ),
          SpeedDialChild(
            child: Icon(
              Icons.search,
              color: appTheme(context, state.userSettings.themeMode).scaffoldBackgroundColor,
            ),
            backgroundColor: appTheme(context, state.userSettings.themeMode).gameModeThemes[gameMode]!.accentColor,
            label: 'Partie suchen',
            labelBackgroundColor: appTheme(context, state.userSettings.themeMode).scaffoldBackgroundColor,
            onTap: () => _showSearchGamesModal(context, state),
          ),
        ],
      ),
    );
  }

  void _showSearchGamesModal(final BuildContext context, final UserSettingsState state) {
    final title = 'Spielepaket ${selectedBundle.getDisplayName()} durchsuchen';
    showDraggableModalBottomSheet(
        context,
        state,
        title,
        SearchGamesModalContents(
          grandmaster: grandmaster,
          gameMode: gameMode,
          selectedBundle: selectedBundle,
          selectedBundleLoadFuture: selectedBundleLoadFuture,
          currentFilterOptions: currentFilterOptions,
          onSubmitSearch: onSubmitSearch,
        ));
  }

  void _showLastPlayedGamesModal(final BuildContext context, final UserSettingsState state) {
    final title = 'Zuletzt gespielte Spiele von\n${grandmaster.getFirstAndLastName()}';
    showDraggableModalBottomSheet(context, state, title, LastPlayedGrandmasterGamesModalContents(grandmaster: grandmaster, gameMode: gameMode));
  }
}
