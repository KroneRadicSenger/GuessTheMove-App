import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/screens/game_modes/components/chess_board/chessboard_model.dart';
import 'package:guess_the_move/model/player.dart';
import 'package:guess_the_move/theme/theme.dart';

class GamePlayerName extends StatelessWidget {
  final Player player;
  final ChessColor playerColor;
  final bool isPlayersTurn;

  GamePlayerName(this.player, this.playerColor, this.isPlayersTurn, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserSettingsBloc, UserSettingsState>(
      builder: (context, userSettingsState) => Text(
        player.getFirstAndLastName(),
        textAlign: playerColor == ChessColor.black ? TextAlign.left : TextAlign.right,
        style: TextStyle(
          color: appTheme(context, userSettingsState.userSettings.themeMode).textColor,
          fontSize: 17,
          fontWeight: isPlayersTurn ? FontWeight.w500 : FontWeight.w300,
        ),
      ),
    );
  }
}
