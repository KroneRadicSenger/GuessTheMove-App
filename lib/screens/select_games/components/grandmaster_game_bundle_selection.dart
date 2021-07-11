import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/model/analyzed_games_bundle.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/theme/theme.dart';

class GrandmasterGameBundleSelection extends StatelessWidget {
  final GameModeEnum gameMode;
  final List<AnalyzedGamesBundle> bundles;
  final TabController controller;

  const GrandmasterGameBundleSelection({
    Key? key,
    required this.gameMode,
    required this.bundles,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserSettingsBloc, UserSettingsState>(
      builder: (context, userSettingsState) => TabBar(
        isScrollable: true,
        unselectedLabelColor: appTheme(context, userSettingsState.userSettings.themeMode).textColor,
        labelColor: appTheme(context, userSettingsState.userSettings.themeMode).textColor,
        physics: BouncingScrollPhysics(),
        controller: controller,
        tabs: bundles
            .map(
              (b) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(b.getDisplayName()),
              ),
            )
            .toList(),
      ),
    );
  }
}
