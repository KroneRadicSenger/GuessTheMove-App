import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class GamePawnOrMateScore extends StatelessWidget {
  final String signedCpOrMateScore;

  const GamePawnOrMateScore({Key? key, required this.signedCpOrMateScore}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMateScore = signedCpOrMateScore.startsWith('M');
    final isWhiteLeading = (isMateScore && signedCpOrMateScore[1] != '-') || (!isMateScore && signedCpOrMateScore.startsWith('+'));

    var pawnOrMateScore = signedCpOrMateScore;
    if (!isMateScore) {
      final centipawns = double.parse(signedCpOrMateScore.substring(1, signedCpOrMateScore.length));
      pawnOrMateScore = signedCpOrMateScore[0] + (centipawns / 100.0).toString();
    }

    final textColor = isWhiteLeading ? Colors.black : Colors.white;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      decoration: BoxDecoration(
        color: isWhiteLeading ? Colors.white : Colors.black,
        borderRadius: BorderRadius.all(Radius.circular(5)),
        border: Border.all(color: textColor),
      ),
      child: Text(pawnOrMateScore,
          style: TextStyle(
            color: textColor,
          )),
    );
  }
}
