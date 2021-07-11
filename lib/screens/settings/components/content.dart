import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/screens/settings/components/settings_list.dart';
import 'package:guess_the_move/theme/theme.dart';

class Content extends StatelessWidget {
  const Content() : super();

  @override
  Widget build(BuildContext context) => Expanded(
        child: BlocBuilder<UserSettingsBloc, UserSettingsState>(
          builder: (context, state) => Container(
            decoration: BoxDecoration(
              color: appTheme(context, state.userSettings.themeMode).scaffoldBackgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(30.0),
                topRight: const Radius.circular(30.0),
              ),
            ),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(30, 40, 30, 0),
              child: SettingsList(),
            ),
          ),
        ),
      );
}
