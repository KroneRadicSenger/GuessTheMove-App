part of 'user_settings_bloc.dart';

abstract class UserSettingsEvent extends Equatable {
  const UserSettingsEvent();

  @override
  List<Object> get props => [];
}

class UserSettingsReset extends UserSettingsEvent {}

class UserSettingsThemeModeChanged extends UserSettingsEvent {
  final ThemeMode value;

  const UserSettingsThemeModeChanged(this.value);

  @override
  List<Object> get props => [value];
}

class UserSettingsMoveNotationModeChanged extends UserSettingsEvent {
  final MoveNotationEnum value;

  const UserSettingsMoveNotationModeChanged(this.value);

  @override
  List<Object> get props => [value];
}

class UserSettingsMoveEvaluationNotationModeChanged extends UserSettingsEvent {
  final MoveEvaluationNotationEnum value;

  const UserSettingsMoveEvaluationNotationModeChanged(this.value);

  @override
  List<Object> get props => [value];
}

class UserSettingsBoardRotationChanged extends UserSettingsEvent {
  final BoardRotationEnum value;

  const UserSettingsBoardRotationChanged(this.value);

  @override
  List<Object> get props => [value];
}

class UserSettingsRevealOpponentMovesFindGrandmasterMoveChanged extends UserSettingsEvent {
  final bool value;

  const UserSettingsRevealOpponentMovesFindGrandmasterMoveChanged(this.value);

  @override
  List<Object> get props => [value];
}

class UserSettingsRevealOpponentMovesTimeBattleChanged extends UserSettingsEvent {
  final bool value;

  const UserSettingsRevealOpponentMovesTimeBattleChanged(this.value);

  @override
  List<Object> get props => [value];
}

class UserSettingsRevealOpponentMovesSurvivalChanged extends UserSettingsEvent {
  final bool value;

  const UserSettingsRevealOpponentMovesSurvivalChanged(this.value);

  @override
  List<Object> get props => [value];
}
