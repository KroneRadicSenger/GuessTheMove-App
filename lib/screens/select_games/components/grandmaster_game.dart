import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/components/game_subtitle_text.dart';
import 'package:guess_the_move/components/game_title_text.dart';
import 'package:guess_the_move/model/analyzed_game.dart';
import 'package:guess_the_move/model/analyzed_games_bundle.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/screens/game_modes/find_the_grandmaster_moves/find_the_grandmaster_moves_screen.dart';
import 'package:guess_the_move/theme/theme.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class GrandmasterGame extends StatefulWidget {
  final AnalyzedGame analyzedGame;
  final AnalyzedGamesBundle analyzedGameOriginBundle;
  final GameModeEnum gameMode;

  GrandmasterGame({required this.analyzedGame, required this.analyzedGameOriginBundle, required this.gameMode, Key? key}) : super(key: key);

  @override
  _GrandmasterGameState createState() => _GrandmasterGameState();
}

class _GrandmasterGameState extends State<GrandmasterGame> with SingleTickerProviderStateMixin {
  bool _cardIsExpanded = false;
  late AnimationController _expandCardController;

  @override
  void initState() {
    _expandCardController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    super.initState();
  }

  @override
  void dispose() {
    _expandCardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<UserSettingsBloc, UserSettingsState>(
        builder: (context, state) {
          return Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            child: TextButton(
              onPressed: () => _onTap(context),
              style: TextButton.styleFrom(
                backgroundColor: appTheme(context, state.userSettings.themeMode).cardBackgroundColor,
                primary: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 2,
                        child: GameTitleText(
                          state,
                          widget.gameMode,
                          '${widget.analyzedGame.whitePlayer.getFirstAndLastName()} vs ${widget.analyzedGame.blackPlayer.getFirstAndLastName()}',
                          addMarginBottom: false,
                        ),
                      ),
                      Expanded(
                        child: GameSubtitleText(
                          state,
                          widget.analyzedGame.gameInfo.getDateFormatted(),
                          showBulletPoint: false,
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() {
                          _cardIsExpanded = !_cardIsExpanded;
                          if (_cardIsExpanded) {
                            _expandCardController.forward();
                          } else {
                            _expandCardController.reverse();
                          }
                        }),
                        constraints: BoxConstraints(),
                        icon: Icon(
                          _cardIsExpanded ? Icons.remove_circle_outline : Icons.add_circle_outline,
                          color: appTheme(context, state.userSettings.themeMode).gameModeThemes[widget.gameMode]!.accentColor,
                        ),
                      ),
                    ],
                  ),
                  SizeTransition(
                    sizeFactor: _expandCardController,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(height: 10),
                        GameSubtitleText(state, widget.analyzedGame.gameInfo.getEventAndSite()),
                        GameSubtitleText(state, widget.analyzedGame.gameInfo.getRoundAndDate()),
                        GameSubtitleText(state, widget.analyzedGame.gameAnalysis.opening.name.toString()),
                        if (widget.analyzedGame.whitePlayerRating != '-') GameSubtitleText(state, 'ELO Weiß: ${widget.analyzedGame.whitePlayerRating}'),
                        if (widget.analyzedGame.blackPlayerRating != '-') GameSubtitleText(state, 'ELO Schwarz: ${widget.analyzedGame.blackPlayerRating}'),
                        Container(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _onTap(context),
                                icon: Icon(Icons.play_arrow),
                                label: Text('Partie spielen'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

  void _onTap(final BuildContext context) {
    switch (widget.gameMode) {
      case GameModeEnum.findTheGrandmasterMoves:
        pushNewScreen(
          context,
          screen: FindTheGrandmasterMovesScreen(analyzedGame: widget.analyzedGame, analyzedGameOriginBundle: widget.analyzedGameOriginBundle),
          withNavBar: false,
          customPageRoute:
              MaterialPageRoute(builder: (_) => FindTheGrandmasterMovesScreen(analyzedGame: widget.analyzedGame, analyzedGameOriginBundle: widget.analyzedGameOriginBundle)),
        );
        break;
      default:
        throw StateError('Unsupported gamemode.');
    }
  }
}
