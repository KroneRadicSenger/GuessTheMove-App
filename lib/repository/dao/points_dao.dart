import 'package:guess_the_move/model/points.dart';
import 'package:guess_the_move/services/app_database.dart';
import 'package:sembast/sembast.dart';

class PointsDao {
  static const String POINTS_STORE_NAME = 'points';

  final _pointsStore = intMapStoreFactory.store(POINTS_STORE_NAME);

  final Database? database;

  PointsDao({this.database});

  Future<Database> get _db async {
    return database ?? await AppDatabase.instance.database;
  }

  Future update(final Points points) async {
    await _pointsStore.update(
      await _db,
      points.toJson(),
    );
  }

  Future<Points> get() async {
    final recordSnapshots = await _pointsStore.find(
      await _db,
    );

    if (recordSnapshots.isEmpty) {
      await insert(initialPoints);
      return initialPoints;
    }

    return Points.fromJson(recordSnapshots.first.value);
  }

  Future insert(final Points points) async {
    await _pointsStore.add(await _db, points.toJson());
  }

  Future reset() async {
    update(Points(0));
  }
}
