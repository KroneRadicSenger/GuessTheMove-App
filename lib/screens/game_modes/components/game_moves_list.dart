import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/components/horizontal_list.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/screens/game_modes/components/chess_board/chess_board.dart';
import 'package:guess_the_move/theme/theme.dart';

class GameMovesList extends StatelessWidget {
  final int startMove;
  final int startHalfMove;
  final List<String> movesList;
  final bool skipFirstMove;
  final GameModeEnum gameMode;
  final bool scrollToEnd;
  final EdgeInsets margin;

  GameMovesList(
      {this.startMove = 1,
      this.startHalfMove = 0,
      required this.movesList,
      this.skipFirstMove = false,
      required this.gameMode,
      this.scrollToEnd = true,
      this.margin = const EdgeInsets.symmetric(vertical: 20),
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) => BlocBuilder<UserSettingsBloc, UserSettingsState>(
        builder: (context, userSettingsState) {
          final List<Widget> elements = [];
          for (int i = (skipFirstMove ? 1 : 0); i < movesList.length; i++) {
            final ply = (i + (startMove - 1) * 2 + startHalfMove);

            if (ply.isEven) {
              elements.add(
                Container(
                  margin: const EdgeInsets.only(left: 10),
                  child: Text(
                    (ply ~/ 2 + 1).toString() + ". ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: appTheme(context, userSettingsState.userSettings.themeMode).textColor,
                    ),
                  ),
                ),
              );
            }
            // TODO Here, we currently always show the moves in uci notation, consider writing a method transforming it into the configured notations
            elements.add(
              Text(
                movesList[i],
                style: TextStyle(
                  fontWeight: (startHalfMove == 0 && startMove == 1 && i == (movesList.length - 1)) ? FontWeight.bold : FontWeight.normal,
                  fontSize: 16,
                  color: (startHalfMove == 0 && startMove == 1 && i == (movesList.length - 1))
                      ? appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[gameMode]!.accentColor
                      : appTheme(context, userSettingsState.userSettings.themeMode).textColor,
                ),
              ),
            );
          }

          return HorizontalList(
            height: 20,
            margin: margin,
            automaticallyScrollToEnd: scrollToEnd,
            scrollSpeedMillis: moveAnimationDurationMillis,
            spaceBetweenElements: 5,
            elements: elements,
          );
        },
      );
}
