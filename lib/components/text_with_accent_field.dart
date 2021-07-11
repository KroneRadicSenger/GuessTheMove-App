import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/theme/theme.dart';

class TextWithAccentField extends StatelessWidget {
  final UserSettingsState userSettingsState;
  final GameModeEnum gameMode;
  final String text;
  final String? accentBoxText;
  final bool? accentBoxTextBold;
  final bool accentBoxInAccentColor;
  final Widget? accentBoxWidget;
  final EdgeInsets valuePadding;

  const TextWithAccentField(
      {Key? key,
      required this.text,
      required this.userSettingsState,
      required this.gameMode,
      this.accentBoxText,
      this.accentBoxTextBold = false,
      this.accentBoxInAccentColor = true,
      this.accentBoxWidget,
      this.valuePadding = const EdgeInsets.symmetric(vertical: 3, horizontal: 15)})
      : assert(accentBoxText != null || accentBoxWidget != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final accentBoxColor = accentBoxInAccentColor
        ? appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[gameMode]!.accentColor
        : appTheme(context, userSettingsState.userSettings.themeMode).cardBackgroundColor;

    final accentBoxTextColor = accentBoxInAccentColor
        ? appTheme(context, userSettingsState.userSettings.themeMode).scaffoldBackgroundColor
        : appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[gameMode]!.accentColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        children: [
          Expanded(
            flex: 10,
            child: Container(
              margin: const EdgeInsets.only(right: 15),
              child: Text(
                text,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: appTheme(context, userSettingsState.userSettings.themeMode).textColor,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Container(
              decoration: BoxDecoration(
                color: accentBoxColor,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Padding(
                padding: valuePadding,
                child: Center(
                  child: accentBoxText != null
                      ? Text(
                          accentBoxText!,
                          style: TextStyle(
                            color: accentBoxTextColor,
                            fontSize: 14,
                            fontWeight: accentBoxTextBold! ? FontWeight.bold : FontWeight.normal,
                          ),
                        )
                      : accentBoxWidget!,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
