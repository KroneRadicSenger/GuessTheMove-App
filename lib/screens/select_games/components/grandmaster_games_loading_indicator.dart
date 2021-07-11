import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/theme/theme.dart';

class GrandmasterGamesLoadingIndicator extends StatelessWidget {
  final UserSettingsState userSettingsState;

  const GrandmasterGamesLoadingIndicator({Key? key, required this.userSettingsState}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  'Lade Spiele im Spielepaket..',
                  style: TextStyle(color: appTheme(context, userSettingsState.userSettings.themeMode).textColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
