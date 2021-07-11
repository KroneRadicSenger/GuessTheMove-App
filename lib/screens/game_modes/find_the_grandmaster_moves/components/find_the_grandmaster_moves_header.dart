import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guess_the_move/components/points_indicator.dart';
import 'package:guess_the_move/screens/game_modes/components/game_move_info.dart';
import 'package:guess_the_move/theme/theme.dart';

class FindTheGrandmasterMovesHeader extends StatelessWidget {
  final Function() onPressHome;

  FindTheGrandmasterMovesHeader({Key? key, required this.onPressHome}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(scaffoldPaddingHorizontal, Platform.isAndroid ? 20 : 5, scaffoldPaddingHorizontal, 20),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GameMoveInfo(onPressHome: onPressHome),
          PointsIndicator(),
        ],
      ),
    );
  }
}
