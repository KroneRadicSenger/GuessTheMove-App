import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guess_the_move/components/logo.dart';
import 'package:guess_the_move/components/points_indicator.dart';
import 'package:guess_the_move/theme/theme.dart';

class Header extends StatelessWidget {
  final bool horizontal;

  const Header({this.horizontal = true, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(scaffoldPaddingHorizontal, Platform.isAndroid ? 20 : 5, scaffoldPaddingHorizontal, 20),
        child: horizontal
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Logo(),
                  PointsIndicator(hasMarginTop: !horizontal),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Logo(),
                  PointsIndicator(),
                ],
              ),
      );
}
