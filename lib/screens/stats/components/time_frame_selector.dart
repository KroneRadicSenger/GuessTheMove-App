import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/theme/theme.dart';

class TimeFrameSelection extends StatelessWidget {
  final List<String> timeFrames;
  final TabController controller;

  TimeFrameSelection({
    Key? key,
    required this.timeFrames,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserSettingsBloc, UserSettingsState>(
      builder: (context, userSettingsState) => TabBar(
        isScrollable: true,
        unselectedLabelColor: appTheme(context, userSettingsState.userSettings.themeMode).textColor,
        labelColor: appTheme(context, userSettingsState.userSettings.themeMode).textColor,
        indicatorSize: TabBarIndicatorSize.label,
        physics: BouncingScrollPhysics(),
        controller: controller,
        tabs: timeFrames
            .map(
              (t) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(t),
              ),
            )
            .toList(),
      ),
    );
  }
}
