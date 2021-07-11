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
import 'package:guess_the_move/screens/game_modes/survival/survival_screen.dart';
import 'package:guess_the_move/screens/select_lives/components/select_lives_element.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class SelectLivesList extends StatefulWidget {
  final Player grandmaster;
  final AnalyzedGamesBundle analyzedGameOriginBundle;

  const SelectLivesList({Key? key, required this.grandmaster, required this.analyzedGameOriginBundle}) : super(key: key);

  @override
  _SelectTimeListState createState() => _SelectTimeListState();
}

class _SelectTimeListState extends State<SelectLivesList> {
  @override
  Widget build(BuildContext context) => BlocBuilder<UserSettingsBloc, UserSettingsState>(builder: (context, userSettingsState) {
        return TitledContainer(
          title: 'Wie viele Leben\nmöchtest du haben?',
          subtitle: _buildSubtitleText(),
          showBackArrow: true,
          mainAxisAlignment: MainAxisAlignment.start,
          child: VerticalList(
            elements: [
              SelectLivesElement(
                grandmaster: widget.grandmaster,
                analyzedGameOriginBundle: widget.analyzedGameOriginBundle,
                amountLives: 1,
                onSelectLives: (initialLives, loadGameFuture) => _onSelectLives(initialLives, loadGameFuture, userSettingsState),
              ),
              SelectLivesElement(
                grandmaster: widget.grandmaster,
                analyzedGameOriginBundle: widget.analyzedGameOriginBundle,
                amountLives: 3,
                onSelectLives: (initialLives, loadGameFuture) => _onSelectLives(initialLives, loadGameFuture, userSettingsState),
              ),
              SelectLivesElement(
                grandmaster: widget.grandmaster,
                analyzedGameOriginBundle: widget.analyzedGameOriginBundle,
                amountLives: 5,
                onSelectLives: (initialLives, loadGameFuture) => _onSelectLives(initialLives, loadGameFuture, userSettingsState),
              ),
              SelectLivesElement(
                grandmaster: widget.grandmaster,
                analyzedGameOriginBundle: widget.analyzedGameOriginBundle,
                amountLives: 10,
                onSelectLives: (initialLives, loadGameFuture) => _onSelectLives(initialLives, loadGameFuture, userSettingsState),
              ),
              SelectLivesElement(
                grandmaster: widget.grandmaster,
                analyzedGameOriginBundle: widget.analyzedGameOriginBundle,
                amountLives: 15,
                onSelectLives: (initialLives, loadGameFuture) => _onSelectLives(initialLives, loadGameFuture, userSettingsState),
              ),
            ],
          ),
        );
      });

  void _onSelectLives(final int initialLives, final Future<List<AnalyzedGame>> loadGameFuture, final UserSettingsState userSettingsState) {
    showLoadingDialog(context, userSettingsState, 'Das Spiel wird geladen');

    loadGameFuture.then(
      (allGamesInBundle) {
        var newRandomGame = allGamesInBundle[MyApp.random.nextInt(allGamesInBundle.length)];

        Navigator.of(context, rootNavigator: true).pop();

        pushNewScreen(
          context,
          screen: SurvivalScreen(
            analyzedGame: newRandomGame,
            analyzedGameOriginBundle: widget.analyzedGameOriginBundle,
            amountLives: initialLives,
          ),
          withNavBar: false,
          customPageRoute: MaterialPageRoute(
            builder: (_) => SurvivalScreen(
              analyzedGame: newRandomGame,
              analyzedGameOriginBundle: widget.analyzedGameOriginBundle,
              amountLives: initialLives,
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
