import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/theme/theme.dart';

class AboutElement extends StatelessWidget {
  final String title;
  final List<String> names;

  AboutElement({required this.title, required this.names, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocBuilder<UserSettingsBloc, UserSettingsState>(builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: appTheme(context, state.userSettings.themeMode).cardBackgroundColor,
          ),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          margin: const EdgeInsets.symmetric(vertical: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(color: appTheme(context, state.userSettings.themeMode).gameModeThemes[GameModeEnum.findTheGrandmasterMoves]!.accentColor, fontSize: 18),
              ),
              Container(height: 10),
              ...names.map(
                (element) => Text(
                  element,
                  style: TextStyle(color: appTheme(context, state.userSettings.themeMode).textColor),
                  textAlign: TextAlign.justify,
                ),
              ),
            ],
          ),
        );
      });
}
