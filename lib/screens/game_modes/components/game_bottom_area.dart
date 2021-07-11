import 'package:flutter/widgets.dart';
import 'package:guess_the_move/bloc/find_the_grandmaster_moves_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/screens/game_modes/components/evaluation/game_evaluation_bottom_area.dart';
import 'package:guess_the_move/screens/game_modes/components/guessing/game_guessing_bottom_area.dart';
import 'package:guess_the_move/screens/game_modes/components/opening/game_opening_bottom_area.dart';
import 'package:guess_the_move/screens/game_modes/components/opponent_playing/game_opponent_playing_bottom_area.dart';
import 'package:guess_the_move/screens/game_modes/components/summary/summary_bottom_area.dart';
import 'package:guess_the_move/theme/theme.dart';

class GameBottomArea extends StatelessWidget {
  final FindTheGrandmasterMovesState state;
  final UserSettingsState userSettingsState;
  final double chessBoardSize;
  final ScrollController scrollController;

  const GameBottomArea({Key? key, required this.state, required this.userSettingsState, required this.chessBoardSize, required this.scrollController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (state is FindTheGrandmasterMovesShowingOpening) {
      return GameOpeningBottomArea(state as FindTheGrandmasterMovesShowingOpening);
    } else if (state is FindTheGrandmasterMovesOpponentPlayingMove) {
      return GameOpponentPlayingBottomArea(state as FindTheGrandmasterMovesOpponentPlayingMove);
    } else if (state is FindTheGrandmasterMovesGuessingPreviewGuessMove) {
      return GameGuessingBottomArea(state as FindTheGrandmasterMovesGuessingMove);
    } else if (state is FindTheGrandmasterMovesGuessingMove) {
      return GameGuessingBottomArea(state as FindTheGrandmasterMovesGuessingMove);
    } else if (state is FindTheGrandmasterMovesGuessEvaluated) {
      return GameEvaluationBottomArea(state as FindTheGrandmasterMovesGuessEvaluated);
    } else if (state is FindTheGrandmasterMovesShowingSummary) {
      var scrollOffset = chessBoardSize + (2 * scaffoldPaddingHorizontal) + 15;
      scrollController.animateTo(scrollOffset, duration: Duration(milliseconds: 800), curve: Curves.easeIn);
      return GameSummaryBottomArea(
        state.analyzedGame.id,
        state.analyzedGameOriginBundle,
        state.analyzedGame.gameInfo.toString(),
        (state as FindTheGrandmasterMovesShowingSummary).data,
        state.analyzedGame.whitePlayer,
        state.analyzedGame.blackPlayer,
        state.gameMode,
        userSettingsState,
        (state as FindTheGrandmasterMovesShowingSummary).playedTimestamp,
      );
    } else {
      throw StateError('Unsupported game state.');
    }
  }
}
