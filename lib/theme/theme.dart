import 'package:cupertino_will_pop_scope/cupertino_will_pop_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/model/game_mode.dart';

const double scaffoldPaddingHorizontal = 26.0;

class AppTheme {
  final Color scaffoldBackgroundColor;
  final Color cardBackgroundColor;
  final Color navigationBarColor;
  final Color textColor;
  final Map<GameModeEnum, GameModeTheme> gameModeThemes;

  AppTheme._({required this.scaffoldBackgroundColor, required this.cardBackgroundColor, required this.navigationBarColor, required this.textColor, required this.gameModeThemes});
}

class GameModeTheme {
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Color chessBoardDarkSquareColor;
  final Color chessBoardLightSquareColor;
  final Gradient backgroundGradient;

  GameModeTheme._({
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.chessBoardDarkSquareColor,
    required this.chessBoardLightSquareColor,
    required this.backgroundGradient,
  });
}

final AppTheme lightAppTheme = AppTheme._(
  scaffoldBackgroundColor: const Color(0xFFFFFFFF),
  cardBackgroundColor: const Color(0xFFEFEFEF),
  navigationBarColor: const Color(0xFFFFFFFF),
  textColor: const Color(0xFF21323d),
  gameModeThemes: {
    GameModeEnum.findTheGrandmasterMoves: GameModeTheme._(
      primaryColor: const Color(0xFFB5537A),
      secondaryColor: const Color(0xFFF5F0F1),
      accentColor: const Color(0xFFB5537A),
      chessBoardDarkSquareColor: const Color(0xFFB5537A),
      chessBoardLightSquareColor: const Color(0xFFF5F0F1),
      backgroundGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          const Color(0xff5b8296),
          const Color(0xFF776EAF),
          const Color(0xFF9E5F9B),
          const Color(0xFFB5537A),
        ],
        stops: [0, 0.09, 0.18, 0.27],
      ),
    ),
    GameModeEnum.timeBattle: GameModeTheme._(
      primaryColor: const Color(0xFF9E5F9B),
      secondaryColor: const Color(0xFFF5F0F1),
      accentColor: const Color(0xFF9E5F9B),
      chessBoardDarkSquareColor: const Color(0xFF9E5F9B),
      chessBoardLightSquareColor: const Color(0xFFF5F0F1),
      backgroundGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          const Color(0xff5b8296),
          const Color(0xFF776EAF),
          const Color(0xFF9E5F9B),
          const Color(0xFFB5537A),
        ],
        stops: [0, 0.09, 0.18, 0.27],
      ),
    ),
    GameModeEnum.survivalMode: GameModeTheme._(
      primaryColor: const Color(0xFF776EAF),
      secondaryColor: const Color(0xFFF5F0F1),
      accentColor: const Color(0xFF776EAF),
      chessBoardDarkSquareColor: const Color(0xFF776EAF),
      chessBoardLightSquareColor: const Color(0xFFF5F0F1),
      backgroundGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          const Color(0xff5b8296),
          const Color(0xFF776EAF),
          const Color(0xFF9E5F9B),
          const Color(0xFFB5537A),
        ],
        stops: [0, 0.09, 0.18, 0.27],
      ),
    ),
    GameModeEnum.puzzleMode: GameModeTheme._(
      primaryColor: const Color(0xff5b8296),
      secondaryColor: const Color(0xfff2f7f5),
      accentColor: const Color(0xff5b8296),
      chessBoardDarkSquareColor: const Color(0xff5b8296),
      chessBoardLightSquareColor: const Color(0xFFf2f7f5),
      backgroundGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          const Color(0xff5b8296),
          const Color(0xFF776EAF),
          const Color(0xFF9E5F9B),
          const Color(0xFFB5537A),
        ],
        stops: [0, 0.09, 0.18, 0.27],
      ),
    ),
  },
);

final AppTheme darkAppTheme = AppTheme._(
  scaffoldBackgroundColor: const Color(0xFF232438),
  cardBackgroundColor: const Color(0xFF343650),
  navigationBarColor: const Color(0xFF191A27),
  textColor: const Color(0xFFF5F0F1),
  gameModeThemes: {
    GameModeEnum.findTheGrandmasterMoves: GameModeTheme._(
      primaryColor: const Color(0xFF8D5371),
      secondaryColor: const Color(0xFFF7C4DE),
      accentColor: const Color(0xFFF7C4DE),
      chessBoardDarkSquareColor: const Color(0xFF8D5371),
      chessBoardLightSquareColor: const Color(0xFFF7C4DE),
      backgroundGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          const Color(0xff476678),
          const Color(0xFF776EAF),
          const Color(0xFF715177),
          const Color(0xFF8D5371),
        ],
        stops: [0, 0.09, 0.18, 0.27],
      ),
    ),
    GameModeEnum.timeBattle: GameModeTheme._(
      primaryColor: const Color(0xFF715177),
      secondaryColor: const Color(0xFFF5C3FF),
      accentColor: const Color(0xFFF5C3FF),
      chessBoardDarkSquareColor: const Color(0xFF715177),
      chessBoardLightSquareColor: const Color(0xFFF5C3FF),
      backgroundGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          const Color(0xff476678),
          const Color(0xFF776EAF),
          const Color(0xFF715177),
          const Color(0xFF8D5371),
        ],
        stops: [0, 0.09, 0.18, 0.27],
      ),
    ),
    GameModeEnum.survivalMode: GameModeTheme._(
      primaryColor: const Color(0xFF555073),
      secondaryColor: const Color(0xFFD0C9F8),
      accentColor: const Color(0xFFD0C9F8),
      chessBoardDarkSquareColor: const Color(0xFF555073),
      chessBoardLightSquareColor: const Color(0xFFD0C9F8),
      backgroundGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          const Color(0xff476678),
          const Color(0xFF776EAF),
          const Color(0xFF715177),
          const Color(0xFF8D5371),
        ],
        stops: [0, 0.09, 0.18, 0.27],
      ),
    ),
    GameModeEnum.puzzleMode: GameModeTheme._(
      primaryColor: const Color(0xff476678),
      secondaryColor: const Color(0xff85abb4),
      accentColor: const Color(0xff85abb4),
      chessBoardDarkSquareColor: const Color(0xff476678),
      chessBoardLightSquareColor: const Color(0xff85abb4),
      backgroundGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          const Color(0xff476678),
          const Color(0xFF776EAF),
          const Color(0xFF715177),
          const Color(0xFF8D5371),
        ],
        stops: [0, 0.09, 0.18, 0.27],
      ),
    ),
  },
);

final Map<ThemeMode, AppTheme> _appThemeByThemeMode = {
  ThemeMode.light: lightAppTheme,
  ThemeMode.dark: darkAppTheme,
};

AppTheme appTheme(final BuildContext context, final ThemeMode themeMode) {
  if (isDarkTheme(context, themeMode)) {
    return _appThemeByThemeMode[ThemeMode.dark]!;
  } else {
    return _appThemeByThemeMode[ThemeMode.light]!;
  }
}

ThemeData buildMaterialThemeData(final BuildContext context, final UserSettingsState userSettingsState, final GameModeEnum gameMode) {
  var systemUiOverlayStyle = isDarkTheme(context, userSettingsState.userSettings.themeMode) ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light;

  SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle.copyWith(
    systemNavigationBarColor: appTheme(context, userSettingsState.userSettings.themeMode).navigationBarColor,
    systemNavigationBarIconBrightness: isDarkTheme(context, userSettingsState.userSettings.themeMode) ? Brightness.light : Brightness.dark,
  ));

  final initialColorScheme = isDarkTheme(context, userSettingsState.userSettings.themeMode) ? ColorScheme.dark() : ColorScheme.light();

  return ThemeData(
    backgroundColor: appTheme(context, userSettingsState.userSettings.themeMode).scaffoldBackgroundColor,
    canvasColor: appTheme(context, userSettingsState.userSettings.themeMode).scaffoldBackgroundColor,
    hintColor: appTheme(context, userSettingsState.userSettings.themeMode).textColor,
    primaryColor: appTheme(context, userSettingsState.userSettings.themeMode).textColor,
    buttonColor: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[gameMode]!.accentColor,
    accentColor: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[gameMode]!.accentColor,
    focusColor: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[gameMode]!.accentColor,
    toggleableActiveColor: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[gameMode]!.accentColor,
    colorScheme: initialColorScheme.copyWith(
      primary: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[gameMode]!.accentColor,
      background: appTheme(context, userSettingsState.userSettings.themeMode).scaffoldBackgroundColor,
      secondary: appTheme(context, userSettingsState.userSettings.themeMode).navigationBarColor,
    ),
    textTheme: TextTheme(
      bodyText1: TextStyle(color: appTheme(context, userSettingsState.userSettings.themeMode).textColor),
      bodyText2: TextStyle(color: appTheme(context, userSettingsState.userSettings.themeMode).textColor),
      button: TextStyle(color: appTheme(context, userSettingsState.userSettings.themeMode).textColor),
      caption: TextStyle(color: appTheme(context, userSettingsState.userSettings.themeMode).textColor),
      subtitle1: TextStyle(color: appTheme(context, userSettingsState.userSettings.themeMode).textColor),
      headline1: TextStyle(color: appTheme(context, userSettingsState.userSettings.themeMode).textColor),
      headline2: TextStyle(color: appTheme(context, userSettingsState.userSettings.themeMode).textColor),
      headline3: TextStyle(color: appTheme(context, userSettingsState.userSettings.themeMode).textColor),
      headline4: TextStyle(color: appTheme(context, userSettingsState.userSettings.themeMode).textColor),
      headline5: TextStyle(color: appTheme(context, userSettingsState.userSettings.themeMode).textColor),
      headline6: TextStyle(color: appTheme(context, userSettingsState.userSettings.themeMode).textColor),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: appTheme(context, userSettingsState.userSettings.themeMode).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: appTheme(context, userSettingsState.userSettings.themeMode).textColor),
      contentTextStyle: TextStyle(color: appTheme(context, userSettingsState.userSettings.themeMode).textColor),
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: TextStyle(color: appTheme(context, userSettingsState.userSettings.themeMode).textColor),
      contentPadding: const EdgeInsets.symmetric(vertical: 10),
      focusColor: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[gameMode]!.accentColor,
      filled: true,
      fillColor: appTheme(context, userSettingsState.userSettings.themeMode).cardBackgroundColor,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: appTheme(context, userSettingsState.userSettings.themeMode).cardBackgroundColor,
          width: 1.0,
        ),
        borderRadius: const BorderRadius.all(
          const Radius.circular(10.0),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: appTheme(context, userSettingsState.userSettings.themeMode).gameModeThemes[gameMode]!.accentColor,
          width: 1.0,
        ),
        borderRadius: const BorderRadius.all(
          const Radius.circular(10.0),
        ),
      ),
    ),
    sliderTheme: SliderThemeData(thumbSelector: (
      TextDirection textDirection,
      RangeValues values,
      double tapValue,
      Size thumbSize,
      Size trackSize,
      double dx,
    ) {
      final double start = (tapValue - values.start).abs();
      final double end = (tapValue - values.end).abs();
      return start < end ? Thumb.start : Thumb.end;
    }),
    popupMenuTheme: PopupMenuThemeData(
      textStyle: TextStyle(color: appTheme(context, userSettingsState.userSettings.themeMode).textColor),
      color: appTheme(context, userSettingsState.userSettings.themeMode).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: appTheme(context, userSettingsState.userSettings.themeMode).navigationBarColor,
          width: 1.0,
        ),
        borderRadius: const BorderRadius.all(
          const Radius.circular(10.0),
        ),
      ),
      elevation: 0,
    ),
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoWillPopScopePageTransionsBuilder(),
        TargetPlatform.iOS: CupertinoWillPopScopePageTransionsBuilder(),
      },
    ),
  );
}
