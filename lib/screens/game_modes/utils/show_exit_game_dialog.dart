import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/theme/theme.dart';

void showExitGameDialog(final BuildContext context, final GameModeEnum gameMode, final UserSettingsState userSettingsState, final Function() onConfirm) {
  final title = gameMode == GameModeEnum.findTheGrandmasterMoves ? 'Spiel abbrechen' : 'Spiel beenden';
  final text = gameMode == GameModeEnum.findTheGrandmasterMoves ? 'Möchtest du das Spiel wirklich abbrechen?' : 'Möchtest du das Spiel wirklich beenden?';

  showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(text),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Nein'),
            style: TextButton.styleFrom(
              primary: appTheme(context, userSettingsState.userSettings.themeMode).textColor.withOpacity(.5),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Ja'),
            style: TextButton.styleFrom(
              primary: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[gameMode]!.accentColor,
            ),
            onPressed: onConfirm,
          ),
        ],
      );
    },
  );
}
