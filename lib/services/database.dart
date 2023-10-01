import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabaseProvider {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'Notifications.db');

    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  static Future<void> _createDatabase(Database db, int version) async {
    await db.execute(
        'CREATE TABLE Notifications(id TEXT PRIMARY KEY, date TEXT, message TEXT, type TEXT, read INTEGER)');
  }

  Future<int> getUnreadCount() async {
    Database db = await _initDatabase();
    return Sqflite.firstIntValue(await db
        .rawQuery('SELECT COUNT(*) FROM Notifications WHERE read = 0'))!;
  }

  Future<void> insertNotification(Map<String, dynamic> data) async {
    Database db = await database;
    await db.insert('Notifications', data);
  }

  Future<List<Map<String, dynamic>>> getNotifications() async {
    Database db = await database;
    return await db.rawQuery('SELECT * FROM Notifications ORDER by date DESC');
  }

  Future<List<Map<String, dynamic>>> getUnreadNotifications() async {
    Database db = await database;
    return await db.rawQuery('SELECT * FROM Notifications WHERE read = 0');
  }

  Future<void> clearUnreadNotifications() async {
    Database db = await database;
    await db.rawQuery('UPDATE Notifications SET read = 1 WHERE read = 0');
  }
}
