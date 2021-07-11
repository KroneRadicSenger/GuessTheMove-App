import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/puzzle_bloc.dart';
import 'package:guess_the_move/components/points_indicator.dart';
import 'package:guess_the_move/model/analyzed_game.dart';
import 'package:guess_the_move/screens/game_modes/components/chess_board/chessboard_model.dart';
import 'package:guess_the_move/screens/game_modes/components/game_move_info.dart';
import 'package:guess_the_move/theme/theme.dart';

class PuzzleHeader extends StatelessWidget {
  final PuzzleBloc? bloc;
  final Function() onPressHome;

  PuzzleHeader({Key? key, this.bloc, required this.onPressHome}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(scaffoldPaddingHorizontal, Platform.isAndroid ? 20 : 5, scaffoldPaddingHorizontal, 20),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildPuzzleInfo(),
          PointsIndicator(),
        ],
      ),
    );
  }

  Widget _buildPuzzleInfo() {
    return BlocBuilder<PuzzleBloc, PuzzleState>(
      bloc: bloc,
      builder: (context, state) {
        if (!(state is PuzzleIngameState)) {
          return Container();
        }

        final turn = state.puzzleMove.turn;
        final fullMoveNumber = state.puzzleMove.ply ~/ 2;

        return GameMoveInfo(
          turn: turn == GrandmasterSide.white ? ChessColor.white : ChessColor.black,
          fullMoveNumber: fullMoveNumber,
          onPressHome: onPressHome,
        );
      },
    );
  }
}
