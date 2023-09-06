import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class NotesDatabase {
  static Future<Database> open() async {
    String path = join(await getDatabasesPath(), "notes.db");

    await deleteDatabase(path);
    Database database = await openDatabase(path, version: 1, onCreate: _createDB);
    return database;
  }

  static Future _createDB(Database db, int version) async {
    const String idType = "INTEGER PRIMARY KEY AUTOINCREMENT";
    const String textType = "TEXT NOT NULL";

    await db.execute('''
CREATE TABLE notes ( 
  _id $idType,
  title $textType,
  description $textType,
  time $textType
  )
''');
  }

  static void test(Database db) {
    Map<String, Object?> note = {
      "title": "title",
      "description": "description",
      "time": DateTime.now().toString(),
    };

    db.insert("notes",note);
  }
}

