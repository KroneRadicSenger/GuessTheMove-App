import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/components/switch_selector.dart';
import 'package:guess_the_move/components/titled_container.dart';
import 'package:guess_the_move/components/utils/show_draggable_modal_bottom_sheet.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/model/user_settings.dart';
import 'package:guess_the_move/screens/settings/components/settings_group.dart';
import 'package:guess_the_move/screens/settings/components/settings_menu_selector.dart';
import 'package:guess_the_move/screens/settings/pages/about/about_page.dart';
import 'package:guess_the_move/screens/settings/pages/impress/impress_page.dart';
import 'package:guess_the_move/screens/settings/pages/osslicenses/oss_licenses_page.dart';
import 'package:guess_the_move/screens/settings/pages/privacypolicy/privacy_policy_page.dart';
import 'package:guess_the_move/screens/settings/utils/show_confirmation_dialog.dart';
import 'package:guess_the_move/theme/theme.dart';

class SettingsList extends StatefulWidget {
  @override
  _SettingsListState createState() => _SettingsListState();
}

class _SettingsListState extends State<SettingsList> {
  final GlobalKey<SwitchSelectorState> _switchSelectorStateRevealOpponentMoves1 = GlobalKey<SwitchSelectorState>();
  final GlobalKey<SwitchSelectorState> _switchSelectorStateRevealOpponentMoves2 = GlobalKey<SwitchSelectorState>();
  final GlobalKey<SwitchSelectorState> _switchSelectorStateRevealOpponentMoves3 = GlobalKey<SwitchSelectorState>();

  @override
  Widget build(BuildContext context) => BlocBuilder<UserSettingsBloc, UserSettingsState>(builder: (context, userSettingsState) {
        return SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: TitledContainer.multipleChildren(
            title: 'Einstellungen',
            children: [
              Container(height: 20),
              SettingsGroup(title: 'Allgemeine Einstellungen', settings: [
                SettingsMenuSelector(
                  title: 'Farbschema',
                  current: getCurrentThemeText(userSettingsState.userSettings.themeMode),
                  menuActions: ['Hell', 'Dunkel'],
                  onSelect: (value) {
                    BlocProvider.of<UserSettingsBloc>(context).add(UserSettingsThemeModeChanged(getThemeModeFromString(value)));
                  },
                ),
                SettingsMenuSelector(
                  title: 'Punktedarstellung',
                  current: getCurrentMoveEvaluationNotationText(userSettingsState.userSettings.moveEvaluationNotation),
                  menuActions: ['CP-Score', 'Siegwahrscheinlichkeit'],
                  onSelect: (value) {
                    BlocProvider.of<UserSettingsBloc>(context).add(UserSettingsMoveEvaluationNotationModeChanged(getMoveEvaluationNotationFromString(value)));
                  },
                ),
                SettingsMenuSelector(
                  title: 'Notation',
                  current: getCurrentMoveNotationText(userSettingsState.userSettings.moveNotation),
                  menuActions: ['Algebraische Notation', 'Figurine Notation', 'UCI-Engine Notation'],
                  onSelect: (value) {
                    BlocProvider.of<UserSettingsBloc>(context).add(UserSettingsMoveNotationModeChanged(getMoveNotationFromString(value)));
                  },
                ),
                SettingsMenuSelector(
                  title: 'Feldrotation',
                  current: getCurrentBoardRotationText(userSettingsState.userSettings.boardRotation),
                  menuActions: ['Weiß unten', 'Großmeister unten'],
                  onSelect: (value) {
                    BlocProvider.of<UserSettingsBloc>(context).add(UserSettingsBoardRotationChanged(getBoardRotationFromString(value)));
                  },
                ),
              ]),
              SettingsGroup(title: 'Großmeisterzüge finden', settings: [
                SwitchSelector(
                  key: _switchSelectorStateRevealOpponentMoves1,
                  title: 'Gegnerzüge direkt anzeigen',
                  initialValue: userSettingsState.userSettings.revealOpponentMovesFindGrandmasterMove,
                  onChanged: (value) => {BlocProvider.of<UserSettingsBloc>(context).add(UserSettingsRevealOpponentMovesFindGrandmasterMoveChanged(value))},
                ),
              ]),
              SettingsGroup(title: 'Zeitdruck', settings: [
                SwitchSelector(
                  key: _switchSelectorStateRevealOpponentMoves2,
                  title: 'Gegnerzüge direkt anzeigen',
                  initialValue: userSettingsState.userSettings.revealOpponentMovesTimeBattle,
                  onChanged: (value) => {BlocProvider.of<UserSettingsBloc>(context).add(UserSettingsRevealOpponentMovesTimeBattleChanged(value))},
                ),
              ]),
              SettingsGroup(title: 'Überleben', settings: [
                SwitchSelector(
                  key: _switchSelectorStateRevealOpponentMoves3,
                  title: 'Gegnerzüge direkt anzeigen',
                  initialValue: userSettingsState.userSettings.revealOpponentMovesSurvival,
                  onChanged: (value) => {BlocProvider.of<UserSettingsBloc>(context).add(UserSettingsRevealOpponentMovesSurvivalChanged(value))},
                ),
              ]),
              TextButton(
                onPressed: () => showConfirmationDialog(context, GameModeEnum.findTheGrandmasterMoves, userSettingsState, () {
                  BlocProvider.of<UserSettingsBloc>(context).add(UserSettingsReset());
                  _switchSelectorStateRevealOpponentMoves1.currentState!.updateValue(initialUserSettings.revealOpponentMovesFindGrandmasterMove);
                  _switchSelectorStateRevealOpponentMoves2.currentState!.updateValue(initialUserSettings.revealOpponentMovesTimeBattle);
                  _switchSelectorStateRevealOpponentMoves3.currentState!.updateValue(initialUserSettings.revealOpponentMovesSurvival);
                }, 'Standardeinstellungen wiederherstellen?', 'Möchtest du die Einstellung auf die Standardeinstellungen zurücksetzen?'),
                child: Center(
                  child: Text(
                    'Standardeinstellungen',
                    style: TextStyle(
                      color: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[GameModeEnum.findTheGrandmasterMoves]!.accentColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => showDraggableModalBottomSheet(context, userSettingsState, '', AboutPage()),
                child: Center(
                  child: Text(
                    'Über diese App',
                    style: TextStyle(
                      color: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[GameModeEnum.findTheGrandmasterMoves]!.accentColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => showDraggableModalBottomSheet(context, userSettingsState, '', OssLicensesPage()),
                child: Center(
                  child: Text(
                    'Open-Source-Software',
                    style: TextStyle(
                      color: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[GameModeEnum.findTheGrandmasterMoves]!.accentColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => showDraggableModalBottomSheet(context, userSettingsState, '', ImpressPage()),
                child: Center(
                  child: Text(
                    'Impressum',
                    style: TextStyle(
                      color: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[GameModeEnum.findTheGrandmasterMoves]!.accentColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => showDraggableModalBottomSheet(context, userSettingsState, '', PrivacyPolicyPage()),
                child: Center(
                  child: Text(
                    'Datenschutz',
                    style: TextStyle(
                      color: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[GameModeEnum.findTheGrandmasterMoves]!.accentColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              Container(height: 20),
            ],
          ),
        );
      });

  String getCurrentThemeText(ThemeMode themeMode) {
    if (themeMode == ThemeMode.dark) {
      return 'Dunkel';
    } else {
      return 'Hell';
    }
  }

  ThemeMode getThemeModeFromString(String current) {
    if (current == 'Hell') {
      return ThemeMode.light;
    } else if (current == 'Dunkel') {
      return ThemeMode.dark;
    }
    throw ArgumentError('Unexpected String argument.');
  }

  String getCurrentMoveNotationText(MoveNotationEnum moveNotation) {
    if (moveNotation == MoveNotationEnum.san) {
      return 'Algebraische Notation';
    } else if (moveNotation == MoveNotationEnum.fan) {
      return 'Figurine Notation';
    } else if (moveNotation == MoveNotationEnum.uci) {
      return 'UCI-Engine Notation';
    }
    throw ArgumentError('Unexpected themeMode argument.');
  }

  MoveNotationEnum getMoveNotationFromString(String current) {
    if (current == 'Algebraische Notation') {
      return MoveNotationEnum.san;
    } else if (current == 'Figurine Notation') {
      return MoveNotationEnum.fan;
    } else if (current == 'UCI-Engine Notation') {
      return MoveNotationEnum.uci;
    }
    throw ArgumentError('Unexpected String argument.');
  }

  String getCurrentMoveEvaluationNotationText(MoveEvaluationNotationEnum moveEvaluationNotation) {
    if (moveEvaluationNotation == MoveEvaluationNotationEnum.grandmasterExpectation) {
      return 'Siegwahrscheinlichkeit';
    } else if (moveEvaluationNotation == MoveEvaluationNotationEnum.pawnScore) {
      return 'CP-Score';
    }
    throw ArgumentError('Unexpected themeMode argument.');
  }

  MoveEvaluationNotationEnum getMoveEvaluationNotationFromString(String current) {
    if (current == 'Siegwahrscheinlichkeit') {
      return MoveEvaluationNotationEnum.grandmasterExpectation;
    } else if (current == 'CP-Score') {
      return MoveEvaluationNotationEnum.pawnScore;
    }
    throw ArgumentError('Unexpected String argument.');
  }

  String getCurrentBoardRotationText(BoardRotationEnum boardRotation) {
    if (boardRotation == BoardRotationEnum.white) {
      return 'Weiß unten';
    } else if (boardRotation == BoardRotationEnum.grandmaster) {
      return 'Großmeister unten';
    }
    throw ArgumentError('Unexpected themeMode argument.');
  }

  BoardRotationEnum getBoardRotationFromString(String current) {
    if (current == 'Weiß unten') {
      return BoardRotationEnum.white;
    } else if (current == 'Großmeister unten') {
      return BoardRotationEnum.grandmaster;
    }
    throw ArgumentError('Unexpected String argument.');
  }
}
