import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/theme/theme.dart';

class WeeklyStats extends StatefulWidget {
  final List<double> weeklyGames;

  WeeklyStats({required this.weeklyGames});

  @override
  State<StatefulWidget> createState() => WeeklyStatsState();
}

class WeeklyStatsState extends State<WeeklyStats> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((_) => _scrollController.jumpTo(_scrollController.position.maxScrollExtent));
  }

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
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: _scrollController,
                    child: Container(
                      width: 7 * 50,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 30, right: 16.0, left: 6.0),
                        child: BarChart(
                          BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: getMaxY(widget.weeklyGames),
                              barTouchData: BarTouchData(
                                enabled: true,
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
                                  margin: 8,
                                  getTitles: (double value) {
                                    return getWeekdayBefore((6 - value).toInt());
                                  },
                                ),
                                leftTitles: SideTitles(showTitles: false),
                              ),
                              borderData: FlBorderData(
                                show: false,
                              ),
                              barGroups: getBars(widget.weeklyGames, state)),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      });

  String getWeekdayBefore(final int daysBefore) {
    final DateTime day = DateTime.now();
    switch ((day.weekday - daysBefore) % 7) {
      case 0:
        return 'So';
      case 1:
        return 'Mo';
      case 2:
        return 'Di';
      case 3:
        return 'Mi';
      case 4:
        return 'Do';
      case 5:
        return 'Fr';
      case 6:
        return 'Sa';
      default:
        return '';
    }
  }

  List<BarChartGroupData> getBars(final List<double> values, final UserSettingsState state) {
    final List<BarChartGroupData> bars = [];
    for (int i = 0; i < values.length / 4; i++) {
      bars.add(
        BarChartGroupData(
          barsSpace: getBarSpace(values, 4 * i),
          x: i,
          barRods: [
            BarChartRodData(
                y: values.elementAt(4 * i), colors: [appTheme(context, state.userSettings.themeMode).gameModeThemes[GameModeEnum.findTheGrandmasterMoves]!.accentColor]),
            BarChartRodData(y: values.elementAt(4 * i + 1), colors: [appTheme(context, state.userSettings.themeMode).gameModeThemes[GameModeEnum.timeBattle]!.accentColor]),
            BarChartRodData(y: values.elementAt(4 * i + 2), colors: [appTheme(context, state.userSettings.themeMode).gameModeThemes[GameModeEnum.survivalMode]!.accentColor]),
            BarChartRodData(y: values.elementAt(4 * i + 3), colors: [appTheme(context, state.userSettings.themeMode).gameModeThemes[GameModeEnum.puzzleMode]!.accentColor]),
          ],
          showingTooltipIndicators: _getTooltipsList([values.elementAt(4 * i), values.elementAt(4 * i + 1), values.elementAt(4 * i + 2), values.elementAt(4 * i + 3)]),
        ),
      );
    }
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

  double getBarSpace(final List<double> values, int index) {
    double max = 0;
    for (int i = index; i < index + 4; i++) {
      if (values.elementAt(i) > max) {
        max = values.elementAt(i);
      }
    }
    if (max < 10) {
      return 2;
    } else if (max < 100) {
      return 5;
    } else if (max < 1000) {
      return 10;
    } else {
      return 15;
    }
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
