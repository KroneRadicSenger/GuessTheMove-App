import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guess_the_move/model/analyzed_game.dart';

class GameWinningChance extends StatelessWidget {
  final GrandmasterSide grandmasterSide;
  final GrandmasterSide playerSide;
  final double gmExpectation;

  const GameWinningChance({Key? key, required this.grandmasterSide, required this.playerSide, required this.gmExpectation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final turnExpectation = grandmasterSide == playerSide ? gmExpectation : (1 - gmExpectation);

    var turnExpectationInPercentString = (turnExpectation * 100).toString();
    turnExpectationInPercentString = turnExpectationInPercentString.substring(0, min(turnExpectationInPercentString.length, 2)).replaceAll('\.', '');
    turnExpectationInPercentString += '%';

    final boxColor = playerSide == GrandmasterSide.black ? Colors.black : Colors.white;
    final textColor = playerSide == GrandmasterSide.white ? Colors.black : Colors.white;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      decoration: BoxDecoration(
        color: boxColor,
        borderRadius: BorderRadius.all(Radius.circular(5)),
        border: Border.all(color: textColor),
      ),
      child: Text(turnExpectationInPercentString,
          style: TextStyle(
            color: textColor,
          )),
    );
  }
}
