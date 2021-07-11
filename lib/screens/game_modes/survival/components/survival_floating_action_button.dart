import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/find_the_grandmaster_moves_bloc.dart';
import 'package:guess_the_move/bloc/points_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/guess_the_move_app.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/theme/theme.dart';

class SurvivalFloatingActionButton extends StatelessWidget {
  const SurvivalFloatingActionButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FindTheGrandmasterMovesBloc, FindTheGrandmasterMovesState>(
      builder: (context, state) => BlocBuilder<UserSettingsBloc, UserSettingsState>(builder: (context, userSettingsState) {
        if (!(state is FindTheGrandmasterMovesShowingSummary || state is FindTheGrandmasterMovesSurvivalGameOver)) {
          return Container();
        }

        final icon;
        final iconText;
        if (state is FindTheGrandmasterMovesShowingSummary) {
          icon = Icons.next_plan_outlined;
          iconText = 'Weiter';
        } else if (state is FindTheGrandmasterMovesSurvivalGameOver) {
          icon = Icons.home;
          iconText = 'Start';
        } else {
          throw StateError('Unexpected game state.');
        }

        return Padding(
          padding: EdgeInsets.only(top: 54),
          child: SizedBox(
            height: 70,
            width: 70,
            child: FloatingActionButton(
              backgroundColor: Colors.transparent,
              elevation: 0,
              onPressed: () => _handleClick(context, state, context.read<FindTheGrandmasterMovesBloc>(), context.read<PointsBloc>(), userSettingsState),
              child: Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  border: Border.all(color: appTheme(context, userSettingsState.userSettings.themeMode).cardBackgroundColor, width: 2),
                  shape: BoxShape.circle,
                  color: appTheme(context, userSettingsState.userSettings.themeMode).navigationBarColor,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 30,
                      color: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[GameModeEnum.survivalMode]!.accentColor,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        iconText,
                        style: TextStyle(
                          fontSize: 10,
                          color: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[GameModeEnum.survivalMode]!.accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  void _handleClick(final BuildContext context, final FindTheGrandmasterMovesState state, final FindTheGrandmasterMovesBloc bloc, final PointsBloc pointsBloc,
      final UserSettingsState userSettingsState) {
    if (state is FindTheGrandmasterMovesSurvivalGameOver) {
      Navigator.of(context).pushAndRemoveUntil(
        CupertinoPageRoute(
          builder: (BuildContext context) {
            return GuessTheMoveApp();
          },
        ),
        (_) => false,
      );
      return;
    } else if (state is FindTheGrandmasterMovesShowingSummary) {
      bloc.add(FindTheGrandmasterMovesGoToNextStateEvent());
      return;
    }
    throw StateError('Floating action button is not supported in state ${state.runtimeType.toString()}');
  }
}
