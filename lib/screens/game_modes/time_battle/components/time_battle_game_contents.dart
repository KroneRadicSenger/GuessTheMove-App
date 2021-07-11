import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/find_the_grandmaster_moves_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/components/header.dart';
import 'package:guess_the_move/screens/game_modes/components/chess_board/chessboard_model.dart';
import 'package:guess_the_move/screens/game_modes/components/game_layout.dart';
import 'package:guess_the_move/screens/game_modes/time_battle/components/time_battle_game_over_contents.dart';
import 'package:guess_the_move/theme/theme.dart';

class TimeBattleGameContents extends StatefulWidget {
  final ChessBoardController chessBoardController;
  final Widget ingameHeader;
  final int initialTimeInSeconds;
  final int totalMovesGuessed;
  final int movesGuessedCorrect;

  TimeBattleGameContents({
    Key? key,
    required this.chessBoardController,
    required this.ingameHeader,
    required this.initialTimeInSeconds,
    required this.totalMovesGuessed,
    required this.movesGuessedCorrect,
  }) : super(key: key);

  @override
  _TimeBattleGameContentsState createState() => _TimeBattleGameContentsState();
}

class _TimeBattleGameContentsState extends State<TimeBattleGameContents> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) => BlocBuilder<FindTheGrandmasterMovesBloc, FindTheGrandmasterMovesState>(
        builder: (context, state) => BlocBuilder<UserSettingsBloc, UserSettingsState>(
          builder: (context, userSettingsState) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              state is FindTheGrandmasterMovesIngameState ? widget.ingameHeader : Header(),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: appTheme(context, userSettingsState.userSettings.themeMode).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(30.0),
                      topRight: const Radius.circular(30.0),
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(.2), offset: Offset(0, -3), blurRadius: 4, spreadRadius: 0),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(scaffoldPaddingHorizontal, 20, scaffoldPaddingHorizontal, 0),
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: BouncingScrollPhysics(),
                      child: state is FindTheGrandmasterMovesTimeBattleGameOver
                          ? TimeBattleGameOverContents(
                              analyzedGamesOriginBundle: state.analyzedGameOriginBundle,
                              analyzedGamesPlayed: state.gamesPlayed,
                              gamesSummaryData: state.gamesSummaryData,
                              playedDateTimestamp: state.playedTimestamp,
                              userSettingsState: userSettingsState,
                              initialTimeInSeconds: widget.initialTimeInSeconds,
                              totalMovesGuessed: widget.totalMovesGuessed,
                              movesGuessedCorrect: widget.movesGuessedCorrect,
                            )
                          : GameLayout(
                              scrollController: _scrollController,
                              chessBoardController: widget.chessBoardController,
                              hidePlayerNames: false,
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
