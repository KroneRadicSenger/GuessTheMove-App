import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guess_the_move/model/points.dart';
import 'package:guess_the_move/repository/dao/points_dao.dart';
import 'package:sembast/sembast.dart';

import 'utils/test_database_provider.dart';

const testDatabasePath = 'test/dao/db/pointsdaotest.db';

void main() {
  group('PointsDao test', () {
    final dbProvider = TestDatabaseProvider();
    late Database db;

    setUp(() async {
      db = await dbProvider.open(testDatabasePath);
    });

    tearDown(() async {
      await db.close();
      return dbProvider.delete(testDatabasePath);
    });

    debugPrint('Running PointsDao tests..');

    test('initial get returns initial points', () async {
      final points = await PointsDao(database: db).get();
      expect(points.amount, initialPoints.amount);
    });

    test('add 5 points', () async {
      final points = await PointsDao(database: db).get();
      expect(points.amount, initialPoints.amount);

      await PointsDao(database: db).update(points.add(5));
      final newPoints = await PointsDao(database: db).get();
      expect(newPoints.amount, initialPoints.amount + 5);
    });

    test('subtract 5 points', () async {
      final points = await PointsDao(database: db).get();
      expect(points.amount, initialPoints.amount);

      await PointsDao(database: db).update(points.remove(5));
      final newPoints = await PointsDao(database: db).get();
      expect(newPoints.amount, initialPoints.amount - 5);
    });

    test('add and subtract 5 points', () async {
      final points = await PointsDao(database: db).get();
      expect(points.amount, initialPoints.amount);

      await PointsDao(database: db).update(points.add(5));
      var newPoints = await PointsDao(database: db).get();
      expect(newPoints.amount, initialPoints.amount + 5);

      await PointsDao(database: db).update(newPoints.remove(5));
      newPoints = await PointsDao(database: db).get();
      expect(newPoints.amount, initialPoints.amount);
    });
  });
}
