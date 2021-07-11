import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/points_bloc.dart';
import 'package:guess_the_move/bloc/puzzle_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/components/utils/show_auto_resizing_modal_bottom_sheet.dart';
import 'package:guess_the_move/components/utils/show_draggable_modal_bottom_sheet.dart';
import 'package:guess_the_move/guess_the_move_app.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/screens/game_modes/components/chess_board/chessboard_model.dart';
import 'package:guess_the_move/screens/game_modes/components/guessing/game_tips_contents.dart';
import 'package:guess_the_move/screens/game_modes/components/live_analysis/game_live_analysis_contents.dart';
import 'package:guess_the_move/theme/theme.dart';

class PuzzleFloatingActionButton extends StatelessWidget {
  final ChessBoardController chessBoardController;

  const PuzzleFloatingActionButton({Key? key, required this.chessBoardController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PuzzleBloc, PuzzleState>(
      builder: (context, state) => BlocBuilder<UserSettingsBloc, UserSettingsState>(builder: (context, userSettingsState) {
        final icon;
        final iconText;
        if (state is PuzzleGuessMove) {
          icon = Icons.lightbulb;
          iconText = 'Tipp';
        } else if (state is PuzzleGameOver) {
          icon = Icons.home;
          iconText = 'Start';
        } else {
          icon = Icons.analytics;
          iconText = 'Analyse';
        }

        return Padding(
          padding: EdgeInsets.only(top: 54),
          child: SizedBox(
            height: 70,
            width: 70,
            child: FloatingActionButton(
              backgroundColor: Colors.transparent,
              elevation: 0,
              onPressed: () => _handleClick(context, state, context.read<PuzzleBloc>(), context.read<PointsBloc>(), userSettingsState),
              child: Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  border: Border.all(color: appTheme(context, userSettingsState.userSettings.themeMode).cardBackgroundColor, width: 2),
                  shape: BoxShape.circle,
                  color: appTheme(context, userSettingsState.userSettings.themeMode).navigationBarColor,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 30,
                      color: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[GameModeEnum.puzzleMode]!.accentColor,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        iconText,
                        style: TextStyle(
                          fontSize: 10,
                          color: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[GameModeEnum.puzzleMode]!.accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  void _handleClick(final BuildContext context, final PuzzleState state, final PuzzleBloc bloc, final PointsBloc pointsBloc, final UserSettingsState userSettingsState) {
    if (state is PuzzleGameOver) {
      Navigator.of(context).pushAndRemoveUntil(
        CupertinoPageRoute(
          builder: (BuildContext context) {
            return GuessTheMoveApp();
          },
        ),
        (_) => false,
      );
      return;
    } else if (state is PuzzleGuessMove) {
      showAutoResizingModalBottomSheet(
        context,
        userSettingsState,
        'Tipps für den korrekten Zug',
        GameTipsContents(
          puzzleBloc: bloc,
          pointsBloc: pointsBloc,
          userSettingsState: userSettingsState,
          chessBoardController: chessBoardController,
        ),
        titleMainAxisAlignment: MainAxisAlignment.center,
        titleTextAlign: TextAlign.center,
      );
      return;
    } else {
      final ingameState = state as PuzzleIngameState;

      showDraggableModalBottomSheet(
        context,
        userSettingsState,
        'Schachbrett analysieren',
        GameLiveAnalysisContents(
          gameMode: GameModeEnum.puzzleMode,
          analyzedGame: ingameState.analyzedGame,
          analyzedMove: ingameState.puzzleMove,
          userSettingsState: userSettingsState,
          gameChessboardController: chessBoardController,
        ),
        titleMainAxisAlignment: MainAxisAlignment.center,
        padding: const EdgeInsets.symmetric(vertical: 20),
        initialSize: 1,
        minSize: 0.9,
      );
    }
  }
}
