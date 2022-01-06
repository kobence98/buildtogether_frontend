import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'language_code.dart';

class LanguagesSqfLiteHandler {
  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'inno.db'),
      onCreate: (database, version) async {
        await database.execute(
          "CREATE TABLE languages(id INTEGER PRIMARY KEY AUTOINCREMENT, code TEXT NOT NULL)",
        );
      },
      version: 1,
    );
  }

  Future<int> insertLanguageCode(LanguageCode languageCode) async {
    int result = 0;
    final Database db = await initializeDB();
    await db.delete(
        'languages'
    );
    result = await db.insert('languages', languageCode.toMap());
    return result;
  }

  Future<LanguageCode?> retrieveLanguageCode() async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.query('languages');
    return queryResult.map((e) => LanguageCode.fromMap(e)).toList().isNotEmpty ? queryResult.map((e) => LanguageCode.fromMap(e)).toList().first : null;
  }
}
