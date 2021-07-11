import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/find_the_grandmaster_moves_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/model/analyzed_game.dart';
import 'package:guess_the_move/model/player.dart';
import 'package:guess_the_move/model/user_settings.dart';
import 'package:guess_the_move/screens/game_modes/components/chess_board/chessboard_model.dart';
import 'package:guess_the_move/screens/game_modes/components/game_pawn_or_mate_score.dart';
import 'package:guess_the_move/screens/game_modes/components/game_player_name.dart';
import 'package:guess_the_move/screens/game_modes/components/game_winning_chance.dart';

class GamePlayerNameAndScore extends StatelessWidget {
  final UserSettingsState userSettingsState;
  final Player player;
  final ChessColor playerSide;
  final GrandmasterSide turn;
  final String signedCpOrMateScore;
  final GrandmasterSide grandmasterSide;
  final double gmExpectation;
  final bool top;

  const GamePlayerNameAndScore({
    Key? key,
    required this.userSettingsState,
    required this.player,
    required this.playerSide,
    required this.turn,
    required this.signedCpOrMateScore,
    required this.grandmasterSide,
    required this.gmExpectation,
    required this.top,
  }) : super(key: key);

  factory GamePlayerNameAndScore.fromState(
      final BuildContext context, final UserSettingsState userSettingsState, final FindTheGrandmasterMovesState state, final ChessColor playerSide, final bool top) {
    final FindTheGrandmasterMovesIngameState ingameState;
    if (state is FindTheGrandmasterMovesPostgameState) {
      final gameBloc = context.read<FindTheGrandmasterMovesBloc>();
      ingameState = gameBloc.screenStateHistory[gameBloc.screenStateHistory.length - 2] as FindTheGrandmasterMovesIngameState;
    } else if (state is FindTheGrandmasterMovesTimeBattleGameOver || state is FindTheGrandmasterMovesSurvivalGameOver) {
      final gameBloc = context.read<FindTheGrandmasterMovesBloc>();
      ingameState = gameBloc.screenStateHistory[gameBloc.screenStateHistory.length - 2] as FindTheGrandmasterMovesIngameState;
    } else {
      ingameState = state as FindTheGrandmasterMovesIngameState;
    }

    final AnalyzedMove? lastMovePlayed = (ingameState.move.ply == 0) ? null : ingameState.analyzedGame.gameAnalysis.analyzedMoves[ingameState.move.ply - 1];
    final String signedCpOrMateScore = lastMovePlayed == null ? '+0.0' : lastMovePlayed.actualMove.signedCPScore;

    var player = playerSide == ChessColor.white ? ingameState.analyzedGame.whitePlayer : ingameState.analyzedGame.blackPlayer;

    final grandmasterSide = state.analyzedGame.gameAnalysis.grandmasterSide;
    final gmExpectation = lastMovePlayed == null ? 0.5 : lastMovePlayed.actualMove.gmExpectation;

    return GamePlayerNameAndScore(
        userSettingsState: userSettingsState,
        player: player,
        playerSide: playerSide,
        turn: ingameState.move.turn,
        signedCpOrMateScore: signedCpOrMateScore,
        grandmasterSide: grandmasterSide,
        gmExpectation: gmExpectation,
        top: top);
  }

  @override
  Widget build(BuildContext context) {
    final isMateScore = signedCpOrMateScore.startsWith('M');
    final isWhiteLeading = (isMateScore && signedCpOrMateScore[1] != '-') || (!isMateScore && signedCpOrMateScore.startsWith('+'));

    final isPlayerTurn = (turn == GrandmasterSide.white && playerSide == ChessColor.white) || (turn == GrandmasterSide.black && playerSide == ChessColor.black);
    final isPlayerLeading = (playerSide == ChessColor.white && isWhiteLeading) || (playerSide == ChessColor.black && !isWhiteLeading);

    final scoreWidget = userSettingsState.userSettings.moveEvaluationNotation == MoveEvaluationNotationEnum.pawnScore
        ? GamePawnOrMateScore(signedCpOrMateScore: signedCpOrMateScore)
        : GameWinningChance(
            grandmasterSide: grandmasterSide,
            playerSide: playerSide == ChessColor.white ? GrandmasterSide.white : GrandmasterSide.black,
            gmExpectation: gmExpectation,
          );

    if (isPlayerLeading) {
      return Padding(
        padding: top ? const EdgeInsets.only(bottom: 10) : const EdgeInsets.only(top: 10),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: top
              ? [
                  GamePlayerName(player, playerSide, isPlayerTurn),
                  scoreWidget,
                ]
              : [
                  scoreWidget,
                  GamePlayerName(player, playerSide, isPlayerTurn),
                ],
        ),
      );
    }

    return Padding(
      padding: top ? const EdgeInsets.only(bottom: 10) : const EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: top ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          GamePlayerName(player, playerSide, isPlayerTurn),
        ],
      ),
    );
  }
}
