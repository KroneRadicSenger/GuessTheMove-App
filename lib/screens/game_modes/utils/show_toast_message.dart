import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/theme/theme.dart';

void showToastMessage(final BuildContext context, final GameModeEnum gameMode, final UserSettingsState userSettingsState, final IconData icon, final String message,
    {double marginBottom = 70}) {
  final fToast = FToast();
  fToast.init(context);

  fToast.removeQueuedCustomToasts();

  final bottomPadding = MediaQuery.of(context).padding.bottom;

  final toast = Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    decoration: BoxDecoration(
      border: Border.all(
        color: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[gameMode]!.accentColor,
        width: 1,
      ),
      borderRadius: BorderRadius.circular(25.0),
      color: appTheme(context, userSettingsState.userSettings.themeMode).cardBackgroundColor,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[gameMode]!.accentColor,
        ),
        SizedBox(
          width: 12.0,
        ),
        Flexible(
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[gameMode]!.accentColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );

  fToast.showToast(
    child: toast,
    positionedToastBuilder: (context, child) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Container(
              margin: EdgeInsets.only(bottom: bottomPadding + marginBottom),
              child: child,
            ),
          ),
        ],
      );
    },
    toastDuration: Duration(seconds: 2),
  );
}
