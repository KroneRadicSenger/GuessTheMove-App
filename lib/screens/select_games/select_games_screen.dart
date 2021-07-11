import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/components/header.dart';
import 'package:guess_the_move/model/analyzed_game.dart';
import 'package:guess_the_move/model/analyzed_games_bundle.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/model/player.dart';
import 'package:guess_the_move/repository/analyzed_games_repository.dart';
import 'package:guess_the_move/repository/players_and_bundles_repository.dart';
import 'package:guess_the_move/screens/select_games/components/grandmaster_game_list.dart';
import 'package:guess_the_move/screens/select_games/components/grandmaster_game_list_speed_dial_fab.dart';
import 'package:guess_the_move/screens/select_games/components/search_games_modal_contents.dart';
import 'package:guess_the_move/theme/theme.dart';

class SelectGamesScreen extends StatefulWidget {
  final Player grandmaster;
  final GameModeEnum gameMode;

  SelectGamesScreen({required this.grandmaster, required this.gameMode, Key? key}) : super(key: key);

  @override
  _SelectGamesScreenState createState() => _SelectGamesScreenState();
}

class _SelectGamesScreenState extends State<SelectGamesScreen> {
  AnalyzedGamesBundle? _selectedBundle;
  Future<List<AnalyzedGame>>? _selectedBundleLoadFuture;
  FilterOptions? _filterOptions;

  @override
  Widget build(BuildContext context) => BlocBuilder<UserSettingsBloc, UserSettingsState>(
        builder: (context, state) => Theme(
          data: buildMaterialThemeData(context, state, widget.gameMode),
          child: Container(
            decoration: BoxDecoration(
              gradient: appTheme(context, state.userSettings.themeMode).gameModeThemes[widget.gameMode]!.backgroundGradient,
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Header(),
                    Expanded(
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
                          child: _buildContents(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              floatingActionButton: _buildFloatingActionButton(),
            ),
          ),
        ),
      );

  Widget _buildFloatingActionButton() {
    if (_selectedBundle == null || _selectedBundleLoadFuture == null) {
      return Container();
    }
    return GrandmasterGameListSpeedDialFab(
      grandmaster: widget.grandmaster,
      gameMode: widget.gameMode,
      selectedBundle: _selectedBundle!,
      selectedBundleLoadFuture: _selectedBundleLoadFuture!,
      currentFilterOptions: _filterOptions,
      onSubmitSearch: (filterOptions) => setState(() {
        Navigator.pop(context);
        this._filterOptions = filterOptions;
      }),
    );
  }

  Widget _buildContents() {
    return FutureBuilder<List<AnalyzedGamesBundle>>(
      future: getAnalyzedGamesBundlesForGrandmaster(widget.grandmaster),
      builder: (final context, final snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        if (_selectedBundle == null) {
          _selectedBundle = snapshot.data!.first;
          _selectedBundleLoadFuture = loadAnalyzedGamesInBundle(snapshot.data!.first);
          WidgetsBinding.instance!.addPostFrameCallback((timeStamp) => setState(() {}));
        }

        return GrandmasterGameList(
          grandmaster: widget.grandmaster,
          gameMode: widget.gameMode,
          analyzedGamesBundlesForGrandmaster: snapshot.data!,
          selectedBundle: _selectedBundle!,
          filterOptions: _filterOptions,
          onSelectBundle: (newBundleSelected) => setState(
            () {
              this._selectedBundle = newBundleSelected;
              this._selectedBundleLoadFuture = loadAnalyzedGamesInBundle(newBundleSelected);
              this._filterOptions = null;
            },
          ),
          onUpdateFilterOptions: (filterOptions) => setState(
            () {
              this._filterOptions = filterOptions;
            },
          ),
        );
      },
    );
  }
}
