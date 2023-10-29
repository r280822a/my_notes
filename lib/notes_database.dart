import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Stores/edits list and database of all notes
class NotesDatabase {
  late Database database; // Database to save notes to
  late List<Note> list; // List to help display notes

  bool hasUpgraded = false;

  Future open() async {
    // Opens the database
    String path = join(await getDatabasesPath(), "notes.db");

    // await deleteDatabase(path); // Deletes database - FOR TESTING ONLY
    database = await openDatabase(path, version: 2, 
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _upgradeDB(Database db, int currentVersion, int newVersion) async {
    if (currentVersion < newVersion) {
      // Adds column for list index, giving default value of 0
      await db.execute("ALTER TABLE notes ADD COLUMN list_index INTEGER NOT NULL DEFAULT 0;");
      hasUpgraded = true; // To run updateIndexes, when converting to list
    }
  }

  static Future _createDB(Database db, int version) async {
    // Creates database, if not created already
    const String idType = "INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL";
    const String textType = "TEXT NOT NULL";
    const String dateIntType = "INTEGER NOT NULL";
    const String listIndexType = "INTEGER NOT NULL";

    await db.execute('''
CREATE TABLE notes ( 
  _id $idType,
  title $textType,
  description $textType,
  time $dateIntType,
  list_index $listIndexType
  )
''');
  }

  Future toList() async {
    // Converts database object to list
    List<Map<String, Object?>> mapList = await database.query("notes", orderBy: "list_index ASC");
    list = mapList.map((map) => Note.fromMap(map)).toList();
    if (hasUpgraded) {updateIndexes();}
  }

  Future updateIndexes() async {
    // Iterate through each note, and update it's index
    Batch batch = database.batch();
    for (int i = 0; i < list.length; i++){
      batch.update("notes", 
        {"list_index": i}, 
        where: "_id = ?", 
        whereArgs: [list[i].id]
      );
    }
    await batch.commit(noResult: true);
  }


  Future<int> addNote(String title, String description) async {
    // Adds a note to database and end of list
    Map<String, Object?> note = {
      "title": title,
      "description": description,
      "time": DateTime.now().millisecondsSinceEpoch,
      "list_index": list.length
    };

    database.insert("notes", note);
    List<Map<String, Object?>> lastRow = await database.query("notes", orderBy: "_id DESC",limit: 1);
    list.add(Note.fromMap(lastRow[0]));
    return (list.length - 1);
  }

  Future insertNote(Note note, int index) async {
    // Inserts note into given index

    Batch batch = database.batch();
    for (int i = index; i < list.length; i++){
      // Iterate from (index + 1) to end of list
      // Incrementing each index, to give space to insert given note
      batch.update("notes", 
        {"list_index": (i + 1)}, 
        where: "_id = ?", 
        whereArgs: [list[i].id]
      );
    }
    await batch.commit(noResult: true);

    // Add note to index
    Map<String, Object?> noteMap = note.toMap();
    noteMap["list_index"] = index;
    database.insert("notes", noteMap);
    list.insert(index, note);
  }

  Future updateNote(Note note) async {
    // Updates the note in database
    // NOTE: list should already have been updated
    await database.update("notes", note.toMap(), where: "_id = ?", whereArgs: [note.id]);
  }

  Future deleteNote(Note note) async {
    // Deletes note in database and list
    await database.delete("notes", where: '_id = ?', whereArgs: [note.id]);
    list.remove(note);
    updateIndexes();
  }

  Future swapNote(int note1Index, int note2Index) async {
    // Swaps 2 notes in database and list
    Note note1 = list[note1Index];
    Note note2 = list[note2Index];

    // Swap notes in database
    await database.update("notes",
      {"list_index": note2Index},
      where: "_id = ?", whereArgs: [note1.id]
    );
    await database.update("notes",
      {"list_index": note1Index},
      where: "_id = ?", whereArgs: [note2.id]
    );

    // Swap notes in list
    list[note1Index] = note2;
    list[note2Index] = note1;
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
