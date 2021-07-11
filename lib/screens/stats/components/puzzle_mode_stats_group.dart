import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/components/text_with_accent_field.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/model/puzzle_game_played.dart';
import 'package:guess_the_move/repository/dao/puzzle_games_played_dao.dart';
import 'package:guess_the_move/screens/stats/components/stats_group.dart';

class PuzzleModeStatsGroup extends StatefulWidget {
  final String selectedTimeFrame;

  const PuzzleModeStatsGroup({Key? key, required this.selectedTimeFrame}) : super(key: key);
  @override
  _PuzzleModeStatsGroupState createState() => _PuzzleModeStatsGroupState();
}

class _PuzzleModeStatsGroupState extends State<PuzzleModeStatsGroup> {
  @override
  Widget build(BuildContext context) => BlocBuilder<UserSettingsBloc, UserSettingsState>(builder: (context, userSettingsState) {
        return FutureBuilder(
            future: getPlayedGamesInTimeFrame(widget.selectedTimeFrame),
            builder: (final BuildContext context, final AsyncSnapshot<List<PuzzleGamePlayed>?> snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              final playedGames = snapshot.data!;

              final gamesPlayedAmount = playedGames.length;
              final amountPlayedPuzzles = _puzzleGetAmountPlayedPuzzles(playedGames);
              final totalMoves = _puzzleGetTotalMoves(playedGames);
              final amountGuessedWrongMoves = _puzzleGetAmountGuessedWrongMoves(playedGames);
              final percentGuessedMovesWrong = totalMoves == 0 ? 100 : ((10000 * (amountGuessedWrongMoves / totalMoves)).round()) / 100;
              return StatsGroup(title: 'Puzzle', gameMode: GameModeEnum.puzzleMode, stats: [
                TextWithAccentField(
                  gameMode: GameModeEnum.puzzleMode,
                  text: 'Gespielte Spiele',
                  accentBoxText: '$gamesPlayedAmount',
                  userSettingsState: userSettingsState,
                ),
                TextWithAccentField(gameMode: GameModeEnum.puzzleMode, text: 'Puzzle Gesamt', userSettingsState: userSettingsState, accentBoxText: '$amountPlayedPuzzles'),
                TextWithAccentField(gameMode: GameModeEnum.puzzleMode, text: 'Fehlversuche', userSettingsState: userSettingsState, accentBoxText: '$amountGuessedWrongMoves'),
                TextWithAccentField(
                    gameMode: GameModeEnum.puzzleMode,
                    text: 'Prozentual richtig',
                    userSettingsState: userSettingsState,
                    accentBoxText: '${(100 * (100 - percentGuessedMovesWrong)).round() / 100}%'),
                TextWithAccentField(
                    gameMode: GameModeEnum.puzzleMode, text: 'Prozentual falsch', userSettingsState: userSettingsState, accentBoxText: '$percentGuessedMovesWrong%'),
              ]);
            });
      });

  Future<List<PuzzleGamePlayed>?> getPlayedGamesInTimeFrame(final String currentTimeFrame) async {
    DateTime today = DateTime.now();
    switch (currentTimeFrame) {
      case 'Insgesamt':
        return await PuzzleGamesPlayedDao().getAll();
      case 'Heute':
        return await PuzzleGamesPlayedDao().getByPlayedDay(today);
      case 'Woche':
        return await PuzzleGamesPlayedDao().getByPlayedDateInRange(today.subtract(Duration(days: 6)), today);
      case 'Monat':
        return await PuzzleGamesPlayedDao().getByPlayedDateInRange(today.subtract(Duration(days: 29)), today);
      case 'Jahr':
        return await PuzzleGamesPlayedDao().getByPlayedDateInRange(today.subtract(Duration(days: 364)), today);
      default:
        return [];
    }
  }

  int _puzzleGetAmountPlayedPuzzles(final List<PuzzleGamePlayed> games) {
    int amountPlayedPuzzles = 0;
    games.forEach((element) {
      amountPlayedPuzzles += element.puzzlesPlayed.length;
    });
    return amountPlayedPuzzles;
  }

  int _puzzleGetAmountGuessedWrongMoves(final List<PuzzleGamePlayed> games) {
    int amountGuessedWrong = 0;
    games.forEach((element) {
      element.puzzlesPlayed.forEach((element) {
        amountGuessedWrong += element.wrongTries;
      });
    });
    return amountGuessedWrong;
  }

  int _puzzleGetTotalMoves(final List<PuzzleGamePlayed> games) {
    int totalMoves = 0;
    games.forEach((element) {
      element.puzzlesPlayed.forEach((element) {
        totalMoves += element.wrongTries;
        if (element.wasCorrectMovePlayed()) {
          totalMoves++;
        }
      });
    });
    return totalMoves;
  }
}
