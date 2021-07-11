import 'package:guess_the_move/model/analyzed_games_bundle.dart';
import 'package:guess_the_move/model/player.dart';
import 'package:guess_the_move/model/time_battle_game_played.dart';
import 'package:guess_the_move/services/app_database.dart';
import 'package:sembast/sembast.dart';

class TimeBattleGamesPlayedDao {
  static const String TIME_BATTLE_GAMES_PLAYED_STORE_NAME = 'timeBattleGamesPlayed';

  final _timeBattleGamesPlayedStore = intMapStoreFactory.store(TIME_BATTLE_GAMES_PLAYED_STORE_NAME);

  final Database? database;

  TimeBattleGamesPlayedDao({this.database});

  Future<Database> get _db async {
    return database ?? await AppDatabase.instance.database;
  }

  Future deleteAll() async {
    return _timeBattleGamesPlayedStore.delete(await _db);
  }

  Future insert(final TimeBattleGamePlayed gamePlayed) async {
    return _timeBattleGamesPlayedStore.add(await _db, gamePlayed.toJson());
  }

  Future<TimeBattleGamePlayed?> getHighscoreGamePlayedByAnalyzedGamesBundleAndInitialTimeInSeconds(
      final AnalyzedGamesBundle analyzedGamesBundle, final int initialTimeInSeconds) async {
    var finder;

    if (analyzedGamesBundle is AnalyzedGamesBundleByGrandmasterAndYear) {
      finder = Finder(
        filter: Filter.and(
          [
            Filter.equals('initialTimeInSeconds', initialTimeInSeconds),
            Filter.equals('analyzedGameOriginBundle.grandmaster.fullName', analyzedGamesBundle.grandmaster.fullName),
            Filter.equals('analyzedGameOriginBundle.year', analyzedGamesBundle.year),
          ],
        ),
        sortOrders: [
          SortOrder('totalPointsGivenAmount', false),
          SortOrder('playedDateTimestamp', false), // to resolve multiple games played with same points amount
        ],
        limit: 1,
      );
    } else {
      throw ArgumentError('Unsupported analyzed games bundle type.');
    }

    final recordSnapshots = await _timeBattleGamesPlayedStore.find(await _db, finder: finder);
    if (recordSnapshots.isEmpty) {
      return null;
    }

    return recordSnapshots.map((snapshot) => TimeBattleGamePlayed.fromJson(snapshot.value)).first;
  }

  Future<List<TimeBattleGamePlayed>> getByAnalyzedGamesBundleAndInitialTimeInSeconds(final AnalyzedGamesBundle analyzedGamesBundle, final int initialTimeInSeconds) async {
    var finder;

    if (analyzedGamesBundle is AnalyzedGamesBundleByGrandmasterAndYear) {
      finder = Finder(
        filter: Filter.and(
          [
            Filter.equals('initialTimeInSeconds', initialTimeInSeconds),
            Filter.equals('analyzedGameOriginBundle.grandmaster.fullName', analyzedGamesBundle.grandmaster.fullName),
            Filter.equals('analyzedGameOriginBundle.year', analyzedGamesBundle.year),
          ],
        ),
        sortOrders: [
          SortOrder('playedDateTimestamp', false),
        ],
      );
    } else {
      throw ArgumentError('Unsupported analyzed games bundle type.');
    }

    final recordSnapshots = await _timeBattleGamesPlayedStore.find(await _db, finder: finder);
    return recordSnapshots.map((snapshot) => TimeBattleGamePlayed.fromJson(snapshot.value)).toList();
  }

  Future<List<TimeBattleGamePlayed>> getByGrandmaster(final Player grandmaster) async {
    var finder = Finder(
      filter: Filter.equals('grandmaster.fullName', grandmaster.fullName),
      sortOrders: [
        SortOrder('playedDateTimestamp', false),
      ],
    );

    final recordSnapshots = await _timeBattleGamesPlayedStore.find(await _db, finder: finder);
    return recordSnapshots.map((snapshot) => TimeBattleGamePlayed.fromJson(snapshot.value)).toList();
  }

  Future<List<TimeBattleGamePlayed>> getByPlayedDay(final DateTime playedDate) async {
    var beginDayDateTime = DateTime(playedDate.year, playedDate.month, playedDate.day);
    var endDayDateTime = DateTime(playedDate.year, playedDate.month, playedDate.day, 23, 59, 59);

    return getByPlayedDateInRange(beginDayDateTime, endDayDateTime);
  }

  // Note: this also considers the hours, minutes and seconds of the given dates
  //  so, e.g. DateTime(2020, 1, 2, 15, 50) would not be retrieved for the query
  //  getByPlayedDateInRange(DateTime(2020, 1, 1), DateTime(2020, 1, 2))
  Future<List<TimeBattleGamePlayed>> getByPlayedDateInRange(final DateTime beginDate, final DateTime endDate) async {
    var finder = Finder(
      filter: Filter.and(
        [
          Filter.greaterThanOrEquals('playedDateTimestamp', beginDate.millisecondsSinceEpoch),
          Filter.lessThanOrEquals('playedDateTimestamp', endDate.millisecondsSinceEpoch),
        ],
      ),
      sortOrders: [
        SortOrder('playedDateTimestamp', false),
      ],
    );

    final recordSnapshots = await _timeBattleGamesPlayedStore.find(await _db, finder: finder);
    return recordSnapshots.map((snapshot) => TimeBattleGamePlayed.fromJson(snapshot.value)).toList();
  }

  Future<TimeBattleGamePlayed?> getNewest() async {
    var finder = Finder(
      sortOrders: [
        SortOrder('playedDateTimestamp', false),
      ],
    );

    final recordSnapshots = await _timeBattleGamesPlayedStore.find(await _db, finder: finder);
    final games = recordSnapshots.map((snapshot) => TimeBattleGamePlayed.fromJson(snapshot.value)).toList();
    return games.isEmpty ? null : games.first;
  }

  Future<List<TimeBattleGamePlayed>?> getAll() async {
    var finder = Finder(sortOrders: [
      SortOrder('playedDateTimestamp', false),
    ]);
    final recordSnapshots = await _timeBattleGamesPlayedStore.find(await _db, finder: finder);
    return recordSnapshots.map((snapshot) => TimeBattleGamePlayed.fromJson(snapshot.value)).toList();
  }
}
