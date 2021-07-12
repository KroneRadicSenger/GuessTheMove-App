import 'package:guess_the_move/model/analyzed_games_bundle.dart';
import 'package:guess_the_move/model/player.dart';
import 'package:guess_the_move/model/puzzle_game_played.dart';
import 'package:guess_the_move/services/app_database.dart';
import 'package:sembast/sembast.dart';

class PuzzleGamesPlayedDao {
  static const String PUZZLE_GAMES_PLAYED_STORE_NAME = 'puzzleGamesPlayed';

  final _puzzleGamesPlayedStore = intMapStoreFactory.store(PUZZLE_GAMES_PLAYED_STORE_NAME);

  final Database? database;

  PuzzleGamesPlayedDao({this.database});

  Future<Database> get _db async {
    return database ?? await AppDatabase.instance.database;
  }

  Future deleteAll() async {
    return _puzzleGamesPlayedStore.delete(await _db);
  }

  Future insert(final PuzzleGamePlayed gamePlayed) async {
    return _puzzleGamesPlayedStore.add(await _db, gamePlayed.toJson());
  }

  Future<PuzzleGamePlayed?> getHighscoreGamePlayedByAnalyzedGamesBundle(final AnalyzedGamesBundle analyzedGamesBundle) async {
    var finder;

    if (analyzedGamesBundle is AnalyzedGamesBundleByGrandmasterAndYear) {
      finder = Finder(
        filter: Filter.and(
          [
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

    final recordSnapshots = await _puzzleGamesPlayedStore.find(await _db, finder: finder);
    if (recordSnapshots.isEmpty) {
      return null;
    }

    return recordSnapshots.map((snapshot) => PuzzleGamePlayed.fromJson(snapshot.value)).first;
  }

  Future<List<PuzzleGamePlayed>> getByAnalyzedGamesBundle(final AnalyzedGamesBundle analyzedGamesBundle) async {
    var finder;

    if (analyzedGamesBundle is AnalyzedGamesBundleByGrandmasterAndYear) {
      finder = Finder(
        filter: Filter.and(
          [
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

    final recordSnapshots = await _puzzleGamesPlayedStore.find(await _db, finder: finder);
    return recordSnapshots.map((snapshot) => PuzzleGamePlayed.fromJson(snapshot.value)).toList();
  }

  Future<List<PuzzleGamePlayed>> getByGrandmaster(final Player grandmaster) async {
    var finder = Finder(
      filter: Filter.equals('grandmaster.fullName', grandmaster.fullName),
      sortOrders: [
        SortOrder('playedDateTimestamp', false),
      ],
    );

    final recordSnapshots = await _puzzleGamesPlayedStore.find(await _db, finder: finder);
    return recordSnapshots.map((snapshot) => PuzzleGamePlayed.fromJson(snapshot.value)).toList();
  }

  Future<List<PuzzleGamePlayed>> getByPlayedDay(final DateTime playedDate) async {
    var beginDayDateTime = DateTime(playedDate.year, playedDate.month, playedDate.day);
    var endDayDateTime = DateTime(playedDate.year, playedDate.month, playedDate.day, 23, 59, 59);

    return getByPlayedDateInRange(beginDayDateTime, endDayDateTime);
  }

  // Note: this also considers the hours, minutes and seconds of the given dates
  //  so, e.g. DateTime(2020, 1, 2, 15, 50) would not be retrieved for the query
  //  getByPlayedDateInRange(DateTime(2020, 1, 1), DateTime(2020, 1, 2))
  Future<List<PuzzleGamePlayed>> getByPlayedDateInRange(final DateTime beginDate, final DateTime endDate) async {
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

    final recordSnapshots = await _puzzleGamesPlayedStore.find(await _db, finder: finder);
    return recordSnapshots.map((snapshot) => PuzzleGamePlayed.fromJson(snapshot.value)).toList();
  }

  Future<PuzzleGamePlayed?> getNewest() async {
    var finder = Finder(
      sortOrders: [
        SortOrder('playedDateTimestamp', false),
      ],
    );

    final recordSnapshots = await _puzzleGamesPlayedStore.find(await _db, finder: finder);
    final games = recordSnapshots.map((snapshot) => PuzzleGamePlayed.fromJson(snapshot.value)).toList();
    return games.isEmpty ? null : games.first;
  }

  Future<List<PuzzleGamePlayed>?> getAll() async {
    var finder = Finder(sortOrders: [
      SortOrder('playedDateTimestamp', false),
    ]);
    final recordSnapshots = await _puzzleGamesPlayedStore.find(await _db, finder: finder);
    return recordSnapshots.map((snapshot) => PuzzleGamePlayed.fromJson(snapshot.value)).toList();
  }
}
