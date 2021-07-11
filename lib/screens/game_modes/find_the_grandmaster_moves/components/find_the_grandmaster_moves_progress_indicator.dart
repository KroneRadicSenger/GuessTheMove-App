import 'package:flutter/widgets.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/find_the_grandmaster_moves_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/theme/theme.dart';

class FindTheGrandmasterMovesProgressIndicator extends StatelessWidget {
  final UserSettingsState userSettingsState;

  const FindTheGrandmasterMovesProgressIndicator({Key? key, required this.userSettingsState}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FindTheGrandmasterMovesBloc, FindTheGrandmasterMovesState>(builder: (context, state) {
      var totalPlies = state.analyzedGame.gameAnalysis.analyzedMoves.length;
      var currentPly = state is FindTheGrandmasterMovesShowingSummary
          ? totalPlies
          : (state as FindTheGrandmasterMovesIngameState).move.ply + 1;

      return FAProgressBar(
        size: 4,
        currentValue: currentPly,
        maxValue: totalPlies,
        backgroundColor: appTheme(context, userSettingsState.userSettings.themeMode).cardBackgroundColor,
        progressColor: appTheme(context, userSettingsState.userSettings.themeMode)
            .gameModeThemes[GameModeEnum.findTheGrandmasterMoves]!
            .accentColor,
      );
    });
  }
}
