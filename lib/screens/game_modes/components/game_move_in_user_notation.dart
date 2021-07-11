import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/screens/game_modes/components/chess_board/chessboard_model.dart';
import 'package:guess_the_move/model/analyzed_game.dart';
import 'package:guess_the_move/model/user_settings.dart';
import 'package:guess_the_move/theme/theme.dart';

class GameMoveInUserNotation extends StatelessWidget {
  final Move move;
  final GrandmasterSide turn;
  final UserSettingsState userSettingsState;
  final bool isSelected;
  final double fontSize;

  const GameMoveInUserNotation({Key? key, required this.move, required this.turn, required this.userSettingsState, this.isSelected = false, this.fontSize = 16}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (userSettingsState.userSettings.moveNotation) {
      case MoveNotationEnum.san:
        return _buildTextMove(context, move.san);
      case MoveNotationEnum.uci:
        return _buildTextMove(context, move.uci);
      case MoveNotationEnum.fan:
        return _buildTextWithIconMove(context, move.san);
    }
  }

  Widget _buildTextMove(final BuildContext context, final String moveInConfiguredNotationText) {
    var textColor =
        isSelected ? appTheme(context, userSettingsState.userSettings.themeMode).scaffoldBackgroundColor : appTheme(context, userSettingsState.userSettings.themeMode).textColor;

    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Text(
              moveInConfiguredNotationText,
              style: TextStyle(
                fontSize: fontSize,
                color: textColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextWithIconMove(final BuildContext context, final String moveInSanNotation) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIconForSanMove(moveInSanNotation),
          _buildSuffixForSanMove(context, moveInSanNotation),
        ],
      ),
    );
  }

  Widget _buildIconForSanMove(final String moveInSanNotation) {
    final ChessPieceTypeEnum pieceType;

    if (moveInSanNotation.startsWith('K')) {
      pieceType = turn == GrandmasterSide.white ? ChessPieceTypeEnum.whiteKing : ChessPieceTypeEnum.blackKing;
    } else if (moveInSanNotation.startsWith('Q')) {
      pieceType = turn == GrandmasterSide.white ? ChessPieceTypeEnum.whiteQueen : ChessPieceTypeEnum.blackQueen;
    } else if (moveInSanNotation.startsWith('R')) {
      pieceType = turn == GrandmasterSide.white ? ChessPieceTypeEnum.whiteRook : ChessPieceTypeEnum.blackRook;
    } else if (moveInSanNotation.startsWith('B')) {
      pieceType = turn == GrandmasterSide.white ? ChessPieceTypeEnum.whiteBishop : ChessPieceTypeEnum.blackBishop;
    } else if (moveInSanNotation.startsWith('N')) {
      pieceType = turn == GrandmasterSide.white ? ChessPieceTypeEnum.whiteKnight : ChessPieceTypeEnum.blackKnight;
    } else {
      return Container();
    }

    return SvgPicture.asset(
      pieceType.assetName,
      semanticsLabel: pieceType.toString().split('.').last,
      width: fontSize + 10,
    );
  }

  Widget _buildSuffixForSanMove(final BuildContext context, final String moveInSanNotation) {
    final textStyle = TextStyle(
        fontSize: fontSize,
        color: isSelected
            ? appTheme(context, userSettingsState.userSettings.themeMode).scaffoldBackgroundColor
            : appTheme(context, userSettingsState.userSettings.themeMode).textColor,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal);

    if (moveInSanNotation.startsWith('K')) {
      return Text(moveInSanNotation.replaceFirst('K', ''), style: textStyle);
    } else if (moveInSanNotation.startsWith('Q')) {
      return Text(moveInSanNotation.replaceFirst('Q', ''), style: textStyle);
    } else if (moveInSanNotation.startsWith('R')) {
      return Text(moveInSanNotation.replaceFirst('R', ''), style: textStyle);
    } else if (moveInSanNotation.startsWith('B')) {
      return Text(moveInSanNotation.replaceFirst('B', ''), style: textStyle);
    } else if (moveInSanNotation.startsWith('N')) {
      return Text(moveInSanNotation.replaceFirst('N', ''), style: textStyle);
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Text(moveInSanNotation, style: textStyle),
      );
    }
  }
}
