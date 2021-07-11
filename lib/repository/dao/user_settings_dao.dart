import 'package:guess_the_move/model/user_settings.dart';
import 'package:guess_the_move/services/app_database.dart';
import 'package:sembast/sembast.dart';

class UserSettingsDao {
  static const String USER_SETTINGS_STORE_NAME = 'userSettings';

  final _userSettingsStore = intMapStoreFactory.store(USER_SETTINGS_STORE_NAME);

  final Database? database;

  UserSettingsDao({this.database});

  Future<Database> get _db async {
    return database ?? await AppDatabase.instance.database;
  }

  Future update(final UserSettings userSettings) async {
    await _userSettingsStore.update(
      await _db,
      userSettings.toJson(),
    );
  }

  Future<UserSettings> get() async {
    final recordSnapshots = await _userSettingsStore.find(
      await _db,
    );

    if (recordSnapshots.isEmpty) {
      await _insert(initialUserSettings);
      return initialUserSettings;
    }

    return UserSettings.fromJson(recordSnapshots.first.value);
  }

  Future _insert(final UserSettings userSettings) async {
    await _userSettingsStore.add(await _db, userSettings.toJson());
  }
}
