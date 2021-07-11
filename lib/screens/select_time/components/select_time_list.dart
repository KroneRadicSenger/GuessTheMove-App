import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/components/titled_container.dart';
import 'package:guess_the_move/components/utils/show_loading_dialog.dart';
import 'package:guess_the_move/components/vertical_list.dart';
import 'package:guess_the_move/main.dart';
import 'package:guess_the_move/model/analyzed_game.dart';
import 'package:guess_the_move/model/analyzed_games_bundle.dart';
import 'package:guess_the_move/model/player.dart';
import 'package:guess_the_move/screens/game_modes/time_battle/time_battle_screen.dart';
import 'package:guess_the_move/screens/select_time/components/select_time_element.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class SelectTimeList extends StatefulWidget {
  final Player grandmaster;
  final AnalyzedGamesBundle analyzedGameOriginBundle;

  const SelectTimeList({Key? key, required this.grandmaster, required this.analyzedGameOriginBundle}) : super(key: key);

  @override
  _SelectTimeListState createState() => _SelectTimeListState();
}

class _SelectTimeListState extends State<SelectTimeList> {
  @override
  Widget build(BuildContext context) => BlocBuilder<UserSettingsBloc, UserSettingsState>(builder: (context, userSettingsState) {
        return TitledContainer(
          title: 'Wie viel Startzeit\nmöchtest du haben?',
          subtitle: _buildSubtitleText(),
          showBackArrow: true,
          mainAxisAlignment: MainAxisAlignment.start,
          child: VerticalList(
            elements: [
              SelectTimeElement(
                grandmaster: widget.grandmaster,
                analyzedGameOriginBundle: widget.analyzedGameOriginBundle,
                initialTimeInSeconds: 30,
                onSelectTime: (initialTimeInSeconds, loadGameFuture) => _onSelectTime(initialTimeInSeconds, loadGameFuture, userSettingsState),
              ),
              SelectTimeElement(
                grandmaster: widget.grandmaster,
                analyzedGameOriginBundle: widget.analyzedGameOriginBundle,
                initialTimeInSeconds: 60,
                onSelectTime: (initialTimeInSeconds, loadGameFuture) => _onSelectTime(initialTimeInSeconds, loadGameFuture, userSettingsState),
              ),
              SelectTimeElement(
                grandmaster: widget.grandmaster,
                analyzedGameOriginBundle: widget.analyzedGameOriginBundle,
                initialTimeInSeconds: 90,
                onSelectTime: (initialTimeInSeconds, loadGameFuture) => _onSelectTime(initialTimeInSeconds, loadGameFuture, userSettingsState),
              ),
              SelectTimeElement(
                grandmaster: widget.grandmaster,
                analyzedGameOriginBundle: widget.analyzedGameOriginBundle,
                initialTimeInSeconds: 2 * 60,
                onSelectTime: (initialTimeInSeconds, loadGameFuture) => _onSelectTime(initialTimeInSeconds, loadGameFuture, userSettingsState),
              ),
              SelectTimeElement(
                grandmaster: widget.grandmaster,
                analyzedGameOriginBundle: widget.analyzedGameOriginBundle,
                initialTimeInSeconds: 5 * 60,
                onSelectTime: (initialTimeInSeconds, loadGameFuture) => _onSelectTime(initialTimeInSeconds, loadGameFuture, userSettingsState),
              ),
            ],
          ),
        );
      });

  void _onSelectTime(final int initialTimeInSeconds, final Future<List<AnalyzedGame>> loadGameFuture, final UserSettingsState userSettingsState) {
    showLoadingDialog(context, userSettingsState, 'Das Spiel wird geladen');

    loadGameFuture.then(
      (allGamesInBundle) {
        var newRandomGame = allGamesInBundle[MyApp.random.nextInt(allGamesInBundle.length)];

        Navigator.of(context, rootNavigator: true).pop();

        pushNewScreen(
          context,
          screen: TimeBattleScreen(
            analyzedGame: newRandomGame,
            analyzedGameOriginBundle: widget.analyzedGameOriginBundle,
            initialTimeInSeconds: initialTimeInSeconds,
          ),
          withNavBar: false,
          customPageRoute: MaterialPageRoute(
            builder: (_) => TimeBattleScreen(
              analyzedGame: newRandomGame,
              analyzedGameOriginBundle: widget.analyzedGameOriginBundle,
              initialTimeInSeconds: initialTimeInSeconds,
            ),
          ),
        );
      },
    );
  }

  String _buildSubtitleText() {
    return '\n' + 'Großmeister: ${widget.grandmaster.getFirstAndLastName()}\n' + 'Spielepaket: ${widget.analyzedGameOriginBundle.getDisplayName()}';
  }
}
