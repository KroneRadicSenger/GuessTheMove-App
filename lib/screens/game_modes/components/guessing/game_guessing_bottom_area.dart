import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/find_the_grandmaster_moves_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/components/titled_container.dart';
import 'package:guess_the_move/model/analyzed_game.dart';
import 'package:guess_the_move/screens/game_modes/components/game_move_in_user_notation.dart';
import 'package:guess_the_move/theme/theme.dart';

class GameGuessingBottomArea extends StatelessWidget {
  final FindTheGrandmasterMovesGuessingMove guessingState;

  GameGuessingBottomArea(this.guessingState, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserSettingsBloc, UserSettingsState>(
      builder: (context, userSettingsState) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: TitledContainer(
            title: 'Finde den Großmeister-Zug',
            mainAxisAlignment: MainAxisAlignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children:
                        guessingState.shuffledAnswerMoves.map((m) => _buildMoveAnswer(context, userSettingsState, m)).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMoveAnswer(final BuildContext context, final UserSettingsState userSettingsState, final EvaluatedMove move) {
    var isSelected = guessingState is FindTheGrandmasterMovesGuessingPreviewGuessMove &&
        move == (guessingState as FindTheGrandmasterMovesGuessingPreviewGuessMove).moveSelected;
    var backgroundColor = isSelected
        ? appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[guessingState.gameMode]!.accentColor
        : appTheme(context, userSettingsState.userSettings.themeMode).cardBackgroundColor;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (guessingState is FindTheGrandmasterMovesGuessingPreviewGuessMove) {
            var previewState = guessingState as FindTheGrandmasterMovesGuessingPreviewGuessMove;

            if (previewState.moveSelected == move) {
              // Unselect current preview move
              context.read<FindTheGrandmasterMovesBloc>().add(FindTheGrandmasterMovesUnselectGuessEvent());
            } else {
              // Unselect current preview move and select new move
              context.read<FindTheGrandmasterMovesBloc>().add(FindTheGrandmasterMovesUnselectGuessEvent());
              context.read<FindTheGrandmasterMovesBloc>().add(FindTheGrandmasterMovesSelectGuessEvent(move));
            }
            return;
          }

          // select move to preview
          context.read<FindTheGrandmasterMovesBloc>().add(FindTheGrandmasterMovesSelectGuessEvent(move));
        },
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(5),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
          margin: EdgeInsets.fromLTRB(10, 15, 10, 0),
          child: GameMoveInUserNotation(
              move: move.move, turn: guessingState.move.turn, userSettingsState: userSettingsState, isSelected: isSelected),
        ),
      ),
    );
  }
}
