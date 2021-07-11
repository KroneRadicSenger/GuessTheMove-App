import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/components/text_with_accent_field.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/theme/theme.dart';

class StatsGroup extends StatelessWidget {
  final String title;
  final List<TextWithAccentField> stats;
  final GameModeEnum gameMode;

  StatsGroup({required this.title, required this.stats, Key? key, required this.gameMode}) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocBuilder<UserSettingsBloc, UserSettingsState>(
        builder: (context, state) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: appTheme(context, state.userSettings.themeMode).cardBackgroundColor,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text(
                      title,
                      style: TextStyle(color: appTheme(context, state.userSettings.themeMode).gameModeThemes[gameMode]!.accentColor, fontWeight: FontWeight.w600, fontSize: 18),
                    ),
                  ),
                  SizedBox(height: 10),
                  Column(
                    children: stats,
                  )
                ],
              ),
            ),
          );
        },
      );
}
