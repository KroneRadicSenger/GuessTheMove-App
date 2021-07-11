import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/screens/settings/utils/show_single_choice_dialog.dart';
import 'package:guess_the_move/theme/theme.dart';

class SettingsMenuSelector extends StatelessWidget {
  final String title;
  final String current;
  final Function(String) onSelect;
  final List<String> menuActions;

  SettingsMenuSelector({required this.title, required this.current, required this.menuActions, required this.onSelect});

  @override
  Widget build(BuildContext context) => BlocBuilder<UserSettingsBloc, UserSettingsState>(builder: (context, userSettingsState) {
        return TextButton(
          onPressed: () => showSingleChoiceDialog(context, title, menuActions, current, onSelect),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[GameModeEnum.findTheGrandmasterMoves]!.accentColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Container(width: 10),
                Expanded(
                  child: Text(
                    current,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: appTheme(context, userSettingsState.userSettings.themeMode).textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      });
}
