import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class TestDatabaseProvider {
  final factory = databaseFactoryIo;

  Future<Database> open(final String dbPath) async {
    await delete(dbPath);
    return await factory.openDatabase(dbPath);
  }

  Future<void> delete(final String dbPath) async {
    await factory.deleteDatabase(dbPath);
  }
}
