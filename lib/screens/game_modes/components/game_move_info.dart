import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/find_the_grandmaster_moves_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/screens/game_modes/components/chess_board/chessboard_model.dart';
import 'package:guess_the_move/theme/theme.dart';

class GameMoveInfo extends StatelessWidget {
  final int? fullMoveNumber;
  final ChessColor? turn;
  final Function() onPressHome;

  const GameMoveInfo({Key? key, this.fullMoveNumber, this.turn, required this.onPressHome}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (fullMoveNumber != null && turn != null) {
      return _buildContents(context, fullMoveNumber!, turn!);
    }

    return BlocBuilder<UserSettingsBloc, UserSettingsState>(
      builder: (context, userSettingsState) => BlocBuilder<FindTheGrandmasterMovesBloc, FindTheGrandmasterMovesState>(
        builder: (context, state) {
          assert(state is FindTheGrandmasterMovesIngameState, 'Game header should only be rendered for ingame states');

          var ingameState = state as FindTheGrandmasterMovesIngameState;
          var fullMoveNumber = ingameState.getFullMoveNumber();
          var turn = ingameState.getTurn();

          return _buildContents(context, fullMoveNumber, turn);
        },
      ),
    );
  }

  Widget _buildContents(final BuildContext context, final int fullMoveNumber, final ChessColor turn) {
    return BlocBuilder<UserSettingsBloc, UserSettingsState>(
      builder: (context, userSettingsState) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: turn == ChessColor.white ? appTheme(context, ThemeMode.light).scaffoldBackgroundColor : appTheme(context, ThemeMode.dark).scaffoldBackgroundColor,
            ),
            width: 42,
            height: 42,
            child: IconButton(
              icon: Icon(Icons.home),
              iconSize: 20,
              color: turn == ChessColor.black ? appTheme(context, ThemeMode.light).scaffoldBackgroundColor : appTheme(context, ThemeMode.dark).scaffoldBackgroundColor,
              onPressed: onPressHome,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 25),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(topRight: Radius.circular(5), bottomRight: Radius.circular(5)),
              color: turn == ChessColor.white ? appTheme(context, ThemeMode.light).scaffoldBackgroundColor : appTheme(context, ThemeMode.dark).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(color: appTheme(context, userSettingsState.userSettings.themeMode).textColor.withOpacity(.1), offset: Offset(0, 2), blurRadius: 2, spreadRadius: 0),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aktueller Zug',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, height: 1.0, color: turn == ChessColor.white ? Colors.black : Colors.white),
                ),
                Text(
                  '$fullMoveNumber ${turn == ChessColor.white ? 'Weiß' : 'Schwarz'}',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, height: 1.0, color: turn == ChessColor.white ? Colors.black : Colors.white),
                ),
              ],
            ),
          ),
          /*ClipRRect(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(5), bottomLeft: Radius.circular(5)),
                child: SvgPicture.asset(
                  isDarkTheme(context, userSettingsState.userSettings.themeMode) ? 'assets/svg/app_icon_dark.svg' : 'assets/svg/app_icon_light.svg',
                  height: 44,
                  width: 44,
                ),
              ),*/
        ],
      ),
    );
  }
}
