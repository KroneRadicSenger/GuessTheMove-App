part of 'user_settings_bloc.dart';

@immutable
class UserSettingsState extends Equatable {
  final UserSettings userSettings;

  const UserSettingsState(this.userSettings);

  @override
  List<Object> get props => [userSettings];
}

@immutable
class UserSettingsInitial extends UserSettingsState {
  const UserSettingsInitial() : super(initialUserSettings);
}

bool isDarkTheme(final BuildContext context, final ThemeMode themeMode) {
  if (themeMode == ThemeMode.dark) {
    return true;
  }

  // TODO Remove or fix buggy material design widgets when system is set to dark
  /*if (themeMode == ThemeMode.system) {
    var brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.dark;
  }*/

  return false;
}
