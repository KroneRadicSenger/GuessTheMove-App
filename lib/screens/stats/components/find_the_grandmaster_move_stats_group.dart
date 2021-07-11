import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/components/text_with_accent_field.dart';
import 'package:guess_the_move/model/analyzed_game.dart';
import 'package:guess_the_move/model/find_the_grandmaster_moves_game_played.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/repository/dao/find_the_grandmaster_moves_games_played_dao.dart';
import 'package:guess_the_move/screens/stats/components/stats_group.dart';

class FindTheGrandmasterMoveStatsGroup extends StatefulWidget {
  final String selectedTimeFrame;

  const FindTheGrandmasterMoveStatsGroup({Key? key, required this.selectedTimeFrame}) : super(key: key);
  @override
  _FindTheGrandmasterMoveStatsGroup createState() => _FindTheGrandmasterMoveStatsGroup();
}

class _FindTheGrandmasterMoveStatsGroup extends State<FindTheGrandmasterMoveStatsGroup> {
  @override
  Widget build(BuildContext context) => BlocBuilder<UserSettingsBloc, UserSettingsState>(builder: (context, userSettingsState) {
        return FutureBuilder(
            future: getPlayedGamesInTimeFrame(widget.selectedTimeFrame),
            builder: (final BuildContext context, final AsyncSnapshot<List<FindTheGrandmasterMovesGamePlayed>?> snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              final playedGames = snapshot.data!;

              final gamesPlayedAmount = playedGames.length;
              final amountGuessedMoves = _findTheGrandmasterMovesGetAmountGuessedMoves(playedGames);
              final amountGuessedCorrectMoves = _findTheGrandmasterMovesGetAmountGuessedCorrectMoves(playedGames);
              final percentGuessedMovesCorrect = amountGuessedMoves == 0 ? 0 : ((10000 * (amountGuessedCorrectMoves / amountGuessedMoves)).round()) / 100;

              return StatsGroup(title: 'Finde den Großmeisterzug', gameMode: GameModeEnum.findTheGrandmasterMoves, stats: [
                TextWithAccentField(
                  gameMode: GameModeEnum.findTheGrandmasterMoves,
                  text: 'Gespielte Spiele',
                  accentBoxText: '$gamesPlayedAmount',
                  userSettingsState: userSettingsState,
                ),
                TextWithAccentField(
                  gameMode: GameModeEnum.findTheGrandmasterMoves,
                  text: 'Züge gesamt',
                  userSettingsState: userSettingsState,
                  accentBoxText: '$amountGuessedMoves',
                ),
                TextWithAccentField(
                    gameMode: GameModeEnum.findTheGrandmasterMoves,
                    text: 'Züge richtig geraten',
                    userSettingsState: userSettingsState,
                    accentBoxText: '$amountGuessedCorrectMoves'),
                TextWithAccentField(
                    gameMode: GameModeEnum.findTheGrandmasterMoves,
                    text: 'Züge falsch geraten',
                    userSettingsState: userSettingsState,
                    accentBoxText: '${amountGuessedMoves - amountGuessedCorrectMoves}'),
                TextWithAccentField(
                    gameMode: GameModeEnum.findTheGrandmasterMoves,
                    text: 'Prozentual richtig',
                    userSettingsState: userSettingsState,
                    accentBoxText: '$percentGuessedMovesCorrect%'),
                TextWithAccentField(
                    gameMode: GameModeEnum.findTheGrandmasterMoves,
                    text: 'Prozentual falsch',
                    userSettingsState: userSettingsState,
                    accentBoxText: '${(100 * (100 - percentGuessedMovesCorrect)).round() / 100}%'),
              ]);
            });
      });

  Future<List<FindTheGrandmasterMovesGamePlayed>?> getPlayedGamesInTimeFrame(final String currentTimeFrame) async {
    DateTime today = DateTime.now();
    switch (currentTimeFrame) {
      case 'Insgesamt':
        return await FindTheGrandmasterMovesGamesPlayedDao().getAll();
      case 'Heute':
        return await FindTheGrandmasterMovesGamesPlayedDao().getByPlayedDay(today);
      case 'Woche':
        return await FindTheGrandmasterMovesGamesPlayedDao().getByPlayedDateInRange(today.subtract(Duration(days: 6)), today);
      case 'Monat':
        return await FindTheGrandmasterMovesGamesPlayedDao().getByPlayedDateInRange(today.subtract(Duration(days: 29)), today);
      case 'Jahr':
        return await FindTheGrandmasterMovesGamesPlayedDao().getByPlayedDateInRange(today.subtract(Duration(days: 364)), today);
      default:
        return [];
    }
  }

  int _findTheGrandmasterMovesGetAmountGuessedMoves(final List<FindTheGrandmasterMovesGamePlayed> games) {
    int amountGuessed = 0;
    games.forEach((element) {
      amountGuessed += element.gameEvaluationData.getTotalMovesGuessedAmount();
    });
    return amountGuessed;
  }

  int _findTheGrandmasterMovesGetAmountGuessedCorrectMoves(final List<FindTheGrandmasterMovesGamePlayed> games) {
    int amountGuessedCorrect = 0;
    games.forEach((element) {
      element.gameEvaluationData.guessEvaluatedList.forEach((element) {
        if (element.chosenMoveType == AnalyzedMoveType.best || element.grandmasterMovePlayed) {
          amountGuessedCorrect++;
        }
      });
    });
    return amountGuessedCorrect;
  }
}
