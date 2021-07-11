import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';

class Logo extends StatelessWidget {
  const Logo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserSettingsBloc, UserSettingsState>(builder: (context, state) {
      final String assetPath = isDarkTheme(context, state.userSettings.themeMode) ? 'assets/svg/logo_dark.svg' : 'assets/svg/logo_light.svg';

      return SvgPicture.asset(
        assetPath,
        semanticsLabel: 'Guess The Move Logo',
        height: 40,
      );
    });
  }
}
