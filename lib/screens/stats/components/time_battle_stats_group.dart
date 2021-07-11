import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/components/text_with_accent_field.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/model/time_battle_game_played.dart';
import 'package:guess_the_move/repository/dao/time_battle_games_played_dao.dart';
import 'package:guess_the_move/screens/stats/components/stats_group.dart';

class TimeBattleStatsGroup extends StatefulWidget {
  final String selectedTimeFrame;

  const TimeBattleStatsGroup({Key? key, required this.selectedTimeFrame}) : super(key: key);
  @override
  _TimeBattleStatsGroupState createState() => _TimeBattleStatsGroupState();
}

class _TimeBattleStatsGroupState extends State<TimeBattleStatsGroup> {
  @override
  Widget build(BuildContext context) => BlocBuilder<UserSettingsBloc, UserSettingsState>(builder: (context, userSettingsState) {
        return FutureBuilder(
            future: getPlayedGamesInTimeFrame(widget.selectedTimeFrame),
            builder: (final BuildContext context, final AsyncSnapshot<List<TimeBattleGamePlayed>?> snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              final playedGames = snapshot.data!;

              final gamesPlayedAmount = playedGames.length;
              final amountGuessedMoves = _timeBattleGetAmountGuessedMoves(playedGames);
              final amountGuessedCorrectMoves = _timeBattleGetAmountGuessedCorrectMoves(playedGames);
              final percentGuessedMovesCorrect = amountGuessedMoves == 0 ? 0 : ((10000 * (amountGuessedCorrectMoves / amountGuessedMoves)).round()) / 100;
              return StatsGroup(title: 'Zeitdruck', gameMode: GameModeEnum.timeBattle, stats: [
                TextWithAccentField(
                  gameMode: GameModeEnum.timeBattle,
                  text: 'Gespielte Spiele',
                  userSettingsState: userSettingsState,
                  accentBoxText: '$gamesPlayedAmount',
                ),
                TextWithAccentField(gameMode: GameModeEnum.timeBattle, text: 'Züge gesamt', userSettingsState: userSettingsState, accentBoxText: '$amountGuessedMoves'),
                TextWithAccentField(
                    gameMode: GameModeEnum.timeBattle, text: 'Züge richtig geraten', userSettingsState: userSettingsState, accentBoxText: '$amountGuessedCorrectMoves'),
                TextWithAccentField(
                    gameMode: GameModeEnum.timeBattle,
                    text: 'Züge falsch geraten',
                    userSettingsState: userSettingsState,
                    accentBoxText: '${amountGuessedMoves - amountGuessedCorrectMoves}'),
                TextWithAccentField(
                    gameMode: GameModeEnum.timeBattle, text: 'Prozentual richtig', userSettingsState: userSettingsState, accentBoxText: '$percentGuessedMovesCorrect%'),
                TextWithAccentField(
                    gameMode: GameModeEnum.timeBattle,
                    text: 'Prozentual falsch',
                    userSettingsState: userSettingsState,
                    accentBoxText: '${(100 * (100 - percentGuessedMovesCorrect)).round() / 100}%'),
              ]);
            });
      });

  Future<List<TimeBattleGamePlayed>?> getPlayedGamesInTimeFrame(final String currentTimeFrame) async {
    DateTime today = DateTime.now();
    switch (currentTimeFrame) {
      case 'Insgesamt':
        return await TimeBattleGamesPlayedDao().getAll();
      case 'Heute':
        return await TimeBattleGamesPlayedDao().getByPlayedDay(today);
      case 'Woche':
        return await TimeBattleGamesPlayedDao().getByPlayedDateInRange(today.subtract(Duration(days: 6)), today);
      case 'Monat':
        return await TimeBattleGamesPlayedDao().getByPlayedDateInRange(today.subtract(Duration(days: 29)), today);
      case 'Jahr':
        return await TimeBattleGamesPlayedDao().getByPlayedDateInRange(today.subtract(Duration(days: 364)), today);
      default:
        return [];
    }
  }

  int _timeBattleGetAmountGuessedMoves(final List<TimeBattleGamePlayed> games) {
    int amountGuessed = 0;
    games.forEach((element) {
      amountGuessed += element.totalMovesPlayedAmount;
    });
    return amountGuessed;
  }

  int _timeBattleGetAmountGuessedCorrectMoves(final List<TimeBattleGamePlayed> games) {
    int amountGuessedCorrect = 0;
    games.forEach((element) {
      amountGuessedCorrect += element.correctMovesPlayedAmount;
    });
    return amountGuessedCorrect;
  }
}
