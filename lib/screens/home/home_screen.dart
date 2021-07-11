import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/components/header.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/screens/home/components/content.dart';
import 'package:guess_the_move/theme/theme.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserSettingsBloc, UserSettingsState>(
      builder: (context, state) => Container(
        decoration: BoxDecoration(
          gradient: appTheme(context, state.userSettings.themeMode).gameModeThemes[GameModeEnum.findTheGrandmasterMoves]!.backgroundGradient,
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [Header(), Content()],
            ),
          ),
          //bottomNavigationBar: Navigation(selectedIndex: 0),
        ),
      ),
    );
  }
}
