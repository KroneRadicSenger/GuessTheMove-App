import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/theme/theme.dart';

class TimeBattleCountdownTimer extends StatelessWidget {
  final UserSettingsState userSettingsState;
  final AnimationController animationController;

  const TimeBattleCountdownTimer({
    Key? key,
    required this.animationController,
    required this.userSettingsState,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: appTheme(context, userSettingsState.userSettings.themeMode).cardBackgroundColor,
      height: 4,
      child: AnimatedBuilder(
        animation: animationController,
        builder: (context, child) {
          return LayoutBuilder(
            builder: (context, boxConstraints) => Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: (1 - animationController.value) * boxConstraints.maxWidth,
                  height: 4,
                  decoration: BoxDecoration(
                    color: appTheme(context, userSettingsState.userSettings.themeMode)
                        .gameModeThemes[GameModeEnum.timeBattle]!
                        .accentColor,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
