import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/theme/theme.dart';

class TestPhaseNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserSettingsBloc, UserSettingsState>(
      builder: (context, state) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7.0),
          ),
          elevation: 0,
          color: appTheme(context, state.userSettings.themeMode).cardBackgroundColor,
          margin: const EdgeInsets.only(bottom: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                leading: Icon(Icons.info_outline),
                title: Text('Bemerkung', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Weitere Großmeister und Spielepakete werden nach der Testphase folgen!'),
              ),
            ],
          ),
        );
      },
    );
  }
}
