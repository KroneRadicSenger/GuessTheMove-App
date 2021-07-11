import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/puzzle_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/theme/theme.dart';

class PuzzleGameBottomNavigationBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) => BlocBuilder<PuzzleBloc, PuzzleState>(
        builder: (context, state) => BlocBuilder<UserSettingsBloc, UserSettingsState>(builder: (_, userSettingsState) {
          return BottomAppBar(
            color: appTheme(context, userSettingsState.userSettings.themeMode).navigationBarColor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _buildIconButtons(context, state, userSettingsState),
                ),
              ],
            ),
          );
        }),
      );

  List<Widget> _buildIconButtons(final BuildContext context, final PuzzleState state, final UserSettingsState userSettingsState) {
    var defaultButtonColor = appTheme(context, userSettingsState.userSettings.themeMode).textColor;

    if (state is PuzzleGuessMove || state is PuzzlePostgameState) {
      return [
        IconButton(
          icon: Container(height: 26),
          color: defaultButtonColor,
          padding: EdgeInsets.all(15),
          onPressed: () {},
        ),
      ];
    }

    Future<void> _onItemTapped(int index) async {
      if (index == 0) {
        var gameBloc = context.read<PuzzleBloc>();
        gameBloc.add(PuzzleRetryCurrentPuzzleEvent());
      } else if (index == 1) {
        var gameBloc = context.read<PuzzleBloc>();
        gameBloc.add(PuzzleShowNextPuzzleEvent());
      }
    }

    return [
      IconButton(
        icon: Icon(Icons.replay, size: 26),
        color: defaultButtonColor,
        padding: EdgeInsets.all(15),
        onPressed: () => _onItemTapped(0),
      ),
      IconButton(
        icon: Icon(Icons.forward, size: 26),
        color: defaultButtonColor,
        padding: EdgeInsets.all(15),
        onPressed: () => _onItemTapped(1),
      ),
    ];
  }
}
