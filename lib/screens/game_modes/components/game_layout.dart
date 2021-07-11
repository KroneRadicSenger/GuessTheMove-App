import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/find_the_grandmaster_moves_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/model/analyzed_game.dart';
import 'package:guess_the_move/model/user_settings.dart';
import 'package:guess_the_move/screens/game_modes/components/chess_board/chess_board.dart';
import 'package:guess_the_move/screens/game_modes/components/chess_board/chessboard_model.dart';
import 'package:guess_the_move/screens/game_modes/components/game_bottom_area.dart';
import 'package:guess_the_move/screens/game_modes/components/game_player_name_and_score.dart';
import 'package:guess_the_move/theme/theme.dart';

class GameLayout extends StatelessWidget {
  final ChessBoardController chessBoardController;
  final ScrollController scrollController;
  final bool hidePlayerNames;

  const GameLayout({
    Key? key,
    required this.chessBoardController,
    required this.scrollController,
    required this.hidePlayerNames,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FindTheGrandmasterMovesBloc, FindTheGrandmasterMovesState>(
      builder: (context, state) => BlocBuilder<UserSettingsBloc, UserSettingsState>(builder: (context, userSettingsState) {
        return LayoutBuilder(builder: (context, boxConstraints) {
          final chessBoardSize = calculateChessboardSize(context, boxConstraints);
          final shouldBeMultiColumnLayout = _shouldBeMultiColumnLayout(context);
          final boardFlipped = _mustBoardBeFlipped(userSettingsState.userSettings.boardRotation, state);
          final firstMoveSan = state.analyzedGame.gameAnalysis.analyzedMoves[0].actualMove.move.san;

          final marginTop = shouldBeMultiColumnLayout ? max(0.0, (MediaQuery.of(context).size.height - chessBoardSize) / 2 - 120) : 0.0;
          final chessBoardPlayersPaddingHorizontal = calculateChessboardPlayersHorizontalPadding(context, boxConstraints);

          return Container(
            margin: EdgeInsets.only(top: marginTop),
            padding: EdgeInsets.symmetric(horizontal: chessBoardPlayersPaddingHorizontal),
            child: Wrap(
              spacing: 0.0,
              runSpacing: 0.0,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: shouldBeMultiColumnLayout ? (boxConstraints.maxWidth / 2 - 30) : boxConstraints.maxWidth,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!hidePlayerNames)
                        GamePlayerNameAndScore.fromState(
                          context,
                          userSettingsState,
                          state,
                          boardFlipped ? ChessColor.white : ChessColor.black,
                          true,
                        ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Center(
                            child: ChessBoard(
                              size: chessBoardSize,
                              lightSquareColor: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[state.gameMode]!.chessBoardLightSquareColor,
                              darkSquareColor: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[state.gameMode]!.chessBoardDarkSquareColor,
                              highlightSquareColor: Colors.lightGreenAccent.withOpacity(0.5),
                              markDragMoveToSquaresColor: Colors.black.withOpacity(0.3),
                              textColor: appTheme(context, userSettingsState.userSettings.themeMode).textColor,
                              whitePlayer: state.analyzedGame.whitePlayer,
                              blackPlayer: state.analyzedGame.blackPlayer,
                              flipped: boardFlipped,
                              controller: chessBoardController,
                              postInitialize: () => chessBoardController.showMoveArrow!(firstMoveSan),
                            ),
                          ),
                        ],
                      ),
                      if (!hidePlayerNames)
                        GamePlayerNameAndScore.fromState(
                          context,
                          userSettingsState,
                          state,
                          boardFlipped ? ChessColor.black : ChessColor.white,
                          false,
                        ),
                    ],
                  ),
                ),
                Container(width: 30),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: shouldBeMultiColumnLayout ? (boxConstraints.maxWidth / 2) : boxConstraints.maxWidth,
                  ),
                  child: GameBottomArea(
                    state: state,
                    userSettingsState: userSettingsState,
                    chessBoardSize: chessBoardSize,
                    scrollController: scrollController,
                  ),
                ),
              ],
            ),
          );
        });
      }),
    );
  }

  bool _mustBoardBeFlipped(final BoardRotationEnum boardRotation, final FindTheGrandmasterMovesState state) {
    return boardRotation == BoardRotationEnum.grandmaster && state.analyzedGame.gameAnalysis.grandmasterSide == GrandmasterSide.black;
  }
}

/* Source: https://iiro.dev/implementing-adaptive-master-detail-layouts/ */
bool isSmartphoneDisplay(final BuildContext context) {
  // The equivalent of the "smallestWidth" qualifier on Android.
  final smallestDimension = MediaQuery.of(context).size.shortestSide;

  // Determine if we should use mobile layout or not. The
  // number 600 here is a common breakpoint for a typical
  // 7-inch tablet.
  return smallestDimension < 600;
}

double calculateChessboardSize(final BuildContext context, final BoxConstraints boxConstraints) {
  final bool smartphoneDisplay = isSmartphoneDisplay(context);
  final bool shouldBeMultiColumnLayout = _shouldBeMultiColumnLayout(context);

  final chessBoardWidth = boxConstraints.maxWidth;
  final chessBoardWidthCorrected = chessBoardWidth - (chessBoardWidth % 8);

  var chessBoardSize = chessBoardWidthCorrected;

  if (shouldBeMultiColumnLayout) {
    chessBoardSize = chessBoardSize * 0.5 - 30;
    chessBoardSize -= chessBoardSize % 8;
  } else if (!smartphoneDisplay) {
    chessBoardSize = chessBoardSize * 0.82;
    chessBoardSize -= chessBoardSize % 8;
  }

  return chessBoardSize;
}

double calculateChessboardPlayersHorizontalPadding(final BuildContext context, final BoxConstraints boxConstraints) {
  final bool smartphoneDisplay = isSmartphoneDisplay(context);
  final bool shouldBeMultiColumnLayout = _shouldBeMultiColumnLayout(context);

  if (smartphoneDisplay || shouldBeMultiColumnLayout) {
    return 0;
  }

  final chessBoardWidth = boxConstraints.maxWidth;
  final chessBoardWidthCorrected = chessBoardWidth - (chessBoardWidth % 8);

  return chessBoardWidthCorrected * 0.09;
}

bool _shouldBeMultiColumnLayout(final BuildContext context) {
  final orientation = MediaQuery.of(context).orientation;
  //final bool isSmartphoneDisplay = _isSmartphoneDisplay(context);

  return /*!isSmartphoneDisplay &&*/ orientation == Orientation.landscape;
}
