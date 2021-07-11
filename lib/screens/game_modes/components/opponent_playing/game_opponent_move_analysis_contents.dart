import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guess_the_move/bloc/find_the_grandmaster_moves_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';

import '../evaluation/components/game_evaluation_move.dart';

class GameOpponentMoveAnalysisContents extends StatelessWidget {
  final FindTheGrandmasterMovesOpponentPlayingMove opponentPlayingState;
  final UserSettingsState userSettingsState;

  const GameOpponentMoveAnalysisContents({Key? key, required this.opponentPlayingState, required this.userSettingsState}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final allMoves = [opponentPlayingState.move.actualMove] + opponentPlayingState.move.alternativeMoves;

    return IntrinsicHeight(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: allMoves
            .map(
              (move) => GameEvaluationMove(
                opponentPlayingState.move.turn,
                opponentPlayingState.analyzedGame.gameAnalysis.grandmasterSide,
                move,
                opponentPlayingState.move.actualMove,
                opponentPlayingState.gameMode,
                userSettingsState,
                null,
              ),
            )
            .toList(),
      ),
    );
  }
}
