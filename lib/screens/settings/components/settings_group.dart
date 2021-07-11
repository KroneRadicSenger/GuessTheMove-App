import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/theme/theme.dart';

class SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> settings;

  SettingsGroup({required this.title, required this.settings});

  @override
  Widget build(BuildContext context) => BlocBuilder<UserSettingsBloc, UserSettingsState>(builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: appTheme(context, state.userSettings.themeMode).cardBackgroundColor,
          ),
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text(
                    title,
                    style: TextStyle(
                        color: appTheme(context, state.userSettings.themeMode).gameModeThemes[GameModeEnum.findTheGrandmasterMoves]!.accentColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 18),
                  ),
                ),
                Column(
                  children: settings,
                )
              ],
            ),
          ),
        );
      });
}
