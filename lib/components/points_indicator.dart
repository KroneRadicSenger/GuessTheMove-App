import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:guess_the_move/bloc/points_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/theme/theme.dart';

class PointsIndicator extends StatelessWidget {
  final bool hasMarginTop;
  final EdgeInsets padding;
  final double topTextSize;
  final double bottomTextSize;
  final double iconSize;
  final double iconRightSpacing;

  const PointsIndicator(
      {this.hasMarginTop = false,
      this.padding = const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      this.topTextSize = 10,
      this.bottomTextSize = 15,
      this.iconSize = 26,
      this.iconRightSpacing = 5,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserSettingsBloc, UserSettingsState>(builder: (context, userSettingsState) {
      return BlocBuilder<PointsBloc, PointsState>(builder: (context, pointsState) {
        return Container(
          margin: EdgeInsets.only(top: hasMarginTop ? 15 : 0),
          decoration:
              BoxDecoration(color: appTheme(context, userSettingsState.userSettings.themeMode).scaffoldBackgroundColor, borderRadius: BorderRadius.all(const Radius.circular(5))),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
            ),
            padding: padding,
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/svg/two-coins.svg',
                  width: iconSize,
                  height: iconSize,
                  color: appTheme(context, userSettingsState.userSettings.themeMode).textColor,
                ),
                Container(width: 10),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: iconRightSpacing),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Punkte',
                        style: TextStyle(color: appTheme(context, userSettingsState.userSettings.themeMode).textColor, height: 1.0, fontSize: topTextSize),
                      ),
                      Text(
                        pointsState.points.amount.toString(),
                        style: TextStyle(color: appTheme(context, userSettingsState.userSettings.themeMode).textColor, height: 1.0, fontSize: bottomTextSize),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      });
    });
  }
}
