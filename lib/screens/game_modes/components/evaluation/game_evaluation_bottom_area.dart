import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/find_the_grandmaster_moves_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/components/titled_container.dart';
import 'package:guess_the_move/screens/game_modes/components/evaluation/components/game_evaluation_move.dart';
import 'package:guess_the_move/screens/game_modes/components/evaluation/components/game_evaluation_points_given.dart';

class GameEvaluationBottomArea extends StatelessWidget {
  final FindTheGrandmasterMovesGuessEvaluated evaluationState;

  GameEvaluationBottomArea(this.evaluationState, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserSettingsBloc, UserSettingsState>(
      builder: (context, userSettingsState) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: TitledContainer(
            title: 'Bewertung',
            trailing: GameEvaluationPointsGiven(
              userSettingsState: userSettingsState,
              pointsGiven: evaluationState.pointsGiven,
              gameMode: evaluationState.gameMode,
            ),
            child: IntrinsicHeight(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: evaluationState.shuffledAnswerMoves
                    .map(
                      (move) => GameEvaluationMove(
                        evaluationState.move.turn,
                        evaluationState.analyzedGame.gameAnalysis.grandmasterSide,
                        move,
                        evaluationState.chosenMove,
                        evaluationState.gameMode,
                        userSettingsState,
                        evaluationState.move.actualMove,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}
