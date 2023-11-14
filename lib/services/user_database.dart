import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class UserLocalCache {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'Users.db');

    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  static Future<void> _createDatabase(Database db, int version) async {
    await db.execute(
        'CREATE TABLE User(id TEXT PRIMARY KEY, firstName TEXT, lastName TEXT, isTeacher INTEGER, isVerified INTEGER, hoursType TEXT, hoursActivity TEXT)');
  }

  Future<void> insertUser(Map<String, dynamic> data) async {
    Database db = await database;
    await db.insert('User', data, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<List<Map<String, dynamic>>> getUser(String id) async {
    Database db = await database;
    return await db.rawQuery('SELECT * FROM User WHERE id = ?', [id]);
  }

  Future<void> updatePerson(
      String uid, String hoursType, String hoursActivity) async {
    Database db = await database;
    await db.update(
      'User',
      {"hoursType": hoursType, "hoursActivity": hoursActivity},
      where: 'id = ?',
      whereArgs: [uid],
    );
  }

  Future<String?> getUserName(String uid) async {
    Database db = await database;
    List<Map<String, dynamic>> users =
        await db.rawQuery('SELECT * FROM User WHERE id = ?', [uid]);
    if (users.isNotEmpty) {
      return users[0]["firstName"] + " " + users[0]["lastName"];
    }
    return null;
  }
}
