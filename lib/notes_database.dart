import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Stores/edits list and database of all notes
class NotesDatabase {
  late Database database; // Database to save notes to
  late List<Note> list; // List to help display notes

  Future open() async {
    // Opens the database
    String path = join(await getDatabasesPath(), "notes.db");

    // await deleteDatabase(path); // Deletes database - FOR TESTING ONLY
    database = await openDatabase(path, version: 1, onCreate: _createDB);
  }

  static Future _createDB(Database db, int version) async {
    // Creates database, if not created already
    const String idType = "INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL";
    const String textType = "TEXT NOT NULL";
    const String dateIntType = "INTEGER NOT NULL";

    await db.execute('''
CREATE TABLE notes ( 
  _id $idType,
  title $textType,
  description $textType,
  time $dateIntType
  )
''');
  }

  Future toList() async {
    // Converts database object to list
    List<Map<String, Object?>> mapList = await database.query("notes");
    list = mapList.map((map) => Note.fromMap(map)).toList();
  }


  Future<int> addNote(String title, String description) async {
    // Adds a note to database and list
    Map<String, Object?> note = {
      "title": title,
      "description": description,
      "time": DateTime.now().millisecondsSinceEpoch,
    };

    database.insert("notes", note);
    List<Map<String, Object?>> lastRow = await database.query("notes", orderBy: "_id DESC",limit: 1);
    list.add(Note.fromMap(lastRow[0]));
    return (list.length - 1);
  }

  Future insertNote(Note note, int index) async {
    // Inserts note into given index

    // Add blank entry
    await addNote("", "");

    // Push all items from (index + 1) to end of list up 1
    // Essentially moving the blank entry to index
    Batch batch = database.batch();
    for (int i = (list.length - 1); i > index; i--){
      Note first = list[i - 1];
      Map<String, Object?> firstMap = first.toMap();
      firstMap.remove("_id");

      batch.update("notes", 
        firstMap, 
        where: "_id = ?", 
        whereArgs: [list[i].id]
      );
      list[i].title = first.title;
      list[i].description = first.description;
      list[i].time = first.time;
    }
    await batch.commit(noResult: true);

    // Add note to index
    Map<String, Object?> noteMap = note.toMap();
    noteMap.remove("_id");
    await database.update("notes", 
      noteMap, 
      where: "_id = ?", 
      whereArgs: [list[index].id]
    );

    // Update list
    list[index].title = note.title;
    list[index].description = note.description;
    list[index].time = note.time;
  }

  Future updateNote(Note note) async {
    // Updates the note in database (list should already have been updated)
    await database.update("notes", note.toMap(), where: "_id = ?", whereArgs: [note.id]);
  }

  Future deleteNote(Note note) async {
    // Deletes note in database and list
    await database.delete("notes", where: '_id = ?', whereArgs: [note.id]);
    list.remove(note);
  }

  Future swapNote(Note note1, Note note2) async {
    // Swaps 2 notes in database and list
    Note tempNote1 = note1;

    // Convert notes to map, remove id
    Map<String, Object?> note1Map = note1.toMap();
    note1Map.remove("_id");
    Map<String, Object?> note2Map = note2.toMap();
    note2Map.remove("_id");

    // Swap notes in database
    await database.update("notes", note2Map, where: "_id = ?", whereArgs: [note1.id]);
    await database.update("notes", note1Map, where: "_id = ?", whereArgs: [note2.id]);

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
  late int time;

  Note(this.id, this.title, this.description, this.time);

  static Note fromMap(Map<String, Object?> map){
    return Note(
      map["_id"] as int,
      map["title"] as String,
      map["description"] as String,
      map["time"] as int,
    );
  }

  Map<String, Object?> toMap(){
    return {
      "_id": id,
      "title": title,
      "description": description,
      "time": time,
    };
  }
}
