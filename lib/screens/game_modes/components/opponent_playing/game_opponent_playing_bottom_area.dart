import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/find_the_grandmaster_moves_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/components/titled_container.dart';
import 'package:guess_the_move/theme/theme.dart';

import '../evaluation/components/game_evaluation_move.dart';

class GameOpponentPlayingBottomArea extends StatelessWidget {
  final FindTheGrandmasterMovesOpponentPlayingMove opponentPlayingState;

  const GameOpponentPlayingBottomArea(this.opponentPlayingState, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocBuilder<UserSettingsBloc, UserSettingsState>(
        builder: (context, userSettingsState) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: TitledContainer(
                title: 'Gegner spielt nächsten Zug',
                mainAxisAlignment: MainAxisAlignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    opponentPlayingState.moveRevealed
                        ? _buildOpponentMoveRevealedBox(context, userSettingsState, opponentPlayingState)
                        : _buildOpponentMoveNotRevealedBox(context, userSettingsState, opponentPlayingState),
                  ],
                )),
          );
        },
      );

  Widget _buildOpponentMoveNotRevealedBox(
      final BuildContext context, final UserSettingsState userSettingsState, final FindTheGrandmasterMovesOpponentPlayingMove opponentPlayingState) {
    return GestureDetector(
      onTap: () => context.read<FindTheGrandmasterMovesBloc>().add(FindTheGrandmasterMovesRevealOpponentMoveEvent()),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 30),
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              decoration: BoxDecoration(
                color: appTheme(context, userSettingsState.userSettings.themeMode).cardBackgroundColor,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Center(
                child: Text(
                  'Tippe um Zug aufzudecken',
                  style: TextStyle(
                    color: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[opponentPlayingState.gameMode]!.accentColor,
                    fontWeight: FontWeight.bold,
                    fontStyle: opponentPlayingState.moveRevealed ? FontStyle.normal : FontStyle.italic,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpponentMoveRevealedBox(
      final BuildContext context, final UserSettingsState userSettingsState, final FindTheGrandmasterMovesOpponentPlayingMove opponentPlayingState) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GameEvaluationMove(
          opponentPlayingState.move.turn,
          opponentPlayingState.analyzedGame.gameAnalysis.grandmasterSide,
          opponentPlayingState.move.actualMove,
          null,
          opponentPlayingState.gameMode,
          userSettingsState,
          null,
        ),
      ],
    );
  }
}
