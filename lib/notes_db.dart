import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class NotesDatabase {
  late Database database;
  late List<Note> notes;

  Future open() async {
    String path = join(await getDatabasesPath(), "notes.db");

    // await deleteDatabase(path);
    database = await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future toList() async {
    List<Map<String, Object?>> dbList = await database.query("notes");
    notes = dbList.map((json) => Note.fromJson(json)).toList();
  }

  Future addNote(String title, String description) async {
    Map<String, Object?> note = {
      "title": title,
      "description": description,
      "time": DateTime.now().toString(),
    };

    database.insert("notes", note);
    List<Map<String, Object?>> lastRow = await database.query("notes", orderBy: "_id DESC",limit: 1);
    notes.add(Note.fromJson(lastRow[0]));
  }

  Future updateNote(Note note) async {
    database.update("notes", note.toJson(), where: "_id = ?", whereArgs: [note.id]);
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
}

class Note{
  late int id;
  late String title;
  late String description;
  late String time;

  Note(this.id, this.title, this.description, this.time);

  static Note fromJson(Map<String, Object?> json){
    return Note(
      json["_id"] as int,
      json["title"] as String,
      json["description"] as String,
      json["time"] as String,
    );
  }

  Map<String, Object?> toJson(){
    return {
      "_id": id,
      "title": title,
      "description": description,
      "time": time,
    };
  }
}
