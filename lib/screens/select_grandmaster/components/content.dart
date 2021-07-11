import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/screens/select_grandmaster/components/grandmaster_list.dart';
import 'package:guess_the_move/theme/theme.dart';

class Content extends StatelessWidget {
  final GameModeEnum gameMode;

  const Content({Key? key, required this.gameMode}) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocBuilder<UserSettingsBloc, UserSettingsState>(
        builder: (context, state) => Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: appTheme(context, state.userSettings.themeMode).scaffoldBackgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(30.0),
                topRight: const Radius.circular(30.0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(scaffoldPaddingHorizontal, 40, scaffoldPaddingHorizontal, 0),
              child: GrandmasterList(gameMode: gameMode),
            ),
          ),
        ),
      );
}
