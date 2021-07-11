import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/screens/game_modes/components/chess_board/chessboard_model.dart';
import 'package:guess_the_move/screens/game_modes/components/game_move_info.dart';
import 'package:guess_the_move/theme/theme.dart';

class TimeBattleHeader extends StatelessWidget {
  final int? fullMoveNumber;
  final ChessColor? turn;
  final int totalMovesGuessed;
  final int movesGuessedCorrect;
  final Function() onPressHome;

  TimeBattleHeader({
    Key? key,
    this.fullMoveNumber,
    this.turn,
    required this.totalMovesGuessed,
    required this.movesGuessedCorrect,
    required this.onPressHome,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(scaffoldPaddingHorizontal, Platform.isAndroid ? 20 : 5, scaffoldPaddingHorizontal, 20),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GameMoveInfo(
            fullMoveNumber: fullMoveNumber,
            turn: turn,
            onPressHome: onPressHome,
          ),
          _buildGameProgressInfo(),
        ],
      ),
    );
  }

  Widget _buildGameProgressInfo() {
    return BlocBuilder<UserSettingsBloc, UserSettingsState>(
      builder: (context, userSettingsState) {
        return Container(
          decoration:
              BoxDecoration(color: appTheme(context, userSettingsState.userSettings.themeMode).scaffoldBackgroundColor, borderRadius: BorderRadius.all(const Radius.circular(5))),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.0),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/svg/confirmed.svg',
                    width: 24.0,
                    height: 24.0,
                    color: appTheme(context, userSettingsState.userSettings.themeMode).textColor,
                  ),
                  Container(width: 10),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$movesGuessedCorrect / $totalMovesGuessed',
                        style: TextStyle(color: appTheme(context, userSettingsState.userSettings.themeMode).textColor, height: 1.0, fontSize: 15.0),
                      ),
                      Text(
                        'Züge korrekt',
                        style: TextStyle(color: appTheme(context, userSettingsState.userSettings.themeMode).textColor, height: 1.0, fontSize: 9.0),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
