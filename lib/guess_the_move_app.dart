import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/screens/home/home_screen.dart';
import 'package:guess_the_move/screens/settings/settings_screen.dart';
import 'package:guess_the_move/screens/stats/stats_screen.dart';
import 'package:guess_the_move/theme/theme.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

import 'model/game_mode.dart';
import 'model/user_settings.dart';

class GuessTheMoveApp extends StatefulWidget {
  @override
  _GuessTheMoveAppState createState() => _GuessTheMoveAppState();
}

class _GuessTheMoveAppState extends State<GuessTheMoveApp> {
  Future? _precacheFuture;
  final PersistentTabController _controller = PersistentTabController(initialIndex: 0);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserSettingsBloc, UserSettingsState>(
      builder: (context, userSettingsState) => MaterialApp(
        theme: buildMaterialThemeData(context, userSettingsState, GameModeEnum.findTheGrandmasterMoves),
        home: FutureBuilder(
          future: _precacheSvgsForHomeScreen(context, userSettingsState.userSettings),
          builder: (context, AsyncSnapshot snapshot) {
            // Show splash screen while waiting for app resources to load:
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Splash();
            } else {
              // Loading is done, show the app
              return PersistentTabView(
                context,
                controller: _controller,
                screens: _buildScreens(),
                items: _buildNavBarsItems(context, userSettingsState),
                confineInSafeArea: true,
                backgroundColor: appTheme(context, userSettingsState.userSettings.themeMode).navigationBarColor,
                handleAndroidBackButtonPress: true,
                resizeToAvoidBottomInset: true,
                stateManagement: true,
                hideNavigationBarWhenKeyboardShows: true,
                decoration: NavBarDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(8.0), topRight: Radius.circular(8.0)),
                  colorBehindNavBar: Colors.white,
                ),
                popAllScreensOnTapOfSelectedTab: true,
                popActionScreens: PopActionScreensType.all,
                itemAnimationProperties: ItemAnimationProperties(
                  duration: Duration(milliseconds: 200),
                  curve: Curves.ease,
                ),
                screenTransitionAnimation: ScreenTransitionAnimation(
                  animateTabTransition: true,
                  curve: Curves.ease,
                  duration: Duration(milliseconds: 200),
                ),
                navBarStyle: NavBarStyle.style12,
              );
            }
          },
        ),
      ),
    );
  }

  List<Widget> _buildScreens() {
    return [
      HomeScreen(),
      StatsScreen(),
      SettingsScreen(),
    ];
  }

  List<PersistentBottomNavBarItem> _buildNavBarsItems(final BuildContext context, final UserSettingsState userSettingsState) {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.play_circle_fill),
        title: ('Spielen'),
        activeColorPrimary: appTheme(context, userSettingsState.userSettings.themeMode).textColor,
        inactiveColorPrimary: appTheme(context, userSettingsState.userSettings.themeMode).textColor.withOpacity(.4),
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.bar_chart),
        title: ('Statistik'),
        activeColorPrimary: appTheme(context, userSettingsState.userSettings.themeMode).textColor,
        inactiveColorPrimary: appTheme(context, userSettingsState.userSettings.themeMode).textColor.withOpacity(.4),
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.settings),
        title: ('Einstellungen'),
        activeColorPrimary: appTheme(context, userSettingsState.userSettings.themeMode).textColor,
        inactiveColorPrimary: appTheme(context, userSettingsState.userSettings.themeMode).textColor.withOpacity(.4),
      ),
    ];
  }

  Future _precacheSvgsForHomeScreen(final BuildContext context, final UserSettings userSettings) {
    if (_precacheFuture != null) {
      return _precacheFuture!;
    }

    final logoSvg;
    if (isDarkTheme(context, userSettings.themeMode)) {
      logoSvg = ExactAssetPicture(SvgPicture.svgStringDecoder, 'assets/svg/logo_dark.svg');
    } else {
      logoSvg = ExactAssetPicture(SvgPicture.svgStringDecoder, 'assets/svg/logo_light.svg');
    }

    final gamemode1Svg = ExactAssetPicture(SvgPicture.svgStringDecoder, 'assets/svg/half-dead.svg');
    final gamemode2Svg = ExactAssetPicture(SvgPicture.svgStringDecoder, 'assets/svg/throne-king.svg');
    final gamemode3Svg = ExactAssetPicture(SvgPicture.svgStringDecoder, 'assets/svg/time-trap.svg');
    final pointsSvg = ExactAssetPicture(SvgPicture.svgStringDecoder, 'assets/svg/two-coins.svg');

    _precacheFuture = Future.wait([
      precachePicture(logoSvg, context),
      precachePicture(gamemode1Svg, context),
      precachePicture(gamemode2Svg, context),
      precachePicture(gamemode3Svg, context),
      precachePicture(pointsSvg, context),
    ]);

    return _precacheFuture!;
  }
}

class Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserSettingsBloc, UserSettingsState>(
      builder: (context, userSettingsState) => Scaffold(
        backgroundColor: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[GameModeEnum.findTheGrandmasterMoves]!.primaryColor,
        body: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.44,
            child: SvgPicture.asset(
              'assets/app_logo_transparent.svg',
              semanticsLabel: 'Guess The Move',
            ),
          ),
        ),
      ),
    );
  }
}
