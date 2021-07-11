import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/points_bloc.dart';
import 'package:guess_the_move/bloc/puzzle_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/components/header.dart';
import 'package:guess_the_move/model/analyzed_game.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/model/user_settings.dart';
import 'package:guess_the_move/screens/game_modes/components/chess_board/chess_board.dart';
import 'package:guess_the_move/screens/game_modes/components/chess_board/chessboard_model.dart';
import 'package:guess_the_move/screens/game_modes/components/game_layout.dart';
import 'package:guess_the_move/screens/game_modes/puzzle/components/puzzle_game_bottom_area.dart';
import 'package:guess_the_move/screens/game_modes/puzzle/components/puzzle_game_over_contents.dart';
import 'package:guess_the_move/screens/game_modes/puzzle/components/puzzle_header.dart';
import 'package:guess_the_move/screens/game_modes/puzzle/components/puzzle_timer.dart';
import 'package:guess_the_move/theme/theme.dart';

class PuzzleGameContents extends StatefulWidget {
  final PuzzleTimerController puzzleTimerController;
  final ChessBoardController chessBoardController;
  final Function() onPause;
  final Function() onPressHome;

  PuzzleGameContents({
    Key? key,
    required this.puzzleTimerController,
    required this.chessBoardController,
    required this.onPause,
    required this.onPressHome,
  }) : super(key: key);

  @override
  _PuzzleGameContentsState createState() => _PuzzleGameContentsState();
}

class _PuzzleGameContentsState extends State<PuzzleGameContents> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) => BlocBuilder<PuzzleBloc, PuzzleState>(
        builder: (context, state) => BlocBuilder<UserSettingsBloc, UserSettingsState>(
          builder: (context, userSettingsState) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              state is PuzzleIngameState ? PuzzleHeader(onPressHome: widget.onPressHome) : Header(),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: appTheme(context, userSettingsState.userSettings.themeMode).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(30.0),
                      topRight: const Radius.circular(30.0),
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(.2), offset: Offset(0, -3), blurRadius: 4, spreadRadius: 0),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(scaffoldPaddingHorizontal, 20, scaffoldPaddingHorizontal, 0),
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: BouncingScrollPhysics(),
                      child: state is PuzzleGameOver
                          ? PuzzleGameOverContents(
                              analyzedGamesOriginBundle: state.analyzedGamesOriginBundle,
                              puzzlesPlayed: state.puzzlesPlayed,
                              playedDateTimestamp: state.playedDateTimestamp,
                              userSettingsState: userSettingsState)
                          : _buildIngameContents(state as PuzzleIngameState, userSettingsState),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildIngameContents(final PuzzleIngameState state, final UserSettingsState userSettingsState) {
    final screenWidth = MediaQuery.of(context).size.width;
    final chessBoardWidth = screenWidth - (2 * scaffoldPaddingHorizontal);
    final chessBoardWidthCorrected = chessBoardWidth - (chessBoardWidth % 8);

    var chessBoardSize = chessBoardWidthCorrected;
    if (!isSmartphoneDisplay(context)) {
      chessBoardSize = MediaQuery.of(context).size.height / 2;
      chessBoardSize -= chessBoardSize % 8;
    }

    // TODO Consider also using two column layout on large screens here

    final boardFlipped = _mustBoardBeFlipped(userSettingsState.userSettings.boardRotation, state);

    final pointsBloc = context.read<PointsBloc>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(height: 10),
        Center(
          child: ChessBoard(
            size: chessBoardSize,
            lightSquareColor: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[GameModeEnum.puzzleMode]!.chessBoardLightSquareColor,
            darkSquareColor: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[GameModeEnum.puzzleMode]!.chessBoardDarkSquareColor,
            highlightSquareColor: Colors.lightGreenAccent.withOpacity(0.5),
            dragToMakeMove: state is PuzzleGuessMove,
            markDragMoveToSquaresColor: Colors.black.withOpacity(0.3),
            textColor: appTheme(context, userSettingsState.userSettings.themeMode).textColor,
            whitePlayer: state.analyzedGame.whitePlayer,
            blackPlayer: state.analyzedGame.blackPlayer,
            flipped: boardFlipped,
            controller: widget.chessBoardController,
            postInitialize: () => _initializeBoardForPuzzle(state),
            onDragMoveSucceeded: (_, __, movePlayed) => context.read<PuzzleBloc>().add(PuzzlePlayMoveEvent(movePlayed!.sanMove, pointsBloc)),
          ),
        ),
        PuzzleGameBottomArea(
          puzzleTimerController: widget.puzzleTimerController,
          onPause: widget.onPause,
        ),
      ],
    );
  }

  void _initializeBoardForPuzzle(final PuzzleIngameState state) {
    for (final analyzedMove in state.analyzedGame.gameAnalysis.analyzedMoves) {
      if (analyzedMove == state.puzzleMove) {
        return;
      }
      widget.chessBoardController.makeMove!(analyzedMove.actualMove.move.san);
    }
  }

  bool _mustBoardBeFlipped(final BoardRotationEnum boardRotation, final PuzzleIngameState state) {
    return boardRotation == BoardRotationEnum.grandmaster && state.analyzedGame.gameAnalysis.grandmasterSide == GrandmasterSide.black;
  }
}
