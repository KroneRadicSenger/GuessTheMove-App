import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/puzzle_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/components/titled_container.dart';
import 'package:guess_the_move/components/utils/show_alert_dialog.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/screens/game_modes/components/evaluation/components/game_evaluation_points_given.dart';
import 'package:guess_the_move/screens/game_modes/puzzle/components/puzzle_timer.dart';
import 'package:guess_the_move/screens/game_modes/utils/show_toast_message.dart';
import 'package:guess_the_move/theme/theme.dart';

class PuzzleGameBottomArea extends StatelessWidget {
  final PuzzleTimerController puzzleTimerController;
  final Function() onPause;

  const PuzzleGameBottomArea({Key? key, required this.puzzleTimerController, required this.onPause}) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocBuilder<UserSettingsBloc, UserSettingsState>(
        builder: (_, userSettingsState) => BlocConsumer<PuzzleBloc, PuzzleState>(
          listener: (context, state) => _handleStateChanged(context, state, userSettingsState),
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: TitledContainer(
                title: _buildTitle(state),
                trailing: _buildTrailing(context, state, userSettingsState),
                mainAxisAlignment: (state is PuzzleCorrectMove && state.pointsGiven > 0) ? MainAxisAlignment.spaceEvenly : MainAxisAlignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 30),
                            margin: EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                              color: appTheme(context, userSettingsState.userSettings.themeMode).cardBackgroundColor,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: PuzzleTimer(controller: puzzleTimerController),
                          ),
                        ),
                      ],
                    ),
                    if (!(state is PuzzleCorrectMove))
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                              child: ElevatedButton.icon(
                            icon: Icon(Icons.pause),
                            label: Text('Spiel pausieren'),
                            onPressed: onPause,
                          )),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      );

  String _buildTitle(final PuzzleState state) {
    if (!(state is PuzzleIngameState)) {
      throw StateError('Unsupported puzzle state ${state.runtimeType.toString()}');
    }

    if (state is PuzzleGuessMove) {
      return 'Finde den korrekten Zug';
    } else if (state is PuzzleCorrectMove) {
      return 'Korrekter Zug';
    } else if (state is PuzzleWrongMove) {
      return 'Falscher Zug';
    } else {
      throw StateError('Unsupported puzzle state ${state.runtimeType.toString()}');
    }

    /* final puzzleType = state.puzzleMove.actualMove.moveType == AnalyzedMoveType.critical
        ? AnalyzedMoveType.critical.name
        : 'Matt in ${state.puzzleMove.actualMove.signedCPScore.replaceFirst('M', '')}';
    return 'Puzzle - $puzzleType}';
    */
  }

  Widget? _buildTrailing(final BuildContext context, final PuzzleState state, final UserSettingsState userSettingsState) {
    if (state is PuzzleCorrectMove && state.pointsGiven > 0) {
      return Container(
        margin: const EdgeInsets.only(top: 5),
        child: GameEvaluationPointsGiven(
          userSettingsState: userSettingsState,
          pointsGiven: state.pointsGiven,
          gameMode: GameModeEnum.puzzleMode,
        ),
      );
    } else {
      return IconButton(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        icon: Icon(Icons.info_outline),
        iconSize: 20,
        constraints: BoxConstraints(),
        onPressed: () => _onPressInfoIconButton(context),
      );
    }
  }

  void _onPressInfoIconButton(final BuildContext context) {
    final text = '' +
        'In jedem Puzzle gibt es nur einen korrekten Zug, alle anderen Züge sind klare Fehler.\n\n'
            'Dein Timer läuft so lange bis du den korrekten Zug gespielt hast. Hast du einen falschen '
            'Zug gespielt und versuchst das Puzzle erneut, läuft deine Zeit weiter bis der korrekte Zug gefunden wurde.';

    showAlertDialog(
      context,
      'Erklärung',
      text,
      confirmText: 'Schließen',
    );
  }

  void _handleStateChanged(final BuildContext context, final PuzzleState state, final UserSettingsState userSettingsState) {
    if (state is PuzzleCorrectMove && state.pointsGiven > 0) {
      showToastMessage(
        context,
        GameModeEnum.puzzleMode,
        userSettingsState,
        Icons.check_circle_outline,
        'Korrekten Zug gespielt.',
        marginBottom: 120,
      );
    } else if (state is PuzzleWrongMove && !state.wasAlreadySolved) {
      showToastMessage(
        context,
        GameModeEnum.puzzleMode,
        userSettingsState,
        Icons.cancel_outlined,
        'Falschen Zug gespielt',
        marginBottom: 120,
      );
    }
  }
}
