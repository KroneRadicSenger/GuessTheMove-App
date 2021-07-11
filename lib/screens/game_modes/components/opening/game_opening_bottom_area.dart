import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/find_the_grandmaster_moves_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/components/titled_container.dart';
import 'package:guess_the_move/screens/game_modes/components/game_moves_list.dart';
import 'package:guess_the_move/theme/theme.dart';

class GameOpeningBottomArea extends StatelessWidget {
  final FindTheGrandmasterMovesShowingOpening openingState;

  const GameOpeningBottomArea(this.openingState, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocBuilder<UserSettingsBloc, UserSettingsState>(
        builder: (context, userSettingsState) {
          final ply = openingState.move.ply;
          final openingMovesList = openingState.analyzedGame.gameAnalysis.opening.getMovesList();
          final openingMovesSublist = openingMovesList.sublist(0, ply + 1);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: TitledContainer(
                title: 'Spieleröffnung',
                mainAxisAlignment: MainAxisAlignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 30),
                            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                            decoration: BoxDecoration(
                              color: appTheme(context, userSettingsState.userSettings.themeMode).cardBackgroundColor,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Center(
                              child: Text(
                                openingState.analyzedGame.gameAnalysis.opening.name,
                                style: TextStyle(
                                  color: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[openingState.gameMode]!.accentColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    GameMovesList(movesList: openingMovesSublist, gameMode: openingState.gameMode),
                  ],
                )),
          );
        },
      );
}
