import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/components/titled_container.dart';
import 'package:guess_the_move/theme/theme.dart';

void showAutoResizingModalBottomSheet(
  final BuildContext context,
  final UserSettingsState state,
  final String? title,
  final Widget content, {
  MainAxisAlignment titleMainAxisAlignment = MainAxisAlignment.start,
  TextAlign titleTextAlign = TextAlign.left,
  EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 30),
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
    builder: (_) => SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: safeAreaPaddingTop + 5, bottom: 20),
                child: Container(
                  width: 50,
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6.0),
                    color: appTheme(context, state.userSettings.themeMode).cardBackgroundColor,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: padding,
            child: TitledContainer(
              mainAxisAlignment: titleMainAxisAlignment,
              textAlign: titleTextAlign,
              title: title,
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: content,
              ),
            ),
          ),
          Container(height: 40),
        ],
      ),
    ),
  );
}
