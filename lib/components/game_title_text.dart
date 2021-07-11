import 'package:flutter/widgets.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/theme/theme.dart';

class GameTitleText extends StatelessWidget {
  final UserSettingsState state;
  final GameModeEnum gameMode;
  final String contents;
  final TextAlign textAlign;
  final bool addMarginBottom;

  GameTitleText(this.state, this.gameMode, this.contents, {this.textAlign = TextAlign.left, this.addMarginBottom = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: addMarginBottom ? 5 : 0),
      child: Text(
        contents,
        style: TextStyle(
          color: appTheme(context, state.userSettings.themeMode).gameModeThemes[gameMode]!.accentColor,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
        textAlign: textAlign,
      ),
    );
  }
}
