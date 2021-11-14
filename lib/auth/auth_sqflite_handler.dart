import 'package:flutter_frontend/auth/auth_user.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AuthSqfLiteHandler {
  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'auth.db'),
      onCreate: (database, version) async {
        await database.execute(
          "CREATE TABLE auth_user(id INTEGER PRIMARY KEY AUTOINCREMENT, email TEXT NOT NULL, password INTEGER NOT NULL)",
        );
      },
      version: 1,
    );
  }

  Future<int> insertUser(AuthUser user) async {
    int result = 0;
    final Database db = await initializeDB();
    result = await db.insert('auth_user', user.toMap());
    return result;
  }

  Future<AuthUser?> retrieveUser() async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.query('auth_user');
    return queryResult.map((e) => AuthUser.fromMap(e)).toList().isNotEmpty ? queryResult.map((e) => AuthUser.fromMap(e)).toList().first : null;
  }

  Future<void> deleteUsers() async {
    final db = await initializeDB();
    await db.delete(
      'auth_user'
    );
  }
}
