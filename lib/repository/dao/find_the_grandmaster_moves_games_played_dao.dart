import 'package:guess_the_move/model/analyzed_game.dart';
import 'package:guess_the_move/model/find_the_grandmaster_moves_game_played.dart';
import 'package:guess_the_move/model/player.dart';
import 'package:guess_the_move/services/app_database.dart';
import 'package:sembast/sembast.dart';

class FindTheGrandmasterMovesGamesPlayedDao {
  static const String FIND_THE_GRANDMASTER_MOVES_GAMES_PLAYED_STORE_NAME = 'findTheGrandmasterMovesGamesPlayed';

  final _findTheGrandmasterMovesGamesPlayedStore = intMapStoreFactory.store(FIND_THE_GRANDMASTER_MOVES_GAMES_PLAYED_STORE_NAME);

  final Database? database;

  FindTheGrandmasterMovesGamesPlayedDao({this.database});

  Future<Database> get _db async {
    return database ?? await AppDatabase.instance.database;
  }

  Future deleteAll() async {
    return _findTheGrandmasterMovesGamesPlayedStore.delete(await _db);
  }

  Future insert(final FindTheGrandmasterMovesGamePlayed gamePlayed) async {
    return _findTheGrandmasterMovesGamesPlayedStore.add(await _db, gamePlayed.toJson());
  }

  Future<List<FindTheGrandmasterMovesGamePlayed>> getByAnalyzedGame(final AnalyzedGame analyzedGame) async {
    var finder = Finder(
      filter: Filter.equals('analyzedGameId', analyzedGame.id),
      sortOrders: [
        SortOrder('playedDateTimestamp', false),
      ],
    );

    final recordSnapshots = await _findTheGrandmasterMovesGamesPlayedStore.find(await _db, finder: finder);
    return recordSnapshots.map((snapshot) => FindTheGrandmasterMovesGamePlayed.fromJson(snapshot.value)).toList();
  }

  Future<List<FindTheGrandmasterMovesGamePlayed>> getByGrandmaster(final Player grandmaster) async {
    var finder = Finder(
      filter: Filter.or(
        [
          Filter.and([
            Filter.equals('info.grandmasterSide', 'white'),
            Filter.equals('info.whitePlayer.fullName', grandmaster.fullName),
          ]),
          Filter.and([
            Filter.equals('info.grandmasterSide', 'black'),
            Filter.equals('info.blackPlayer.fullName', grandmaster.fullName),
          ])
        ],
      ),
      sortOrders: [
        SortOrder('playedDateTimestamp', false),
      ],
    );

    final recordSnapshots = await _findTheGrandmasterMovesGamesPlayedStore.find(await _db, finder: finder);
    return recordSnapshots.map((snapshot) => FindTheGrandmasterMovesGamePlayed.fromJson(snapshot.value)).toList();
  }

  Future<List<FindTheGrandmasterMovesGamePlayed>> getByPlayedDay(final DateTime playedDate) async {
    var beginDayDateTime = DateTime(playedDate.year, playedDate.month, playedDate.day);
    var endDayDateTime = DateTime(playedDate.year, playedDate.month, playedDate.day, 23, 59, 59);

    return getByPlayedDateInRange(beginDayDateTime, endDayDateTime);
  }

  // Note: this also considers the hours, minutes and seconds of the given dates
  //  so, e.g. DateTime(2020, 1, 2, 15, 50) would not be retrieved for the query
  //  getByPlayedDateInRange(DateTime(2020, 1, 1), DateTime(2020, 1, 2))
  Future<List<FindTheGrandmasterMovesGamePlayed>> getByPlayedDateInRange(final DateTime beginDate, final DateTime endDate) async {
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

    final recordSnapshots = await _findTheGrandmasterMovesGamesPlayedStore.find(await _db, finder: finder);
    return recordSnapshots.map((snapshot) => FindTheGrandmasterMovesGamePlayed.fromJson(snapshot.value)).toList();
  }

  Future<FindTheGrandmasterMovesGamePlayed?> getNewest() async {
    var finder = Finder(
      sortOrders: [
        SortOrder('playedDateTimestamp', false),
      ],
    );

    final recordSnapshots = await _findTheGrandmasterMovesGamesPlayedStore.find(await _db, finder: finder);
    final games = recordSnapshots.map((snapshot) => FindTheGrandmasterMovesGamePlayed.fromJson(snapshot.value)).toList();
    return games.isEmpty ? null : games.first;
  }

  Future<List<FindTheGrandmasterMovesGamePlayed>?> getAll() async {
    var finder = Finder(sortOrders: [
      SortOrder('playedDateTimestamp', false),
    ]);
    final recordSnapshots = await _findTheGrandmasterMovesGamesPlayedStore.find(await _db, finder: finder);
    return recordSnapshots.map((snapshot) => FindTheGrandmasterMovesGamePlayed.fromJson(snapshot.value)).toList();
  }
}
