import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guess_the_move/model/user_settings.dart';
import 'package:guess_the_move/repository/dao/user_settings_dao.dart';

part 'user_settings_event.dart';
part 'user_settings_state.dart';

class UserSettingsBloc extends Bloc<UserSettingsEvent, UserSettingsState> {
  UserSettingsBloc(final UserSettings userSettings) : super(UserSettingsState(userSettings));

  @override
  Stream<UserSettingsState> mapEventToState(
    UserSettingsEvent event,
  ) async* {
    if (event is UserSettingsReset) {
      await UserSettingsDao().update(initialUserSettings);
      yield UserSettingsState(initialUserSettings);
    } else if (event is UserSettingsThemeModeChanged) {
      final newUserSettings = state.userSettings.copyWith(themeMode: event.value);
      await UserSettingsDao().update(newUserSettings);
      yield UserSettingsState(newUserSettings);
    } else if (event is UserSettingsMoveNotationModeChanged) {
      final newUserSettings = state.userSettings.copyWith(moveNotation: event.value);
      await UserSettingsDao().update(newUserSettings);
      yield UserSettingsState(newUserSettings);
    } else if (event is UserSettingsMoveEvaluationNotationModeChanged) {
      final newUserSettings = state.userSettings.copyWith(moveEvaluationNotation: event.value);
      await UserSettingsDao().update(newUserSettings);
      yield UserSettingsState(newUserSettings);
    } else if (event is UserSettingsRevealOpponentMovesFindGrandmasterMoveChanged) {
      final newUserSettings = state.userSettings.copyWith(revealOpponentMovesFindGrandmasterMove: event.value);
      await UserSettingsDao().update(newUserSettings);
      yield UserSettingsState(newUserSettings);
    } else if (event is UserSettingsRevealOpponentMovesTimeBattleChanged) {
      final newUserSettings = state.userSettings.copyWith(revealOpponentMovesTimeBattle: event.value);
      await UserSettingsDao().update(newUserSettings);
      yield UserSettingsState(newUserSettings);
    } else if (event is UserSettingsRevealOpponentMovesSurvivalChanged) {
      final newUserSettings = state.userSettings.copyWith(revealOpponentMovesSurvival: event.value);
      await UserSettingsDao().update(newUserSettings);
      yield UserSettingsState(newUserSettings);
    } else if (event is UserSettingsBoardRotationChanged) {
      final newUserSettings = state.userSettings.copyWith(boardRotation: event.value);
      await UserSettingsDao().update(newUserSettings);
      yield UserSettingsState(newUserSettings);
    }
  }
}
