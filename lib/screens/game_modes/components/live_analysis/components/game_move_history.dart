import 'package:chess/chess.dart' as chess;
import 'package:flutter/widgets.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/screens/game_modes/components/game_moves_list.dart';

class GameMoveHistory extends StatelessWidget {
  final GameModeEnum gameMode;
  final Stream<chess.Chess> boardStream;

  const GameMoveHistory({Key? key, required this.gameMode, required this.boardStream}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<chess.Chess>(
      stream: boardStream,
      builder: (BuildContext context, AsyncSnapshot<chess.Chess> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Container();
          case ConnectionState.waiting:
            return Container();
          case ConnectionState.active:
          case ConnectionState.done:
            final movesHistory = _getMovesHistoryFromLibraryBoard(snapshot.data!);
            return GameMovesList(movesList: movesHistory, gameMode: gameMode);
        }
      },
    );
  }

  List<String> _getMovesHistoryFromLibraryBoard(final chess.Chess currentBoard) {
    return currentBoard.history.map((state) => state.move.toAlgebraic).toList();
  }
}
