import 'package:flutter/material.dart';
import 'package:guess_the_move/bloc/find_the_grandmaster_moves_bloc.dart';
import 'package:guess_the_move/bloc/puzzle_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/components/utils/show_alert_dialog.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/theme/theme.dart';

class GameEvaluationPointsGiven extends StatelessWidget {
  final UserSettingsState userSettingsState;
  final int pointsGiven;
  final GameModeEnum gameMode;

  const GameEvaluationPointsGiven({
    Key? key,
    required this.userSettingsState,
    required this.pointsGiven,
    required this.gameMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '+' + pointsGiven.toString() + ' Punkte',
          style: TextStyle(
            color: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[gameMode]!.accentColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          icon: Icon(Icons.info_outline),
          iconSize: 20,
          constraints: BoxConstraints(),
          onPressed: () => _onPressInfoIconButton(context),
        ),
      ],
    );
  }

  void _onPressInfoIconButton(final BuildContext context) {
    final text;
    if (gameMode == GameModeEnum.puzzleMode) {
      text = '' +
          'Für einen korrekt gespielten Puzzle-Zug erhältst du Punkte.\n\n' +
          'Falls du direkt den korrekten Zug gefunden hast, erhälst du ${PuzzleBloc.maxPointsForCorrectPuzzleMove} Punkte.'
              ' Ansonsten erhälst du pro Fehlversuch ${PuzzleBloc.discountPointsForWrongTry} Punkte weniger. Du kannst jedoch nie Minuspunkte erhalten.';
    } else {
      text = '' +
          'GM Zug, Konter, Einzige Wahl, brillianten oder besten Zug gespielt:\n+$bestMovePlayedPointsGiven Punkte\n\n' +
          'Mittelmäßiger, guter oder sehr guter Zug gespielt:\n+$mediocreMovePlayedPointsGiven Punkte\n\n' +
          'Ungenauigkeit, Fehler oder Grober Fehler gespielt:\n+$badMovePlayedPointsGiven Punkte';
    }

    showAlertDialog(
      context,
      'Punktevergabe',
      text,
      confirmText: 'Schließen',
    );
  }
}
