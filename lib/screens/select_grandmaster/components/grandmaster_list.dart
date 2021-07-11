import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:guess_the_move/components/titled_container.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/model/player.dart';
import 'package:guess_the_move/repository/players_and_bundles_repository.dart';
import 'package:guess_the_move/screens/select_grandmaster/components/grandmaster.dart';
import 'package:guess_the_move/screens/select_grandmaster/components/test_phase_notice.dart';

class GrandmasterList extends StatelessWidget {
  final GameModeEnum gameMode;

  GrandmasterList({Key? key, required this.gameMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TitledContainer(
      title: 'Wähle einen Großmeister',
      showBackArrow: true,
      mainAxisAlignment: MainAxisAlignment.start,
      child: Expanded(
        child: Container(
          margin: EdgeInsets.only(top: 30.0),
          child: FutureBuilder(
            future: getAllGrandmasters(),
            builder: (BuildContext context, AsyncSnapshot<List<Player>> snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children: [
                    // TODO Remove after test phase
                    TestPhaseNotice(),
                    Expanded(
                      child: ListView.builder(
                        physics: BouncingScrollPhysics(),
                        itemCount: snapshot.data?.length ?? 0,
                        itemBuilder: (BuildContext context, int index) => Grandmaster(player: snapshot.data![index], gameMode: gameMode),
                      ),
                    ),
                  ],
                );
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ),
      ),
    );
  }
}
