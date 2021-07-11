import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/model/summary_data.dart';
import 'package:guess_the_move/model/user_settings.dart';
import 'package:guess_the_move/theme/theme.dart';

class SummaryPointsGivenGraph extends StatelessWidget {
  final SummaryData _summaryData;
  final GameModeEnum _gameMode;
  final UserSettings _userSettings;

  SummaryPointsGivenGraph({Key? key, required SummaryData summaryData, required final GameModeEnum gameMode, required UserSettings userSettings})
      : this._summaryData = summaryData,
        this._gameMode = gameMode,
        this._userSettings = userSettings;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.13,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(18)),
          color: appTheme(context, _userSettings.themeMode).scaffoldBackgroundColor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(height: 20),
            Text(
              'Punkteverlauf',
              style: TextStyle(color: appTheme(context, _userSettings.themeMode).textColor, fontSize: 21, fontWeight: FontWeight.bold, letterSpacing: 2),
              textAlign: TextAlign.center,
            ),
            Container(height: 14),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  width: _summaryData.getTotalMovesGuessedAmount() * 30,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50, right: 16.0, left: 6.0),
                    child: LineChart(
                      summaryDataAsLineChartData(context),
                    ),
                  ),
                ),
              ),
            ),
            Container(height: 10),
          ],
        ),
      ),
    );
  }

  LineChartData summaryDataAsLineChartData(final BuildContext context) {
    return LineChartData(
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: appTheme(context, _userSettings.themeMode).gameModeThemes[_gameMode]!.accentColor,
          tooltipRoundedRadius: 8,
          getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
            return lineBarsSpot.map((lineBarSpot) {
              return LineTooltipItem(
                _summaryData.guessEvaluatedList[lineBarSpot.x.toInt() - 1].chosenMove.move.san,
                TextStyle(
                  color: appTheme(context, _userSettings.themeMode).scaffoldBackgroundColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              );
            }).toList();
          },
        ),
      ),
      gridData: FlGridData(
        show: false,
      ),
      titlesData: FlTitlesData(
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          getTextStyles: (value) => const TextStyle(
            color: Color(0xff72719b),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          margin: 10,
          interval: 1,
        ),
        leftTitles: SideTitles(
          showTitles: true,
          getTextStyles: (value) => TextStyle(
            color: appTheme(context, _userSettings.themeMode).textColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          interval: 5,
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: const Border(
          bottom: BorderSide(
            color: Color(0xff4e4965),
            width: 4,
          ),
          left: BorderSide(
            color: Colors.transparent,
          ),
          right: BorderSide(
            color: Colors.transparent,
          ),
          top: BorderSide(
            color: Colors.transparent,
          ),
        ),
      ),
      lineBarsData: summaryDataAsLineBarsData(context),
    );
  }

  List<LineChartBarData> summaryDataAsLineBarsData(final BuildContext context) {
    return [
      LineChartBarData(
        spots: List<FlSpot>.generate(_summaryData.getTotalMovesGuessedAmount(), (index) {
          return FlSpot(index.toDouble() + 1, _summaryData.guessEvaluatedList[index].pointsGiven.toDouble());
        }),
        isCurved: false,
        colors: [
          appTheme(context, _userSettings.themeMode).gameModeThemes[_gameMode]!.accentColor,
        ],
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(show: true),
        belowBarData: BarAreaData(
          show: false,
        ),
      ),
    ];
  }
}
