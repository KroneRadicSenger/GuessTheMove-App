import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/screens/home/components/game_mode_list.dart';
import 'package:guess_the_move/screens/home/components/last_played_list.dart';
import 'package:guess_the_move/theme/theme.dart';

class Content extends StatelessWidget {
  const Content({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserSettingsBloc, UserSettingsState>(
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
            padding: const EdgeInsets.only(top: 40),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: scaffoldPaddingHorizontal),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GameModeList(),
                    LastPlayedList(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
