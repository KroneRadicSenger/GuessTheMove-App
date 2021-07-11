import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/theme/theme.dart';

class GameInfoButton extends StatelessWidget {
  final String text;
  final UserSettingsState userSettingsState;
  final GameModeEnum gameMode;
  final Function() onTap;
  final EdgeInsets margin;

  GameInfoButton({
    required this.text,
    required this.userSettingsState,
    required this.gameMode,
    required this.onTap,
    this.margin = const EdgeInsets.only(left: 10, right: 10),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: appTheme(context, userSettingsState.userSettings.themeMode).cardBackgroundColor,
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              color: appTheme(context, userSettingsState.userSettings.themeMode).textColor,
            ),
            Container(width: 10),
            Text(
              text,
              style: TextStyle(color: appTheme(context, userSettingsState.userSettings.themeMode).textColor),
            ),
          ],
        ),
      ),
    );
  }
}
