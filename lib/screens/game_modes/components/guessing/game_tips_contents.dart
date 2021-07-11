import 'package:chess/chess.dart' as chess;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:guess_the_move/bloc/find_the_grandmaster_moves_bloc.dart';
import 'package:guess_the_move/bloc/points_bloc.dart';
import 'package:guess_the_move/bloc/puzzle_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/components/text_with_accent_field.dart';
import 'package:guess_the_move/model/analyzed_game.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/screens/game_modes/components/chess_board/chessboard_model.dart';
import 'package:guess_the_move/screens/game_modes/components/chess_board/utils/san_utils.dart';
import 'package:guess_the_move/screens/game_modes/components/game_move_in_user_notation.dart';
import 'package:guess_the_move/theme/theme.dart';

class GameTipsContents extends StatelessWidget {
  final FindTheGrandmasterMovesBloc? findTheGrandmasterMovesBloc;
  final PuzzleBloc? puzzleBloc;
  final PointsBloc pointsBloc;
  final UserSettingsState userSettingsState;
  final ChessBoardController chessBoardController;

  const GameTipsContents(
      {Key? key, this.findTheGrandmasterMovesBloc, this.puzzleBloc, required this.pointsBloc, required this.userSettingsState, required this.chessBoardController})
      : assert(findTheGrandmasterMovesBloc != null || puzzleBloc != null, 'A game bloc (find the grandmaster moves or puzzle) must be provided'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (findTheGrandmasterMovesBloc != null) {
      return BlocBuilder<FindTheGrandmasterMovesBloc, FindTheGrandmasterMovesState>(
        bloc: findTheGrandmasterMovesBloc!,
        builder: (context, state) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _buildTipsContentForFindTheGrandmasterMovesGame(context, state as FindTheGrandmasterMovesGuessingMove),
          ),
        ),
      );
    } else {
      return BlocBuilder<PuzzleBloc, PuzzleState>(
        bloc: puzzleBloc!,
        builder: (context, state) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _buildTipsContentForPuzzleGame(context, state as PuzzleGuessMove),
          ),
        ),
      );
    }
  }

  List<Widget> _buildTipsContentForFindTheGrandmasterMovesGame(final BuildContext context, final FindTheGrandmasterMovesGuessingMove state) {
    var lastMove;
    if (state is FindTheGrandmasterMovesGuessingPreviewGuessMove) {
      lastMove = chessBoardController.getLibraryBoard!().undo_move();
    }

    final tipsContents = _buildTipsContent(
        context, state.move, 3, FindTheGrandmasterMovesBloc.buyNextTipPrice, state.removeWorstAnswerTipUsed, state.showPieceTypeTipUsed, state.showActualPieceTipUsed, false);

    if (state is FindTheGrandmasterMovesGuessingPreviewGuessMove) {
      chessBoardController.getLibraryBoard!().make_move(lastMove);
    }

    return tipsContents;
  }

  List<Widget> _buildTipsContentForPuzzleGame(final BuildContext context, final PuzzleGuessMove state) {
    return _buildTipsContent(
        context, state.puzzleMove, 3, PuzzleBloc.buyNextTipPrice, false, state.showPieceTypeTipUsed, state.showActualPieceTipUsed, state.showActualMoveTipUsed);
  }

  List<Widget> _buildTipsContent(final BuildContext context, final AnalyzedMove analyzedMove, final int totalTipsAvailableAmount, final int price,
      final bool removeWorstAnswerTipUsed, final bool showPieceTypeTipUsed, final bool showActualPieceTipUsed, final bool showActualMoveTipUsed) {
    final List<Widget> tipsContent = [];

    int tipsRevealedAmount = 0;

    if (removeWorstAnswerTipUsed) {
      final worstAlternativeMove;
      if (analyzedMove.turn == GrandmasterSide.white) {
        worstAlternativeMove = analyzedMove.alternativeMoves.reduce((current, next) => double.parse(current.signedCPScore) < double.parse(next.signedCPScore) ? current : next);
      } else {
        worstAlternativeMove = analyzedMove.alternativeMoves.reduce((current, next) => double.parse(current.signedCPScore) > double.parse(next.signedCPScore) ? current : next);
      }

      tipsContent.add(_buildTipBox(context, 'Schlechtester Zug', 'Der folgende Zug ist nicht der GM-Zug', null,
          GameMoveInUserNotation(move: worstAlternativeMove.move, turn: analyzedMove.turn, userSettingsState: userSettingsState, isSelected: true, fontSize: 14)));
      tipsRevealedAmount++;
    }

    if (showPieceTypeTipUsed) {
      final move = parseSanMove(analyzedMove.actualMove.move.san, chessBoardController.getLibraryBoard!());
      final pieceType = move.piece;

      final pieceTypeName;
      switch (pieceType) {
        case chess.PieceType.KING:
          pieceTypeName = 'König';
          break;
        case chess.PieceType.QUEEN:
          pieceTypeName = 'Dame';
          break;
        case chess.PieceType.BISHOP:
          pieceTypeName = 'Läufer';
          break;
        case chess.PieceType.KNIGHT:
          pieceTypeName = 'Springer';
          break;
        case chess.PieceType.ROOK:
          pieceTypeName = 'Turm';
          break;
        case chess.PieceType.PAWN:
          pieceTypeName = 'Bauer';
          break;
        default:
          pieceTypeName = '';
      }

      tipsContent.add(_buildTipBox(context, 'Bewegter Stein', 'Der GM bewegt eine Figur des folgenden Typs', pieceTypeName, null));
      tipsRevealedAmount++;
    }

    if (showActualPieceTipUsed) {
      final move = parseSanMove(analyzedMove.actualMove.move.san, chessBoardController.getLibraryBoard!());
      final movingFromSquareName = move.fromAlgebraic;

      tipsContent.add(_buildTipBox(context, 'Bewegte Figur', 'Der GM bewegt die Figur auf folgendem Feld', movingFromSquareName, null));
      tipsRevealedAmount++;
    }

    if (showActualMoveTipUsed) {
      tipsContent.add(_buildTipBox(
          context,
          'Korrekter Zug',
          'Der folgende Zug ist der zu spielende Zug',
          null,
          GameMoveInUserNotation(
            move: analyzedMove.actualMove.move,
            turn: analyzedMove.turn,
            userSettingsState: userSettingsState,
            isSelected: true,
            fontSize: 14,
          )));
      tipsRevealedAmount++;
    }

    if (tipsRevealedAmount == 0) {
      tipsContent.add(
        Center(
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: Text(
              'Es wurde noch kein Tipp freigeschaltet',
              style: TextStyle(color: appTheme(context, userSettingsState.userSettings.themeMode).textColor),
            ),
          ),
        ),
      );
    }

    if (tipsRevealedAmount < totalTipsAvailableAmount) {
      tipsContent.add(_buildUnlockNextTipButton(context, price));
    }

    return tipsContent;
  }

  Widget _buildTipBox(final BuildContext context, final String title, final String description, final String? valueText, final Widget? valueWidget) {
    final gameMode = findTheGrandmasterMovesBloc != null ? GameModeEnum.findTheGrandmasterMoves : GameModeEnum.puzzleMode;

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            margin: EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: appTheme(context, userSettingsState.userSettings.themeMode).cardBackgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    child: Text(
                      title,
                      style: TextStyle(
                        color: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[gameMode]!.accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  TextWithAccentField(
                    gameMode: gameMode,
                    text: description,
                    userSettingsState: userSettingsState,
                    accentBoxWidget: valueWidget,
                    accentBoxText: valueText,
                    accentBoxTextBold: true,
                    valuePadding: EdgeInsets.symmetric(horizontal: 15, vertical: valueText != null ? 6 : 3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUnlockNextTipButton(BuildContext context, final int price) {
    final gameMode = findTheGrandmasterMovesBloc != null ? GameModeEnum.findTheGrandmasterMoves : GameModeEnum.puzzleMode;

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            margin: EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: appTheme(context, userSettingsState.userSettings.themeMode).cardBackgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    child: Text(
                      'Nächster Tipp',
                      style: TextStyle(
                        color: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[gameMode]!.accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      if (findTheGrandmasterMovesBloc != null) {
                        findTheGrandmasterMovesBloc!.add(FindTheGrandmasterMovesShowNextTipEvent(context, pointsBloc));
                      } else {
                        puzzleBloc!.add(PuzzleShowNextTipEvent(context, pointsBloc));
                      }
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[gameMode]!.accentColor,
                      primary: appTheme(context, userSettingsState.userSettings.themeMode).scaffoldBackgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: SvgPicture.asset(
                      'assets/svg/two-coins.svg',
                      width: 28,
                      height: 28,
                      color: appTheme(context, userSettingsState.userSettings.themeMode).scaffoldBackgroundColor,
                    ),
                    label: Text('Für $price Punkte freischalten', style: TextStyle(color: appTheme(context, userSettingsState.userSettings.themeMode).scaffoldBackgroundColor)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
