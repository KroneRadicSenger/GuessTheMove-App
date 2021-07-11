import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/components/titled_container.dart';
import 'package:guess_the_move/components/vertical_list.dart';
import 'package:guess_the_move/model/analyzed_games_bundle.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/model/player.dart';
import 'package:guess_the_move/repository/players_and_bundles_repository.dart';
import 'package:guess_the_move/screens/select_games_bundle/components/select_games_bundle_element.dart';

class SelectGamesBundleList extends StatelessWidget {
  final Player grandmaster;
  final GameModeEnum gameMode;

  const SelectGamesBundleList({Key? key, required this.grandmaster, required this.gameMode}) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocBuilder<UserSettingsBloc, UserSettingsState>(
        builder: (context, userSettingsState) {
          return TitledContainer(
            title: 'Wähle ein Spielepaket von\n${grandmaster.getFirstAndLastName()}',
            showBackArrow: true,
            mainAxisAlignment: MainAxisAlignment.start,
            child: FutureBuilder<List<AnalyzedGamesBundle>>(
              future: getAnalyzedGamesBundlesForGrandmaster(grandmaster),
              builder: (final context, final snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }
                return VerticalList(
                  elements: snapshot.data!
                      .map(
                        (bundle) => SelectGamesBundleElement(
                          bundle: bundle,
                          grandmaster: grandmaster,
                          gameMode: gameMode,
                        ),
                      )
                      .toList(),
                );
              },
            ),
          );
        },
      );
}
