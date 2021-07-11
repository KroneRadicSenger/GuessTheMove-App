import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:guess_the_move/components/horizontal_list.dart';
import 'package:guess_the_move/components/titled_container.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/screens/home/components/game_mode.dart';
import 'package:guess_the_move/screens/puzzle_initial_select/puzzle_initial_select_screen.dart';
import 'package:guess_the_move/screens/select_grandmaster/select_grandmaster_screen.dart';

class GameModeList extends StatelessWidget {
  GameModeList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<GameMode> gameModeElements = [
      GameMode(
        gameModeEnum: GameModeEnum.findTheGrandmasterMoves,
        iconName: 'throne-king',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SelectGrandmasterScreen(gameMode: GameModeEnum.findTheGrandmasterMoves)),
        ),
      ),
      GameMode(
        gameModeEnum: GameModeEnum.timeBattle,
        iconName: 'time-trap',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SelectGrandmasterScreen(gameMode: GameModeEnum.timeBattle)),
        ),
      ),
      GameMode(
        gameModeEnum: GameModeEnum.survivalMode,
        iconName: 'half-dead',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SelectGrandmasterScreen(gameMode: GameModeEnum.survivalMode)),
        ),
      ),
      GameMode(
        gameModeEnum: GameModeEnum.puzzleMode,
        iconName: 'jigsaw-piece',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PuzzleInitialSelectScreen()),
        ),
      ),
    ];

    return TitledContainer(
      title: 'Wie möchtest du\nheute trainieren?',
      child: HorizontalList(elements: gameModeElements),
    );
  }
}
