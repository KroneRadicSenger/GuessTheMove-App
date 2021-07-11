import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_launcher_icons/custom_exceptions.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/repository/dao/find_the_grandmaster_moves_games_played_dao.dart';
import 'package:guess_the_move/repository/dao/puzzle_games_played_dao.dart';
import 'package:guess_the_move/repository/dao/survival_games_played_dao.dart';
import 'package:guess_the_move/repository/dao/time_battle_games_played_dao.dart';
import 'package:guess_the_move/screens/stats/components/diagrams/monthly_stats.dart';
import 'package:guess_the_move/screens/stats/components/diagrams/total_stats.dart';
import 'package:guess_the_move/theme/theme.dart';

import 'daily_stats.dart';
import 'weekly_stats.dart';
import 'yearly_stats.dart';

class StatsDiagram extends StatefulWidget {
  final String selectedTimeFrame;

  const StatsDiagram({Key? key, required this.selectedTimeFrame}) : super(key: key);
  @override
  _StatsDiagramState createState() => _StatsDiagramState();
}

class _StatsDiagramState extends State<StatsDiagram> {
  @override
  Widget build(BuildContext context) => BlocBuilder<UserSettingsBloc, UserSettingsState>(builder: (context, userSettingsState) {
        return FutureBuilder(
            future: _getDiagramStats(widget.selectedTimeFrame),
            builder: (final BuildContext context, final AsyncSnapshot<List<double>?> snapshot) {
              return Container(
                decoration: BoxDecoration(
                  color: appTheme(context, userSettingsState.userSettings.themeMode).cardBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        _getDiagramHeader(widget.selectedTimeFrame),
                        style: TextStyle(
                            color: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[GameModeEnum.findTheGrandmasterMoves]!.accentColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 18),
                      ),
                    ),
                    _getDiagram(widget.selectedTimeFrame, snapshot),
                  ],
                ),
              );
            });
      });

  Widget _getDiagram(final String selectedTimeFrame, final AsyncSnapshot<List<double>?> snapshot) {
    if (snapshot.connectionState != ConnectionState.done) {
      return Container(
        margin: const EdgeInsets.only(top: 30),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 60, bottom: 60),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    final values = snapshot.data!;

    switch (selectedTimeFrame) {
      case 'Insgesamt':
        return TotalStats(totalGames: values);
      case 'Heute':
        return DailyStats(dailyGames: values);
      case 'Woche':
        return WeeklyStats(weeklyGames: values);
      case 'Monat':
        return MonthlyStats(monthlyGames: values);
      case 'Jahr':
        return YearlyStats(yearlyGames: values);
      default:
        throw InvalidConfigException();
    }
  }

  Future<List<double>> _getPlayedGamesPerWeekday() async {
    final List<double> weekdays = [];
    final DateTime today = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      DateTime start = today.subtract(Duration(days: i));
      await FindTheGrandmasterMovesGamesPlayedDao().getByPlayedDay(start).then((data) => weekdays.add(data.length.toDouble()));
      await TimeBattleGamesPlayedDao().getByPlayedDay(start).then((data) => weekdays.add(data.length.toDouble()));
      await SurvivalGamesPlayedDao().getByPlayedDay(start).then((data) => weekdays.add(data.length.toDouble()));
      await PuzzleGamesPlayedDao().getByPlayedDay(start).then((data) => weekdays.add(data.length.toDouble()));
    }
    return weekdays;
  }

  Future<List<double>> _getPlayedGamesPerMonth() async {
    final List<double> months = [];
    for (int i = 11; i >= 0; i--) {
      DateTime end = _getEndOfMonth(i);
      DateTime start = DateTime(end.year, end.month, 1, 0, 0, 0, 0, 0);
      await FindTheGrandmasterMovesGamesPlayedDao().getByPlayedDateInRange(start, end).then((data) => months.add(data.length.toDouble()));
      await TimeBattleGamesPlayedDao().getByPlayedDateInRange(start, end).then((data) => months.add(data.length.toDouble()));
      await SurvivalGamesPlayedDao().getByPlayedDateInRange(start, end).then((data) => months.add(data.length.toDouble()));
      await PuzzleGamesPlayedDao().getByPlayedDateInRange(start, end).then((data) => months.add(data.length.toDouble()));
    }
    return months;
  }

  DateTime _getEndOfMonth(final int monthsAgo) {
    final DateTime today = DateTime.now();
    int day;
    int month = ((today.month - monthsAgo - 1) % 12) + 1;
    int yearOffset = month < monthsAgo ? -1 : 0;
    if (month == 2) {
      day = (today.year + yearOffset) % 4 == 0 && (today.year + yearOffset) % 100 != 0 || (today.year + yearOffset) % 400 == 0 ? 29 : 28;
    } else if ([4, 6, 9, 11].contains(month)) {
      day = 30;
    } else {
      day = 31;
    }
    DateTime end = DateTime(today.year + yearOffset, month, day, 23, 59, 59, 999, 999);
    return end;
  }

  Future<List<double>> _getPlayedGamesPerDayInMonth() async {
    final List<double> days = [];
    final DateTime today = DateTime.now();
    for (int i = 29; i >= 0; i--) {
      DateTime start = today.subtract(Duration(days: i));
      await FindTheGrandmasterMovesGamesPlayedDao().getByPlayedDay(start).then((data) => days.add(data.length.toDouble()));
      await TimeBattleGamesPlayedDao().getByPlayedDay(start).then((data) => days.add(data.length.toDouble()));
      await SurvivalGamesPlayedDao().getByPlayedDay(start).then((data) => days.add(data.length.toDouble()));
      await PuzzleGamesPlayedDao().getByPlayedDay(start).then((data) => days.add(data.length.toDouble()));
    }
    return days;
  }

  Future<List<double>> _getPlayedGamesPerHour() async {
    final List<double> days = [];
    final DateTime today = DateTime.now();
    for (int i = 0; i <= today.hour; i++) {
      DateTime start = DateTime(today.year, today.month, today.day, i, 0, 0, 0, 0);
      DateTime end = DateTime(today.year, today.month, today.day, i, 59, 59, 999, 999);
      await FindTheGrandmasterMovesGamesPlayedDao().getByPlayedDateInRange(start, end).then((data) => days.add(data.length.toDouble()));
      await TimeBattleGamesPlayedDao().getByPlayedDateInRange(start, end).then((data) => days.add(data.length.toDouble()));
      await SurvivalGamesPlayedDao().getByPlayedDateInRange(start, end).then((data) => days.add(data.length.toDouble()));
      await PuzzleGamesPlayedDao().getByPlayedDateInRange(start, end).then((data) => days.add(data.length.toDouble()));
    }
    return days;
  }

  Future<List<double>> _getPlayedGamesTotal() async {
    final List<double> modes = [];
    await FindTheGrandmasterMovesGamesPlayedDao().getAll().then((data) => modes.add(data!.length.toDouble()));
    await TimeBattleGamesPlayedDao().getAll().then((data) => modes.add(data!.length.toDouble()));
    await SurvivalGamesPlayedDao().getAll().then((data) => modes.add(data!.length.toDouble()));
    await PuzzleGamesPlayedDao().getAll().then((data) => modes.add(data!.length.toDouble()));
    return modes;
  }

  String _getDiagramHeader(final String currentTimeFrame) {
    switch (currentTimeFrame) {
      case 'Insgesamt':
        return 'Spiele insgesamt';
      case 'Heute':
        return 'Heutige Spiele ';
      case 'Woche':
        return 'Spiele diese Woche';
      case 'Monat':
        return 'Spiele diesen Monat';
      case 'Jahr':
        return 'Spiele dieses Jahr';
      default:
        throw InvalidConfigException();
    }
  }

  Future<List<double>> _getDiagramStats(final String currentTimeFrame) async {
    switch (currentTimeFrame) {
      case 'Insgesamt':
        return _getPlayedGamesTotal();
      case 'Heute':
        return _getPlayedGamesPerHour();
      case 'Woche':
        return _getPlayedGamesPerWeekday();
      case 'Monat':
        return _getPlayedGamesPerDayInMonth();
      case 'Jahr':
        return _getPlayedGamesPerMonth();
      default:
        return [];
    }
  }
}
