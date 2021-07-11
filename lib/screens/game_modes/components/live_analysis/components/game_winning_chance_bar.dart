import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GameWinningChanceBar extends StatelessWidget {
  final Stream<String> signedCpOrMateScoreStream;

  const GameWinningChanceBar({Key? key, required this.signedCpOrMateScoreStream}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: signedCpOrMateScoreStream,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        var pawnOrMateScore;
        double winningChance;

        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            pawnOrMateScore = '+0';
            winningChance = 0.5;
            break;
          case ConnectionState.active:
          case ConnectionState.done:
            final signedCpOrMateScore = snapshot.data!;
            final isMateScore = signedCpOrMateScore.startsWith('M');

            if (!isMateScore) {
              final centipawns = double.parse(signedCpOrMateScore.substring(1, signedCpOrMateScore.length));
              pawnOrMateScore = signedCpOrMateScore[0] + (centipawns / 100.0).toString();
              winningChance = 1 / (1 + pow(10, -(centipawns / 100.0) / 4));
            } else {
              pawnOrMateScore = signedCpOrMateScore;
              winningChance = 1;
            }
            break;
        }

        return Container(
          height: 15,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(4.0),
          ),
          alignment: Alignment.centerLeft,
          child: LayoutBuilder(builder: (final BuildContext context, final BoxConstraints constraints) {
            return Container(
              width: constraints.maxWidth * winningChance,
              height: 15,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.0),
              ),
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  pawnOrMateScore,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
