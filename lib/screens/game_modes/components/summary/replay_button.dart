import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/theme/theme.dart';

class ReplayButton extends StatelessWidget {
  final String text;
  final UserSettingsState userSettingsState;
  final GameModeEnum gameMode;
  final Function() onTap;
  final EdgeInsets margin;
  final EdgeInsets padding;

  ReplayButton({
    required this.text,
    required this.userSettingsState,
    required this.gameMode,
    required this.onTap,
    this.margin = const EdgeInsets.only(left: 10, right: 10, bottom: 10),
    this.padding = const EdgeInsets.symmetric(vertical: 10),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[gameMode]!.accentColor,
        ),
        onPressed: onTap,
        child: Container(
          padding: padding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.replay),
              Container(width: 10),
              Text(text),
            ],
          ),
        ),
      ),
    );
  }
}
