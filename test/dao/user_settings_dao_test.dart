import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guess_the_move/model/user_settings.dart';
import 'package:guess_the_move/repository/dao/user_settings_dao.dart';
import 'package:sembast/sembast.dart';

import 'utils/test_database_provider.dart';

const testDatabasePath = 'test/dao/db/usersettingsdaotest.db';

void main() {
  group('UserSettingsDao test', () {
    final dbProvider = TestDatabaseProvider();
    late Database db;

    setUp(() async {
      db = await dbProvider.open(testDatabasePath);
    });

    tearDown(() async {
      await db.close();
      return dbProvider.delete(testDatabasePath);
    });

    debugPrint('Running UserSettingsDao tests..');

    test('initial get returns initial user settings', () async {
      final settings = await UserSettingsDao(database: db).get();
      expect(settings, initialUserSettings);
    });

    test('update theme mode and then change back to initial setting', () async {
      final settings = await UserSettingsDao(database: db).get();
      expect(settings, initialUserSettings);

      final newThemeMode = ThemeMode.dark;

      expect(newThemeMode, isNot(initialUserSettings.themeMode));

      await UserSettingsDao(database: db).update(settings.copyWith(themeMode: newThemeMode));
      var newSettings = await UserSettingsDao(database: db).get();
      expect(newSettings, initialUserSettings.copyWith(themeMode: newThemeMode));

      await UserSettingsDao(database: db).update(settings.copyWith(themeMode: initialUserSettings.themeMode));
      newSettings = await UserSettingsDao(database: db).get();
      expect(newSettings, initialUserSettings);
    });

    test('update move notation and then change back to initial setting', () async {
      final settings = await UserSettingsDao(database: db).get();
      expect(settings, initialUserSettings);

      final newMoveNotation = MoveNotationEnum.uci;

      expect(newMoveNotation, isNot(initialUserSettings.moveNotation));

      await UserSettingsDao(database: db).update(settings.copyWith(moveNotation: newMoveNotation));
      var newSettings = await UserSettingsDao(database: db).get();
      expect(newSettings, initialUserSettings.copyWith(moveNotation: newMoveNotation));

      await UserSettingsDao(database: db).update(settings.copyWith(moveNotation: initialUserSettings.moveNotation));
      newSettings = await UserSettingsDao(database: db).get();
      expect(newSettings, initialUserSettings);
    });

    test('update move evaluation notation and then change back to initial setting', () async {
      final settings = await UserSettingsDao(database: db).get();
      expect(settings, initialUserSettings);

      final newMoveEvaluationNotation = MoveEvaluationNotationEnum.grandmasterExpectation;

      expect(newMoveEvaluationNotation, isNot(initialUserSettings.moveEvaluationNotation));

      await UserSettingsDao(database: db).update(settings.copyWith(moveEvaluationNotation: newMoveEvaluationNotation));
      var newSettings = await UserSettingsDao(database: db).get();
      expect(newSettings, initialUserSettings.copyWith(moveEvaluationNotation: newMoveEvaluationNotation));

      await UserSettingsDao(database: db).update(settings.copyWith(moveEvaluationNotation: initialUserSettings.moveEvaluationNotation));
      newSettings = await UserSettingsDao(database: db).get();
      expect(newSettings, initialUserSettings);
    });

    test('update board rotation and then change back to initial setting', () async {
      final settings = await UserSettingsDao(database: db).get();
      expect(settings, initialUserSettings);

      final newBoardRotation = BoardRotationEnum.white;

      expect(newBoardRotation, isNot(initialUserSettings.boardRotation));

      await UserSettingsDao(database: db).update(settings.copyWith(boardRotation: newBoardRotation));
      var newSettings = await UserSettingsDao(database: db).get();
      expect(newSettings, initialUserSettings.copyWith(boardRotation: newBoardRotation));

      await UserSettingsDao(database: db).update(settings.copyWith(boardRotation: initialUserSettings.boardRotation));
      newSettings = await UserSettingsDao(database: db).get();
      expect(newSettings, initialUserSettings);
    });

    test('update reveal opponent moves in find grandmaster moves gamemode and then change back to initial setting', () async {
      final settings = await UserSettingsDao(database: db).get();
      expect(settings, initialUserSettings);

      final newRevealOpponentMovesFindGrandmasterMove = !initialUserSettings.revealOpponentMovesFindGrandmasterMove;

      expect(newRevealOpponentMovesFindGrandmasterMove, isNot(initialUserSettings.revealOpponentMovesFindGrandmasterMove));

      await UserSettingsDao(database: db).update(settings.copyWith(revealOpponentMovesFindGrandmasterMove: newRevealOpponentMovesFindGrandmasterMove));
      var newSettings = await UserSettingsDao(database: db).get();
      expect(newSettings, initialUserSettings.copyWith(revealOpponentMovesFindGrandmasterMove: newRevealOpponentMovesFindGrandmasterMove));

      await UserSettingsDao(database: db).update(settings.copyWith(revealOpponentMovesFindGrandmasterMove: initialUserSettings.revealOpponentMovesFindGrandmasterMove));
      newSettings = await UserSettingsDao(database: db).get();
      expect(newSettings, initialUserSettings);
    });

    test('update reveal opponent moves in time battle gamemode and then change back to initial setting', () async {
      final settings = await UserSettingsDao(database: db).get();
      expect(settings, initialUserSettings);

      final newRevealOpponentMovesTimeBattle = !initialUserSettings.revealOpponentMovesTimeBattle;

      expect(newRevealOpponentMovesTimeBattle, isNot(initialUserSettings.revealOpponentMovesTimeBattle));

      await UserSettingsDao(database: db).update(settings.copyWith(revealOpponentMovesTimeBattle: newRevealOpponentMovesTimeBattle));
      var newSettings = await UserSettingsDao(database: db).get();
      expect(newSettings, initialUserSettings.copyWith(revealOpponentMovesTimeBattle: newRevealOpponentMovesTimeBattle));

      await UserSettingsDao(database: db).update(settings.copyWith(revealOpponentMovesTimeBattle: initialUserSettings.revealOpponentMovesTimeBattle));
      newSettings = await UserSettingsDao(database: db).get();
      expect(newSettings, initialUserSettings);
    });

    test('update reveal opponent moves in survival gamemode and then change back to initial setting', () async {
      final settings = await UserSettingsDao(database: db).get();
      expect(settings, initialUserSettings);

      final newRevealOpponentMovesSurvival = !initialUserSettings.revealOpponentMovesSurvival;

      expect(newRevealOpponentMovesSurvival, isNot(initialUserSettings.revealOpponentMovesSurvival));

      await UserSettingsDao(database: db).update(settings.copyWith(revealOpponentMovesSurvival: newRevealOpponentMovesSurvival));
      var newSettings = await UserSettingsDao(database: db).get();
      expect(newSettings, initialUserSettings.copyWith(revealOpponentMovesSurvival: newRevealOpponentMovesSurvival));

      await UserSettingsDao(database: db).update(settings.copyWith(revealOpponentMovesSurvival: initialUserSettings.revealOpponentMovesSurvival));
      newSettings = await UserSettingsDao(database: db).get();
      expect(newSettings, initialUserSettings);
    });

    test('update all settings and then change back to initial settings', () async {
      final settings = await UserSettingsDao(database: db).get();
      expect(settings, initialUserSettings);

      final newThemeMode = ThemeMode.dark;
      expect(newThemeMode, isNot(initialUserSettings.themeMode));

      final newMoveNotation = MoveNotationEnum.uci;
      expect(newMoveNotation, isNot(initialUserSettings.moveNotation));

      final newMoveEvaluationNotation = MoveEvaluationNotationEnum.grandmasterExpectation;
      expect(newMoveEvaluationNotation, isNot(initialUserSettings.moveEvaluationNotation));

      final newBoardRotation = BoardRotationEnum.white;
      expect(newBoardRotation, isNot(initialUserSettings.boardRotation));

      final newRevealOpponentMovesFindGrandmasterMove = !initialUserSettings.revealOpponentMovesFindGrandmasterMove;
      expect(newRevealOpponentMovesFindGrandmasterMove, isNot(initialUserSettings.revealOpponentMovesFindGrandmasterMove));

      final newRevealOpponentMovesTimeBattle = !initialUserSettings.revealOpponentMovesTimeBattle;
      expect(newRevealOpponentMovesTimeBattle, isNot(initialUserSettings.revealOpponentMovesTimeBattle));

      final newRevealOpponentMovesSurvival = !initialUserSettings.revealOpponentMovesSurvival;
      expect(newRevealOpponentMovesSurvival, isNot(initialUserSettings.revealOpponentMovesSurvival));

      await UserSettingsDao(database: db).update(settings.copyWith(
        themeMode: newThemeMode,
        moveNotation: newMoveNotation,
        moveEvaluationNotation: newMoveEvaluationNotation,
        boardRotation: newBoardRotation,
        revealOpponentMovesFindGrandmasterMove: newRevealOpponentMovesFindGrandmasterMove,
        revealOpponentMovesTimeBattle: newRevealOpponentMovesTimeBattle,
        revealOpponentMovesSurvival: newRevealOpponentMovesSurvival,
      ));
      var newSettings = await UserSettingsDao(database: db).get();
      expect(
        newSettings,
        initialUserSettings.copyWith(
          themeMode: newThemeMode,
          moveNotation: newMoveNotation,
          moveEvaluationNotation: newMoveEvaluationNotation,
          boardRotation: newBoardRotation,
          revealOpponentMovesFindGrandmasterMove: newRevealOpponentMovesFindGrandmasterMove,
          revealOpponentMovesTimeBattle: newRevealOpponentMovesTimeBattle,
          revealOpponentMovesSurvival: newRevealOpponentMovesSurvival,
        ),
      );

      await UserSettingsDao(database: db).update(initialUserSettings);
      newSettings = await UserSettingsDao(database: db).get();
      expect(newSettings, initialUserSettings);
    });
  });
}
