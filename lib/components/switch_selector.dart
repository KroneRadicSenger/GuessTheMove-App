import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/theme/theme.dart';

class SwitchSelector extends StatefulWidget {
  final String title;
  final bool initialValue;
  final EdgeInsets padding;
  final double titleSize;
  final GameModeEnum gameMode;
  final Function(bool) onChanged;

  SwitchSelector({
    Key? key,
    required this.initialValue,
    required this.title,
    required this.onChanged,
    this.padding = const EdgeInsets.fromLTRB(15, 0, 5, 0),
    this.titleSize = 14,
    this.gameMode = GameModeEnum.findTheGrandmasterMoves,
  }) : super(key: key);

  @override
  SwitchSelectorState createState() => SwitchSelectorState();
}

class SwitchSelectorState extends State<SwitchSelector> {
  bool _value = false;

  @override
  void initState() {
    _value = widget.initialValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<UserSettingsBloc, UserSettingsState>(builder: (context, userSettingsState) {
        return Container(
          decoration: BoxDecoration(color: appTheme(context, userSettingsState.userSettings.themeMode).cardBackgroundColor, borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Padding(
            padding: widget.padding,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      color: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[widget.gameMode]!.accentColor,
                      fontWeight: FontWeight.w600,
                      fontSize: widget.titleSize,
                    ),
                  ),
                ),
                Transform.scale(
                  scale: Platform.isAndroid ? 0.9 : 0.65,
                  child: Switch.adaptive(
                    activeColor: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[widget.gameMode]!.accentColor,
                    onChanged: (value) {
                      _value = value;
                      widget.onChanged(value);
                    },
                    value: _value,
                  ),
                ),
              ],
            ),
          ),
        );
      });

  void updateValue(final bool newValue) {
    setState(() {
      _value = newValue;
    });
  }
}
