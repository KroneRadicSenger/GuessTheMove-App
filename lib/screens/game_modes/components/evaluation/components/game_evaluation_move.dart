import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/model/analyzed_game.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/model/user_settings.dart';
import 'package:guess_the_move/screens/game_modes/components/game_move_in_user_notation.dart';
import 'package:guess_the_move/screens/game_modes/components/game_pawn_or_mate_score.dart';
import 'package:guess_the_move/screens/game_modes/components/game_winning_chance.dart';
import 'package:guess_the_move/theme/theme.dart';

class GameEvaluationMove extends StatelessWidget {
  final GrandmasterSide turn;
  final GrandmasterSide grandmasterSide;
  final EvaluatedMove evaluatedMove;
  final EvaluatedMove? chosenMove;
  final GameModeEnum gameMode;
  final UserSettingsState userSettingsState;
  final EvaluatedMove? gmMove;

  GameEvaluationMove(this.turn, this.grandmasterSide, this.evaluatedMove, this.chosenMove, this.gameMode, this.userSettingsState, this.gmMove, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isGmMove = gmMove != null && evaluatedMove.move.san == gmMove!.move.san;
    final isSelected = chosenMove != null && chosenMove!.move.san == evaluatedMove.move.san;
    final backgroundColor = isSelected
        ? appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[gameMode]!.accentColor
        : appTheme(context, userSettingsState.userSettings.themeMode).cardBackgroundColor;
    final textColor =
        isSelected ? appTheme(context, userSettingsState.userSettings.themeMode).scaffoldBackgroundColor : appTheme(context, userSettingsState.userSettings.themeMode).textColor;

    final scoreWidget = userSettingsState.userSettings.moveEvaluationNotation == MoveEvaluationNotationEnum.pawnScore
        ? GamePawnOrMateScore(signedCpOrMateScore: evaluatedMove.signedCPScore)
        : GameWinningChance(grandmasterSide: grandmasterSide, playerSide: turn, gmExpectation: evaluatedMove.gmExpectation);

    return Expanded(
      child: Container(
          padding: const EdgeInsets.all(10),
          margin: EdgeInsets.fromLTRB(5, 15, 5, 0),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GameMoveInUserNotation(move: evaluatedMove.move, turn: turn, userSettingsState: userSettingsState, isSelected: isSelected),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  evaluatedMove.moveType.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textColor),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: scoreWidget,
              ),
              if (isGmMove)
                Container(
                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    color: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[gameMode]!.accentColor,
                    border: Border.all(color: textColor),
                  ),
                  child: Text(
                    'GM Zug',
                    style: TextStyle(
                      color: appTheme(context, userSettingsState.userSettings.themeMode).scaffoldBackgroundColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          )),
    );
  }
}
