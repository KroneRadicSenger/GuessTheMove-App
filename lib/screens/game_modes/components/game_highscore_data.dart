import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/theme/theme.dart';

class GameHighscoreData extends StatelessWidget {
  final UserSettingsState userSettingsState;
  final int points;
  final int correctMovesPlayedAmount;
  final int totalMovesPlayedAmount;

  const GameHighscoreData({Key? key, required this.userSettingsState, required this.points, required this.correctMovesPlayedAmount, required this.totalMovesPlayedAmount})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset('assets/svg/two-coins.svg', width: 14, height: 14, color: appTheme(context, userSettingsState.userSettings.themeMode).textColor),
            Container(
              margin: const EdgeInsets.only(left: 10),
              child: Text(
                '$points',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: appTheme(context, userSettingsState.userSettings.themeMode).textColor,
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset('assets/svg/confirmed.svg', width: 12, height: 12, color: appTheme(context, userSettingsState.userSettings.themeMode).textColor),
            Container(
              margin: const EdgeInsets.only(left: 10),
              child: Text(
                '$correctMovesPlayedAmount / $totalMovesPlayedAmount',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: appTheme(context, userSettingsState.userSettings.themeMode).textColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
