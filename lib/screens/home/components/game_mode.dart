import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/theme/theme.dart';

class GameMode extends StatelessWidget {
  final GameModeEnum gameModeEnum;
  final String iconName;
  final Function() onTap;

  GameMode({required this.gameModeEnum, required this.iconName, required this.onTap, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocBuilder<UserSettingsBloc, UserSettingsState>(builder: (context, state) {
        final String assetPath = 'assets/svg/$iconName.svg';

        return Column(
          children: [
            TextButton(
              onPressed: onTap,
              style: TextButton.styleFrom(
                backgroundColor: appTheme(context, state.userSettings.themeMode).gameModeThemes[gameModeEnum]!.primaryColor,
                primary: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                padding: EdgeInsets.zero,
              ),
              child: Padding(
                padding: const EdgeInsets.all(26),
                child: SvgPicture.asset(
                  assetPath,
                  semanticsLabel: 'Spielmodus ${getGameModeShortName(gameModeEnum)}',
                  color: appTheme(context, state.userSettings.themeMode).gameModeThemes[gameModeEnum]!.secondaryColor,
                  width: 80,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
              child: Text(
                getGameModeShortName(gameModeEnum),
                style: TextStyle(color: appTheme(context, state.userSettings.themeMode).textColor),
              ),
            )
          ],
        );
      });
}
