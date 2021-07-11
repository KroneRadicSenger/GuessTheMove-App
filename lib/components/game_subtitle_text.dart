import 'package:flutter/widgets.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/theme/theme.dart';

class GameSubtitleText extends StatelessWidget {
  final UserSettingsState state;
  final String contents;
  final bool showBulletPoint;

  GameSubtitleText(this.state, this.contents, {this.showBulletPoint = true});

  @override
  Widget build(BuildContext context) {
    if (!showBulletPoint) {
      return Text(
        contents,
        style: TextStyle(color: appTheme(context, state.userSettings.themeMode).textColor, fontWeight: FontWeight.w300),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(
          '\u2022',
          style: TextStyle(color: appTheme(context, state.userSettings.themeMode).textColor, fontWeight: FontWeight.w300),
        ),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              contents,
              style: TextStyle(color: appTheme(context, state.userSettings.themeMode).textColor, fontWeight: FontWeight.w300),
            ),
          ),
        ),
      ],
    );
  }
}
