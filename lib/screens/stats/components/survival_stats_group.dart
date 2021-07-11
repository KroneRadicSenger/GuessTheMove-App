import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/components/text_with_accent_field.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/model/survival_game_played.dart';
import 'package:guess_the_move/repository/dao/survival_games_played_dao.dart';
import 'package:guess_the_move/screens/stats/components/stats_group.dart';

class SurvivalStatsGroup extends StatefulWidget {
  final String selectedTimeFrame;

  const SurvivalStatsGroup({Key? key, required this.selectedTimeFrame}) : super(key: key);
  @override
  _SurvivalStatsGroupState createState() => _SurvivalStatsGroupState();
}

class _SurvivalStatsGroupState extends State<SurvivalStatsGroup> {
  @override
  Widget build(BuildContext context) => BlocBuilder<UserSettingsBloc, UserSettingsState>(builder: (context, userSettingsState) {
        return FutureBuilder(
            future: getPlayedGamesInTimeFrame(widget.selectedTimeFrame),
            builder: (final BuildContext context, final AsyncSnapshot<List<SurvivalGamePlayed>?> snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              final playedGames = snapshot.data!;

              final gamesPlayedAmount = playedGames.length;
              final amountGuessedMoves = _survivalGetAmountGuessedMoves(playedGames);
              final amountGuessedCorrectMoves = _survivalGetAmountGuessedCorrectMoves(playedGames);
              final percentGuessedMovesCorrect = amountGuessedMoves == 0 ? 0 : ((10000 * (amountGuessedCorrectMoves / amountGuessedMoves)).round()) / 100;
              return StatsGroup(title: 'Überleben', gameMode: GameModeEnum.survivalMode, stats: [
                TextWithAccentField(
                  gameMode: GameModeEnum.survivalMode,
                  text: 'Gespielte Spiele',
                  accentBoxText: '$gamesPlayedAmount',
                  userSettingsState: userSettingsState,
                ),
                TextWithAccentField(gameMode: GameModeEnum.survivalMode, text: 'Züge gesamt', userSettingsState: userSettingsState, accentBoxText: '$amountGuessedMoves'),
                TextWithAccentField(
                    gameMode: GameModeEnum.survivalMode, text: 'Züge richtig geraten', userSettingsState: userSettingsState, accentBoxText: '$amountGuessedCorrectMoves'),
                TextWithAccentField(
                    gameMode: GameModeEnum.survivalMode,
                    text: 'Züge falsch geraten',
                    userSettingsState: userSettingsState,
                    accentBoxText: '${amountGuessedMoves - amountGuessedCorrectMoves}'),
                TextWithAccentField(
                    gameMode: GameModeEnum.survivalMode, text: 'Prozentual richtig', userSettingsState: userSettingsState, accentBoxText: '$percentGuessedMovesCorrect%'),
                TextWithAccentField(
                    gameMode: GameModeEnum.survivalMode,
                    text: 'Prozentual falsch',
                    userSettingsState: userSettingsState,
                    accentBoxText: '${(100 * (100 - percentGuessedMovesCorrect)).round() / 100}%'),
              ]);
            });
      });

  Future<List<SurvivalGamePlayed>?> getPlayedGamesInTimeFrame(final String currentTimeFrame) async {
    DateTime today = DateTime.now();
    switch (currentTimeFrame) {
      case 'Insgesamt':
        return await SurvivalGamesPlayedDao().getAll();
      case 'Heute':
        return await SurvivalGamesPlayedDao().getByPlayedDay(today);
      case 'Woche':
        return await SurvivalGamesPlayedDao().getByPlayedDateInRange(today.subtract(Duration(days: 6)), today);
      case 'Monat':
        return await SurvivalGamesPlayedDao().getByPlayedDateInRange(today.subtract(Duration(days: 29)), today);
      case 'Jahr':
        return await SurvivalGamesPlayedDao().getByPlayedDateInRange(today.subtract(Duration(days: 364)), today);
      default:
        return [];
    }
  }

  int _survivalGetAmountGuessedMoves(final List<SurvivalGamePlayed> games) {
    int amountGuessed = 0;
    games.forEach((element) {
      amountGuessed += element.totalMovesPlayedAmount;
    });
    return amountGuessed;
  }

  int _survivalGetAmountGuessedCorrectMoves(final List<SurvivalGamePlayed> games) {
    int amountGuessedCorrect = 0;
    games.forEach((element) {
      amountGuessedCorrect += element.correctMovesPlayedAmount;
    });
    return amountGuessedCorrect;
  }
}
