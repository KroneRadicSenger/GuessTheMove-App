import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/components/header.dart';
import 'package:guess_the_move/model/analyzed_games_bundle.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/model/player.dart';
import 'package:guess_the_move/screens/select_lives/components/content.dart';
import 'package:guess_the_move/theme/theme.dart';

class SelectLivesScreen extends StatelessWidget {
  final Player grandmaster;
  final AnalyzedGamesBundle analyzedGameOriginBundle;

  SelectLivesScreen({Key? key, required this.grandmaster, required this.analyzedGameOriginBundle}) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocBuilder<UserSettingsBloc, UserSettingsState>(
        builder: (context, state) => Theme(
          data: buildMaterialThemeData(context, state, GameModeEnum.survivalMode),
          child: Container(
            decoration: BoxDecoration(
              gradient: appTheme(context, state.userSettings.themeMode).gameModeThemes[GameModeEnum.survivalMode]!.backgroundGradient,
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [Header(), Content(grandmaster: grandmaster, analyzedGameOriginBundle: analyzedGameOriginBundle)],
                ),
              ),
            ),
          ),
        ),
      );
}
