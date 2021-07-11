import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guess_the_move/bloc/points_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/guess_the_move_app.dart';
import 'package:guess_the_move/model/user_settings.dart';
import 'package:guess_the_move/repository/dao/user_settings_dao.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final splashLogoSvg = ExactAssetPicture(SvgPicture.svgStringDecoder, 'assets/app_logo_transparent.svg');
  await precachePicture(splashLogoSvg, null);

  final userSettings = await UserSettingsDao().get();

  SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top, SystemUiOverlay.bottom]);
  runApp(MyApp(userSettings));
}

class MyApp extends StatelessWidget {
  static final Random random = Random();

  final UserSettings userSettings;

  MyApp(this.userSettings);

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQueryData(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider<UserSettingsBloc>(
            create: (BuildContext context) {
              var userSettingsBloc = UserSettingsBloc(userSettings);
              return userSettingsBloc;
            },
          ),
          BlocProvider<PointsBloc>(
            create: (BuildContext context) {
              var pointsBloc = PointsBloc();
              pointsBloc.add(PointsLoadInitiated());
              return pointsBloc;
            },
          ),
        ],
        child: GuessTheMoveApp(),
      ),
    );
  }
}
