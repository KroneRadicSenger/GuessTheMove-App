import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/components/horizontal_list.dart';
import 'package:guess_the_move/components/titled_container.dart';
import 'package:guess_the_move/components/utils/show_draggable_modal_bottom_sheet.dart';
import 'package:guess_the_move/model/analyzed_game.dart';
import 'package:guess_the_move/model/find_the_grandmaster_moves_game_played.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/model/puzzle_game_played.dart';
import 'package:guess_the_move/model/survival_game_played.dart';
import 'package:guess_the_move/model/time_battle_game_played.dart';
import 'package:guess_the_move/repository/dao/find_the_grandmaster_moves_games_played_dao.dart';
import 'package:guess_the_move/repository/dao/puzzle_games_played_dao.dart';
import 'package:guess_the_move/repository/dao/survival_games_played_dao.dart';
import 'package:guess_the_move/repository/dao/time_battle_games_played_dao.dart';
import 'package:guess_the_move/screens/game_modes/components/summary/summary_bottom_area.dart';
import 'package:guess_the_move/screens/game_modes/puzzle/components/puzzle_game_over_contents.dart';
import 'package:guess_the_move/screens/game_modes/survival/components/survival_game_over_contents.dart';
import 'package:guess_the_move/screens/game_modes/time_battle/components/time_battle_game_over_contents.dart';
import 'package:guess_the_move/screens/home/components/last_played.dart';
import 'package:guess_the_move/theme/theme.dart';

class LastPlayedList extends StatelessWidget {
  LastPlayedList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserSettingsBloc, UserSettingsState>(builder: (context, state) {
      return TitledContainer(
        title: 'Zuletzt gespielt',
        child: HorizontalList(
          elements: [
            FutureBuilder<FindTheGrandmasterMovesGamePlayed?>(
              future: FindTheGrandmasterMovesGamesPlayedDao().getNewest(),
              builder: (final BuildContext context, final AsyncSnapshot<FindTheGrandmasterMovesGamePlayed?> snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return LastPlayed(
                    gameModeEnum: GameModeEnum.findTheGrandmasterMoves,
                    iconName: 'throne-king',
                    title: CircularProgressIndicator(),
                    gameInfo: '',
                    onTap: () {},
                  );
                }
                if (!snapshot.hasData) {
                  return LastPlayed(
                    gameModeEnum: GameModeEnum.findTheGrandmasterMoves,
                    iconName: 'throne-king',
                    title: _buildTextTitle(context, state, 'Noch nicht gespielt'),
                    gameInfo: '',
                    onTap: () {},
                  );
                }
                return LastPlayed(
                  gameModeEnum: GameModeEnum.findTheGrandmasterMoves,
                  iconName: 'throne-king',
                  title: _buildTextTitle(context, state, snapshot.data!.info.whitePlayer.getLastName() + ' vs ' + snapshot.data!.info.blackPlayer.getLastName()),
                  gameInfo: 'Gespielt am\n' + germanDateTimeFormatShort.format(DateTime.fromMillisecondsSinceEpoch(snapshot.data!.playedDateTimestamp)),
                  onTap: () => _onShowLastGamePlayedSummaryFindGrandmasterMove(state, snapshot.data!, context),
                );
              },
            ),
            FutureBuilder<TimeBattleGamePlayed?>(
              future: TimeBattleGamesPlayedDao().getNewest(),
              builder: (final BuildContext context, final AsyncSnapshot<TimeBattleGamePlayed?> snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return LastPlayed(
                    gameModeEnum: GameModeEnum.timeBattle,
                    iconName: 'time-trap',
                    title: CircularProgressIndicator(),
                    gameInfo: '',
                    onTap: () {},
                  );
                }
                if (!snapshot.hasData) {
                  return LastPlayed(
                    gameModeEnum: GameModeEnum.timeBattle,
                    iconName: 'time-trap',
                    title: _buildTextTitle(context, state, 'Noch nicht gespielt'),
                    gameInfo: '',
                    onTap: () {},
                  );
                }
                return LastPlayed(
                  gameModeEnum: GameModeEnum.timeBattle,
                  iconName: 'time-trap',
                  title: _buildTextTitle(context, state, snapshot.data!.grandmaster.getFirstAndLastName()),
                  gameInfo: snapshot.data!.initialTimeInSeconds.toString() + ' Sekunden\nPaket ' + snapshot.data!.analyzedGameOriginBundle.getDisplayName(),
                  onTap: () => _onShowLastGamePlayedSummaryTimeBattle(context, state, snapshot.data!),
                );
              },
            ),
            FutureBuilder<SurvivalGamePlayed?>(
              future: SurvivalGamesPlayedDao().getNewest(),
              builder: (final BuildContext context, final AsyncSnapshot<SurvivalGamePlayed?> snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return LastPlayed(
                    gameModeEnum: GameModeEnum.survivalMode,
                    iconName: 'half-dead',
                    title: CircularProgressIndicator(),
                    gameInfo: '',
                    onTap: () {},
                  );
                }
                if (!snapshot.hasData) {
                  return LastPlayed(
                    gameModeEnum: GameModeEnum.survivalMode,
                    iconName: 'half-dead',
                    title: _buildTextTitle(context, state, 'Noch nicht gespielt'),
                    gameInfo: '',
                    onTap: () {},
                  );
                }
                return LastPlayed(
                  gameModeEnum: GameModeEnum.survivalMode,
                  iconName: 'half-dead',
                  title: _buildTextTitle(context, state, snapshot.data!.grandmaster.getFirstAndLastName()),
                  gameInfo: snapshot.data!.amountLives.toString() + ' Leben\nPaket ' + snapshot.data!.analyzedGameOriginBundle.getDisplayName(),
                  onTap: () => _onShowLastGamePlayedSummarySurvival(
                    context,
                    state,
                    snapshot.data!,
                  ),
                );
              },
            ),
            FutureBuilder<PuzzleGamePlayed?>(
              future: PuzzleGamesPlayedDao().getNewest(),
              builder: (final BuildContext context, final AsyncSnapshot<PuzzleGamePlayed?> snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return LastPlayed(
                    gameModeEnum: GameModeEnum.puzzleMode,
                    iconName: 'jigsaw-piece',
                    title: CircularProgressIndicator(),
                    gameInfo: '',
                    onTap: () {},
                  );
                }
                if (!snapshot.hasData) {
                  return LastPlayed(
                    gameModeEnum: GameModeEnum.puzzleMode,
                    iconName: 'jigsaw-piece',
                    title: _buildTextTitle(context, state, 'Noch nicht gespielt'),
                    gameInfo: '',
                    onTap: () {},
                  );
                }
                return LastPlayed(
                  gameModeEnum: GameModeEnum.puzzleMode,
                  iconName: 'jigsaw-piece',
                  title: _buildTextTitle(context, state, snapshot.data!.grandmaster.getFirstAndLastName()),
                  gameInfo: 'Paket ' + snapshot.data!.analyzedGameOriginBundle.getDisplayName(),
                  onTap: () => _onShowLastGamePlayedSummaryPuzzle(
                    context,
                    state,
                    snapshot.data!,
                  ),
                );
              },
            ),
          ],
          height: 160,
        ),
      );
    });
  }

  Widget _buildTextTitle(final BuildContext context, final UserSettingsState state, final String text) {
    return Text(
      text,
      style: TextStyle(
        color: appTheme(context, state.userSettings.themeMode).textColor,
        fontWeight: FontWeight.w300,
      ),
      textAlign: TextAlign.center,
      textScaleFactor: 0.9,
    );
  }

  void _onShowLastGamePlayedSummaryFindGrandmasterMove(final UserSettingsState state, final FindTheGrandmasterMovesGamePlayed gamePlayed, BuildContext context) {
    showDraggableModalBottomSheet(
      context,
      state,
      null,
      GameSummaryBottomArea(
        gamePlayed.analyzedGameId,
        gamePlayed.analyzedGameOriginBundle,
        gamePlayed.info.gameInfoString,
        gamePlayed.gameEvaluationData,
        gamePlayed.info.whitePlayer,
        gamePlayed.info.blackPlayer,
        GameModeEnum.findTheGrandmasterMoves,
        state,
        gamePlayed.playedDateTimestamp,
        padding: const EdgeInsets.symmetric(horizontal: 20),
      ),
    );
  }

  void _onShowLastGamePlayedSummaryTimeBattle(final BuildContext context, final UserSettingsState userSettingsState, final TimeBattleGamePlayed gamePlayed) {
    showDraggableModalBottomSheet(
      context,
      userSettingsState,
      null,
      TimeBattleGameOverContents(
        titleText: 'Letztes Spiel',
        padding: const EdgeInsets.only(bottom: 10),
        analyzedGamesOriginBundle: gamePlayed.analyzedGameOriginBundle,
        gamesPlayedInfo: gamePlayed.gamesPlayedInfo,
        gamesSummaryData: gamePlayed.analyzedGamesPlayedSummaryData,
        playedDateTimestamp: gamePlayed.playedDateTimestamp,
        userSettingsState: userSettingsState,
        initialTimeInSeconds: gamePlayed.initialTimeInSeconds,
        totalMovesGuessed: gamePlayed.totalMovesPlayedAmount,
        movesGuessedCorrect: gamePlayed.correctMovesPlayedAmount,
      ),
    );
  }

  void _onShowLastGamePlayedSummarySurvival(final BuildContext context, final UserSettingsState userSettingsState, final SurvivalGamePlayed gamePlayed) {
    showDraggableModalBottomSheet(
      context,
      userSettingsState,
      null,
      SurvivalGameOverContents(
        titleText: 'Letztes Spiel',
        padding: const EdgeInsets.only(bottom: 10),
        analyzedGamesOriginBundle: gamePlayed.analyzedGameOriginBundle,
        gamesPlayedInfo: gamePlayed.gamesPlayedInfo,
        gamesSummaryData: gamePlayed.analyzedGamesPlayedSummaryData,
        playedDateTimestamp: gamePlayed.playedDateTimestamp,
        userSettingsState: userSettingsState,
        amountLives: gamePlayed.amountLives,
        totalMovesGuessed: gamePlayed.totalMovesPlayedAmount,
        movesGuessedCorrect: gamePlayed.correctMovesPlayedAmount,
      ),
    );
  }

  void _onShowLastGamePlayedSummaryPuzzle(final BuildContext context, final UserSettingsState userSettingsState, final PuzzleGamePlayed gamePlayed) {
    showDraggableModalBottomSheet(
      context,
      userSettingsState,
      null,
      PuzzleGameOverContents(
        titleText: 'Letztes Spiel',
        padding: const EdgeInsets.only(bottom: 10),
        analyzedGamesOriginBundle: gamePlayed.analyzedGameOriginBundle,
        puzzlesPlayed: gamePlayed.puzzlesPlayed,
        playedDateTimestamp: gamePlayed.playedDateTimestamp,
        userSettingsState: userSettingsState,
      ),
    );
  }
}
