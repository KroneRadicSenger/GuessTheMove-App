import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/components/game_subtitle_text.dart';
import 'package:guess_the_move/components/game_title_text.dart';
import 'package:guess_the_move/components/utils/show_draggable_modal_bottom_sheet.dart';
import 'package:guess_the_move/components/utils/show_loading_dialog.dart';
import 'package:guess_the_move/model/analyzed_game.dart';
import 'package:guess_the_move/model/find_the_grandmaster_moves_game_played.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/model/player.dart';
import 'package:guess_the_move/repository/analyzed_games_repository.dart';
import 'package:guess_the_move/repository/dao/find_the_grandmaster_moves_games_played_dao.dart';
import 'package:guess_the_move/screens/game_modes/components/summary/summary_bottom_area.dart';
import 'package:guess_the_move/screens/game_modes/find_the_grandmaster_moves/find_the_grandmaster_moves_screen.dart';
import 'package:guess_the_move/theme/theme.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class LastPlayedGrandmasterGamesModalContents extends StatefulWidget {
  final Player grandmaster;
  final GameModeEnum gameMode;

  const LastPlayedGrandmasterGamesModalContents({Key? key, required this.grandmaster, required this.gameMode}) : super(key: key);

  @override
  _LastPlayedGrandmasterGamesModalContentsState createState() => _LastPlayedGrandmasterGamesModalContentsState();
}

class _LastPlayedGrandmasterGamesModalContentsState extends State<LastPlayedGrandmasterGamesModalContents> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserSettingsBloc, UserSettingsState>(
      builder: (context, state) {
        return FutureBuilder<List<FindTheGrandmasterMovesGamePlayed>>(
          future: FindTheGrandmasterMovesGamesPlayedDao().getByGrandmaster(widget.grandmaster),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text('Es ist ein Fehler beim Laden der zuletzt gespielten Spiele aufgetreten.')),
              );
            }
            if (!snapshot.hasData) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return _buildLastPlayedGames(state, snapshot.data!);
          },
        );
      },
    );
  }

  Widget _buildLastPlayedGames(final UserSettingsState state, final List<FindTheGrandmasterMovesGamePlayed> gamesPlayed) {
    if (gamesPlayed.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        child: Text(
          'Du hast noch kein Spiel von diesem Großmeister gespielt',
          style: TextStyle(
            color: appTheme(context, state.userSettings.themeMode).textColor,
          ),
        ),
      );
    }

    return Column(
      children: [
        ...gamesPlayed.map((gamePlayed) => _buildLastPlayedGame(state, gamePlayed)),
      ],
    );
  }

  Widget _buildLastPlayedGame(final UserSettingsState state, final FindTheGrandmasterMovesGamePlayed gamePlayed) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => _onTapLastGamePlayed(state, gamePlayed),
              style: TextButton.styleFrom(
                backgroundColor: appTheme(context, state.userSettings.themeMode).cardBackgroundColor,
                primary: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 8,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GameTitleText(state, widget.gameMode, '${gamePlayed.info.whitePlayer.getFirstAndLastName()} vs ${gamePlayed.info.blackPlayer.getFirstAndLastName()}'),
                          GameSubtitleText(state, gamePlayed.info.gameInfoString),
                          GameSubtitleText(state, 'Gespielt am ${germanDateTimeFormatShort.format(DateTime.fromMillisecondsSinceEpoch(gamePlayed.playedDateTimestamp))}'),
                          if (gamePlayed.info.whitePlayerRating != '-') GameSubtitleText(state, 'ELO Weiß: ${gamePlayed.info.whitePlayerRating}'),
                          if (gamePlayed.info.blackPlayerRating != '-') GameSubtitleText(state, 'ELO Schwarz: ${gamePlayed.info.blackPlayerRating}'),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.info_outline_rounded,
                      color: appTheme(context, state.userSettings.themeMode).textColor,
                      size: 30,
                    ),
                    onPressed: () => _onShowLastGamePlayedSummary(state, gamePlayed),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onTapLastGamePlayed(final UserSettingsState state, final FindTheGrandmasterMovesGamePlayed gamePlayed) {
    showLoadingDialog(context, state, 'Das Spiel wird geladen');

    loadAnalyzedGamesInBundle(gamePlayed.analyzedGameOriginBundle).then((analyzedGames) {
      if (!mounted) {
        return;
      }

      if (!analyzedGames.any((game) => game.id == gamePlayed.analyzedGameId)) {
        _showGameNotFoundDialog(state);
        return;
      }

      final loadedGame = analyzedGames.firstWhere((game) => game.id == gamePlayed.analyzedGameId);

      Navigator.pop(context);

      pushNewScreen(
        context,
        screen: FindTheGrandmasterMovesScreen(analyzedGame: loadedGame, analyzedGameOriginBundle: gamePlayed.analyzedGameOriginBundle),
        withNavBar: false,
        customPageRoute: MaterialPageRoute(builder: (_) => FindTheGrandmasterMovesScreen(analyzedGame: loadedGame, analyzedGameOriginBundle: gamePlayed.analyzedGameOriginBundle)),
      );
    }).catchError((error, stacktrace) {
      _showGameNotFoundDialog(state);
      Navigator.pop(context);
    });
  }

  void _onShowLastGamePlayedSummary(final UserSettingsState state, final FindTheGrandmasterMovesGamePlayed gamePlayed) {
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
        widget.gameMode,
        state,
        gamePlayed.playedDateTimestamp,
        padding: const EdgeInsets.symmetric(horizontal: 20),
      ),
    );
  }

  void _showGameNotFoundDialog(final UserSettingsState state) {
    Navigator.pop(context);
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Fehler'),
        content: Text('Das ausgewählte Spiel konnte nicht gefunden werden'),
        actions: <Widget>[
          TextButton(
            child: Text('Ok'),
            style: TextButton.styleFrom(
              primary: appTheme(context, state.userSettings.themeMode).gameModeThemes[widget.gameMode]!.accentColor,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
