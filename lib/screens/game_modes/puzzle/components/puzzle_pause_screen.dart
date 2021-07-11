import 'package:cupertino_will_pop_scope/cupertino_will_pop_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/puzzle_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/components/titled_container.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/screens/game_modes/puzzle/components/puzzle_header.dart';
import 'package:guess_the_move/theme/theme.dart';

class PuzzlePauseScreen extends StatelessWidget {
  final PuzzleBloc bloc;
  final UserSettingsState userSettingsState;
  final Function() onResume;
  final Function() onEndGame;
  final int wrongTries;
  final bool wasAlreadySolved;
  final int timePassedInMilliseconds;

  const PuzzlePauseScreen({
    Key? key,
    required this.bloc,
    required this.userSettingsState,
    required this.onResume,
    required this.onEndGame,
    required this.wrongTries,
    required this.wasAlreadySolved,
    required this.timePassedInMilliseconds,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserSettingsBloc, UserSettingsState>(
      builder: (context, userSettingsState) => ConditionalWillPopScope(
        onWillPop: () async {
          onResume();
          return false;
        },
        shouldAddCallbacks: true,
        child: Theme(
          data: buildMaterialThemeData(context, userSettingsState, GameModeEnum.puzzleMode),
          child: Container(
            decoration: BoxDecoration(
              gradient: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[GameModeEnum.puzzleMode]!.backgroundGradient,
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                bottom: false,
                child: _buildContents(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContents() {
    return BlocBuilder<UserSettingsBloc, UserSettingsState>(
      builder: (context, userSettingsState) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PuzzleHeader(
            bloc: bloc,
            onPressHome: onEndGame,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: appTheme(context, userSettingsState.userSettings.themeMode).scaffoldBackgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(30.0),
                  topRight: const Radius.circular(30.0),
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(.2), offset: Offset(0, -3), blurRadius: 4, spreadRadius: 0),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(scaffoldPaddingHorizontal, 50, scaffoldPaddingHorizontal, 0),
                child: TitledContainer.multipleChildren(
                  title: 'Spiel ist pausiert',
                  subtitle: 'Puzzle',
                  subtitleAboveTitle: true,
                  titleSize: 28,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 60, bottom: 10),
                      child: Text(
                        'Zwischenstand',
                        style: TextStyle(fontSize: 25),
                      ),
                    ),
                    _buildTextBoxWithIcon(
                      context,
                      Icon(
                        Icons.timer,
                        size: 40,
                        color: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[GameModeEnum.puzzleMode]!.accentColor,
                      ),
                      '${(timePassedInMilliseconds / 1000).round()}s',
                      'bisher benötigt',
                    ),
                    Expanded(child: Container()),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: onResume,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                'Spiel fortsetzen',
                                style: TextStyle(fontSize: 17),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: onEndGame,
                            style: TextButton.styleFrom(
                              backgroundColor: appTheme(context, userSettingsState.userSettings.themeMode).cardBackgroundColor,
                            ),
                            child: Text(
                              'Spiel beenden',
                              style: TextStyle(color: appTheme(context, userSettingsState.userSettings.themeMode).textColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextBoxWithIcon(final BuildContext context, final Widget icon, final String titleText, final String subTitleText) {
    return Container(
      decoration: BoxDecoration(
        color: appTheme(context, userSettingsState.userSettings.themeMode).cardBackgroundColor,
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          Container(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titleText,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              Text(subTitleText),
            ],
          ),
        ],
      ),
    );
  }
}
