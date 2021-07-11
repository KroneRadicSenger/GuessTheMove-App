import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/components/titled_container.dart';
import 'package:guess_the_move/theme/theme.dart';

void showTitledModalBottomSheet(
  final BuildContext context,
  final UserSettingsState state,
  final String? title,
  final Widget content, {
  MainAxisAlignment titleMainAxisAlignment = MainAxisAlignment.start,
  TextAlign titleTextAlign = TextAlign.left,
}) {
  final safeAreaPaddingTop = MediaQueryData.fromWindow(WidgetsBinding.instance!.window).padding.top;

  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: const Radius.circular(30.0),
        topRight: const Radius.circular(30.0),
      ),
    ),
    backgroundColor: appTheme(context, state.userSettings.themeMode).scaffoldBackgroundColor,
    isScrollControlled: true,
    builder: (_) {
      return SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: safeAreaPaddingTop),
          child: TitledContainer(
            mainAxisAlignment: titleMainAxisAlignment,
            textAlign: titleTextAlign,
            title: title,
            titleSize: 22,
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: content,
            ),
          ),
        ),
      );
    },
  );
}
