import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/theme/theme.dart';

class TotalStats extends StatefulWidget {
  final List<double> totalGames;

  TotalStats({required this.totalGames});

  @override
  State<StatefulWidget> createState() => TotalStatsState();
}

class TotalStatsState extends State<TotalStats> {
  @override
  Widget build(BuildContext context) => BlocBuilder<UserSettingsBloc, UserSettingsState>(builder: (context, state) {
        return AspectRatio(
          aspectRatio: 1.7,
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            color: appTheme(context, state.userSettings.themeMode).cardBackgroundColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    width: 300,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 30, right: 16.0, left: 6.0),
                      child: BarChart(
                        BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: getMaxY(widget.totalGames),
                            barTouchData: BarTouchData(
                              enabled: false,
                              touchTooltipData: BarTouchTooltipData(
                                tooltipBgColor: Colors.transparent,
                                tooltipPadding: const EdgeInsets.all(0),
                                tooltipMargin: 8,
                                getTooltipItem: (
                                  BarChartGroupData group,
                                  int groupIndex,
                                  BarChartRodData rod,
                                  int rodIndex,
                                ) {
                                  return BarTooltipItem(
                                    rod.y.round().toString(),
                                    TextStyle(
                                      color: appTheme(context, state.userSettings.themeMode).textColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: SideTitles(
                                  showTitles: true,
                                  getTextStyles: (value) => const TextStyle(color: Color(0xff7589a2), fontWeight: FontWeight.bold, fontSize: 14),
                                  margin: 12,
                                  getTitles: (double value) {
                                    return getMode(value);
                                  }),
                              leftTitles: SideTitles(showTitles: false),
                            ),
                            borderData: FlBorderData(
                              show: false,
                            ),
                            barGroups: getBars(widget.totalGames, state)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      });

  String getMode(final double mode) {
    switch (mode.toInt()) {
      case 0:
        return 'GM Zug';
      case 1:
        return 'Zeitdruck';
      case 2:
        return 'Überleben';
      case 3:
        return 'Puzzle';
      default:
        return '';
    }
  }

  List<BarChartGroupData> getBars(final List<double> values, final UserSettingsState state) {
    final List<BarChartGroupData> bars = [];
    bars.add(
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(y: values.elementAt(0), colors: [appTheme(context, state.userSettings.themeMode).gameModeThemes[GameModeEnum.findTheGrandmasterMoves]!.accentColor]),
        ],
        showingTooltipIndicators: _getTooltipsList([values.elementAt(0)]),
      ),
    );
    bars.add(
      BarChartGroupData(
        x: 1,
        barRods: [
          BarChartRodData(y: values.elementAt(1), colors: [appTheme(context, state.userSettings.themeMode).gameModeThemes[GameModeEnum.timeBattle]!.accentColor]),
        ],
        showingTooltipIndicators: _getTooltipsList([values.elementAt(1)]),
      ),
    );
    bars.add(
      BarChartGroupData(
        x: 2,
        barRods: [
          BarChartRodData(y: values.elementAt(2), colors: [appTheme(context, state.userSettings.themeMode).gameModeThemes[GameModeEnum.survivalMode]!.accentColor]),
        ],
        showingTooltipIndicators: _getTooltipsList([values.elementAt(2)]),
      ),
    );
    bars.add(
      BarChartGroupData(
        x: 3,
        barRods: [
          BarChartRodData(y: values.elementAt(3), colors: [appTheme(context, state.userSettings.themeMode).gameModeThemes[GameModeEnum.puzzleMode]!.accentColor]),
        ],
        showingTooltipIndicators: _getTooltipsList([values.elementAt(3)]),
      ),
    );
    return bars;
  }

  double getMaxY(final List<double> values) {
    double max = 0;
    values.forEach((element) {
      if (element > max) {
        max = element;
      }
    });
    return max * 1.2;
  }

  List<int> _getTooltipsList(final List<double> values) {
    final List<int> list = [];
    for (int i = 0; i < values.length; i++) {
      if (values.elementAt(i) != 0.0) {
        list.add(i);
      }
    }
    return list;
  }
}
