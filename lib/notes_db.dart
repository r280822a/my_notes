import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

class NotesDatabase {
  late Database database;
  late List<Note> list;

  Future open() async {
    String path = join(await getDatabasesPath(), "notes.db");

    // await deleteDatabase(path);
    database = await openDatabase(path, version: 1, onCreate: _createDB);
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

  Future toList() async {
    List<Map<String, Object?>> mapList = await database.query("notes");
    list = mapList.map((json) => Note.fromJson(json)).toList();
  }


  Future<int> addNote(String title, String description) async {
    Map<String, Object?> note = {
      "title": title,
      "description": description,
      "time": DateFormat('dd MMMM yyyy - hh:mm').format(DateTime.now()).toString(),
    };

    database.insert("notes", note);
    List<Map<String, Object?>> lastRow = await database.query("notes", orderBy: "_id DESC",limit: 1);
    list.add(Note.fromJson(lastRow[0]));
    return (list.length - 1);
  }

  Future updateNote(Note note) async {
    await database.update("notes", note.toJson(), where: "_id = ?", whereArgs: [note.id]);
  }

  Future deleteNote(Note note) async {
    await database.delete("notes", where: '_id = ?', whereArgs: [note.id]);
    list.remove(note);
  }

  Future swapNote(Note note1, Note note2) async {
    Note tempNote1 = note1;

    Map<String, Object?> note1Json = note1.toJson();
    note1Json.remove("_id");
    Map<String, Object?> note2Json = note2.toJson();
    note2Json.remove("_id");

    await database.update("notes", note2Json, where: "_id = ?", whereArgs: [note1.id]);
    await database.update("notes", note1Json, where: "_id = ?", whereArgs: [note2.id]);

    int note1Index = list.indexOf(note1);
    int note2Index = list.indexOf(note2);
    list[note1Index] = note2;
    list[note2Index] = tempNote1;
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
