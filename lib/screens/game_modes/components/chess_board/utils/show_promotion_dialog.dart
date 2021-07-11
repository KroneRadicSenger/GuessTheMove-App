import 'package:chess/chess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:guess_the_move/screens/game_modes/components/chess_board/chessboard_model.dart';

Future<ChessPieceTypeEnum?> showPromotionDialog(final BuildContext context, final Color turn) {
  final queenPieceType = turn == Color.WHITE ? ChessPieceTypeEnum.whiteQueen : ChessPieceTypeEnum.blackQueen;
  final knightPieceType = turn == Color.WHITE ? ChessPieceTypeEnum.whiteKnight : ChessPieceTypeEnum.blackKnight;
  final rookPieceType = turn == Color.WHITE ? ChessPieceTypeEnum.whiteRook : ChessPieceTypeEnum.blackRook;
  final bishopPieceType = turn == Color.WHITE ? ChessPieceTypeEnum.whiteBishop : ChessPieceTypeEnum.blackBishop;

  return showDialog<ChessPieceTypeEnum>(
    context: context,
    builder: (BuildContext context) => SimpleDialog(
      title: Text('Wähle eine Figur für die Bauernumwandlung'),
      children: [
        PromotionDialogItem(
          icon: SvgPicture.asset(
            queenPieceType.assetName,
            width: 40,
            height: 40,
          ),
          onPressed: () => Navigator.pop(context, queenPieceType),
          text: 'Dame',
        ),
        PromotionDialogItem(
          icon: SvgPicture.asset(
            knightPieceType.assetName,
            width: 40,
            height: 40,
          ),
          onPressed: () => Navigator.pop(context, knightPieceType),
          text: 'Springer',
        ),
        PromotionDialogItem(
          icon: SvgPicture.asset(
            rookPieceType.assetName,
            width: 40,
            height: 40,
          ),
          onPressed: () => Navigator.pop(context, rookPieceType),
          text: 'Turm',
        ),
        PromotionDialogItem(
          icon: SvgPicture.asset(
            bishopPieceType.assetName,
            width: 40,
            height: 40,
          ),
          onPressed: () => Navigator.pop(context, bishopPieceType),
          text: 'Läufer',
        ),
      ],
    ),
  );
}

class PromotionDialogItem extends StatelessWidget {
  final Widget icon;
  final String text;
  final VoidCallback onPressed;

  const PromotionDialogItem({Key? key, required this.icon, required this.text, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialogOption(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          icon,
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 16.0),
            child: Text(text, style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }
}
