import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/components/switch_selector.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/model/live_analysis_response.dart';
import 'package:guess_the_move/screens/game_modes/components/live_analysis/components/game_played_move_feedback.dart';
import 'package:guess_the_move/theme/theme.dart';

class GameLiveAnalysisResults extends StatelessWidget {
  final GameModeEnum gameMode;
  final UserSettingsState userSettingsState;
  final Stream<LiveAnalysisResponse?> liveAnalysisResponseStream;
  final bool fetchingLiveAnalysisResponse;
  final bool noMovePlayedYet;
  final bool liveAnalysisActivated;
  final String? errorMessage;
  final Function(bool) onLiveAnalysisSwitchChanged;

  GameLiveAnalysisResults(
      {required this.gameMode,
      required this.userSettingsState,
      required this.liveAnalysisResponseStream,
      required this.fetchingLiveAnalysisResponse,
      required this.noMovePlayedYet,
      required this.liveAnalysisActivated,
      required this.errorMessage,
      required this.onLiveAnalysisSwitchChanged,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: liveAnalysisResponseStream,
      builder: (final BuildContext context, final AsyncSnapshot<LiveAnalysisResponse?> snapshot) {
        return Container(
          decoration: BoxDecoration(
            color: appTheme(context, userSettingsState.userSettings.themeMode).cardBackgroundColor,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildContents(context, snapshot),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildContents(final BuildContext context, final AsyncSnapshot<LiveAnalysisResponse?> snapshot) {
    if (!liveAnalysisActivated) {
      return [
        SwitchSelector(
          initialValue: true,
          title: 'Live-Analyse',
          padding: const EdgeInsets.only(bottom: 5),
          titleSize: 16,
          gameMode: gameMode,
          onChanged: onLiveAnalysisSwitchChanged,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: Text('Die Live-Analyse ist derzeit deaktiviert'),
          ),
        ),
      ];
    }

    if (fetchingLiveAnalysisResponse) {
      return [
        SwitchSelector(
          initialValue: true,
          title: 'Live-Analyse',
          padding: const EdgeInsets.only(bottom: 5),
          titleSize: 16,
          gameMode: gameMode,
          onChanged: onLiveAnalysisSwitchChanged,
        ),
        Container(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: CircularProgressIndicator(),
        ),
        Container(height: 10),
      ];
    }

    if (errorMessage != null) {
      return [
        SwitchSelector(
          initialValue: true,
          title: 'Live-Analyse',
          padding: const EdgeInsets.only(bottom: 5),
          titleSize: 16,
          gameMode: gameMode,
          onChanged: onLiveAnalysisSwitchChanged,
        ),
        Container(height: 5),
        Text(errorMessage!, textAlign: TextAlign.justify),
      ];
    }

    if (!snapshot.hasData || noMovePlayedYet) {
      return [];
    }

    final movePlayed = snapshot.data!.evaluatedMove;

    return [
      SwitchSelector(
        initialValue: true,
        title: 'Live-Analyse',
        padding: const EdgeInsets.all(0),
        titleSize: 16,
        gameMode: gameMode,
        onChanged: onLiveAnalysisSwitchChanged,
      ),
      GamePlayedMoveFeedback(
        gameMode: gameMode,
        userSettingsState: userSettingsState,
        move: movePlayed.move,
        turn: snapshot.data!.turn,
        moveType: movePlayed.moveType,
        pv: movePlayed.pv,
        signedCpScore: movePlayed.signedCPScore,
      ),
      ..._buildAlternativeMove(context, snapshot),
    ];
  }

  List<Widget> _buildAlternativeMove(final BuildContext context, final AsyncSnapshot<LiveAnalysisResponse?> snapshot) {
    final movePlayed = snapshot.data!.evaluatedMove;
    final alternativeMove = snapshot.data!.alternativeMoves.where((move) => move != movePlayed).toList();

    if (alternativeMove.isEmpty) {
      return [];
    }

    return [
      Container(height: 15),
      Text(
        'Alternative',
        style: TextStyle(
          color: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[gameMode]!.accentColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      GamePlayedMoveFeedback(
        gameMode: gameMode,
        userSettingsState: userSettingsState,
        move: alternativeMove.first.move,
        turn: snapshot.data!.turn,
        moveType: alternativeMove.first.moveType,
        pv: alternativeMove.first.pv,
        signedCpScore: alternativeMove.first.signedCPScore,
      ),
    ];
  }
}
