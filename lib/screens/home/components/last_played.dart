import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/theme/theme.dart';

class LastPlayed extends StatelessWidget {
  final GameModeEnum gameModeEnum;
  final String iconName;
  final Widget title;
  final String gameInfo;
  final Function() onTap;

  LastPlayed({required this.gameModeEnum, required this.iconName, required this.title, required this.gameInfo, required this.onTap, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocBuilder<UserSettingsBloc, UserSettingsState>(builder: (context, state) {
        final String assetPath = 'assets/svg/$iconName.svg';
        return TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            backgroundColor: appTheme(context, state.userSettings.themeMode).gameModeThemes[gameModeEnum]!.primaryColor,
            primary: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            padding: EdgeInsets.zero,
          ),
          child: Column(
            children: [
              Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        padding: const EdgeInsets.all(8.0),
                        child: SvgPicture.asset(
                          assetPath,
                          semanticsLabel: 'Spielmodus ${getGameModeShortName(gameModeEnum)}',
                          color: appTheme(context, state.userSettings.themeMode).gameModeThemes[gameModeEnum]!.secondaryColor,
                        ),
                      ),
                      Container(
                        width: 80,
                        child: Text(
                          getGameModeShortName(gameModeEnum),
                          style: TextStyle(
                            color: appTheme(context, state.userSettings.themeMode).gameModeThemes[gameModeEnum]!.secondaryColor,
                          ),
                          textScaleFactor: 0.9,
                        ),
                      ),
                    ],
                  )),
              Container(
                height: 90,
                width: 120,
                margin: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                  color: appTheme(context, state.userSettings.themeMode).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    title,
                    Text(
                      gameInfo,
                      style: TextStyle(
                        color: appTheme(context, state.userSettings.themeMode).textColor,
                        fontWeight: FontWeight.w300,
                      ),
                      textAlign: TextAlign.center,
                      textScaleFactor: 0.7,
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      });
}
