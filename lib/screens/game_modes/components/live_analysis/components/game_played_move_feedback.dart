import 'package:flutter/widgets.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/model/analyzed_game.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/screens/game_modes/components/game_move_in_user_notation.dart';
import 'package:guess_the_move/screens/game_modes/components/game_moves_list.dart';
import 'package:guess_the_move/screens/game_modes/components/game_pawn_or_mate_score.dart';
import 'package:guess_the_move/theme/theme.dart';

class GamePlayedMoveFeedback extends StatelessWidget {
  final GameModeEnum gameMode;
  final UserSettingsState userSettingsState;
  final GrandmasterSide turn;
  final Move move;
  final AnalyzedMoveType moveType;
  final String pv;
  final String signedCpScore;

  const GamePlayedMoveFeedback(
      {Key? key,
      required this.gameMode,
      required this.move,
      required this.userSettingsState,
      required this.turn,
      required this.moveType,
      required this.pv,
      required this.signedCpScore})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pvStartMove = int.parse(pv.substring(0, pv.indexOf('.')));
    var pvStartHalfMove = 0;

    // remove move number
    var pvCorrected = pv.substring(pv.indexOf('.') + 2, pv.length);

    // check if move is second half move
    if (pv[pv.indexOf('.') + 1] == '.') {
      pvCorrected = pvCorrected.substring(1, pvCorrected.length);
      pvStartHalfMove = 1;
    }

    final pvMovesList = pvCorrected.split(' ').where((component) => !component.contains('\.')).toList();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Zug'),
              Container(
                decoration: BoxDecoration(
                  color: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[gameMode]!.accentColor,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                margin: const EdgeInsets.only(top: 3),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: GameMoveInUserNotation(
                    move: move,
                    turn: turn,
                    userSettingsState: userSettingsState,
                    fontSize: 14,
                    isSelected: true,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('PV'),
                  GameMovesList(
                    gameMode: gameMode,
                    startMove: pvStartMove,
                    startHalfMove: pvStartHalfMove,
                    movesList: pvMovesList,
                    skipFirstMove: true, // dont show actual move played in pv
                    scrollToEnd: false,
                    margin: EdgeInsets.only(top: 3),
                  ),
                ],
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(moveType.name),
              Container(height: 3),
              GamePawnOrMateScore(signedCpOrMateScore: signedCpScore),
            ],
          )
        ],
      ),
    );
  }
}
