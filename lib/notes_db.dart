import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

class NotesDatabase {
  // Database to save notes to
  late Database database;
  // List to help display notes
  late List<Note> list;

  Future open() async {
    // Opens the database
    String path = join(await getDatabasesPath(), "notes.db");

    // await deleteDatabase(path);
    database = await openDatabase(path, version: 1, onCreate: _createDB);
  }

  static Future _createDB(Database db, int version) async {
    // Creates database, if not created already
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
    // Converts database object to list
    List<Map<String, Object?>> mapList = await database.query("notes");
    list = mapList.map((json) => Note.fromJson(json)).toList();
  }


  Future<int> addNote(String title, String description) async {
    // Adds a note to database and list
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
    // Updates the note in database
    await database.update("notes", note.toJson(), where: "_id = ?", whereArgs: [note.id]);
  }

  Future deleteNote(Note note) async {
    // Deletes note in database and list
    await database.delete("notes", where: '_id = ?', whereArgs: [note.id]);
    list.remove(note);
  }

  Future swapNote(Note note1, Note note2) async {
    // Swaps 2 notes in database and list
    Note tempNote1 = note1;

    // Convert notes to json, remove id
    Map<String, Object?> note1Json = note1.toJson();
    note1Json.remove("_id");
    Map<String, Object?> note2Json = note2.toJson();
    note2Json.remove("_id");

    // Swap notes in database
    await database.update("notes", note2Json, where: "_id = ?", whereArgs: [note1.id]);
    await database.update("notes", note1Json, where: "_id = ?", whereArgs: [note2.id]);

    // Swap notes in list
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
