import 'package:flutter/material.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/theme/theme.dart';

void showLoadingDialog(final BuildContext context, final UserSettingsState userSettingsState, final String text) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
          backgroundColor: appTheme(context, userSettingsState.userSettings.themeMode).scaffoldBackgroundColor,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Container(
                  child: CircularProgressIndicator(),
                  width: 30,
                  height: 30,
                ),
              ),
              Text(text),
            ],
          ),
        ),
      );
    },
  );
}
