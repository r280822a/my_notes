import 'package:my_notes/utils/common.dart';
import 'package:sqflite/sqflite.dart';

// Stores/edits list and database of all notes
class NotesDatabase {
  late Database database; // Database to save notes to
  late List<Note> list; // List to help display notes

  final String tableName = "notes";
  bool hasUpgraded = false;

  Future open() async {
    // Opens the database
    final String path = await Common.getNotesDatabasePath();

    // await deleteDatabase(path); // Deletes database - FOR TESTING ONLY
    database = await openDatabase(path, version: 2, 
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future close() async {
    database.close();
  }

  Future _upgradeDB(Database db, int currentVersion, int newVersion) async {
    if (currentVersion < newVersion) {
      // Adds column for list index, giving default value of 0
      await db.execute("ALTER TABLE $tableName ADD COLUMN list_index INTEGER NOT NULL DEFAULT 0;");
      hasUpgraded = true; // To run updateIndexes, when converting to list
    }
  }

  Future _createDB(Database db, int version) async {
    // Creates database, if not created already
    const String idType = "INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL";
    const String textType = "TEXT NOT NULL";
    const String intType = "INTEGER NOT NULL";

    await db.execute('''
CREATE TABLE $tableName ( 
  _id $idType,
  title $textType,
  description $textType,
  time $intType,
  list_index $intType
  )
''');
  }

  Future toList() async {
    // Converts database object to list
    List<Map<String, Object?>> mapList = await database.query(tableName, orderBy: "list_index ASC");
    list = mapList.map((map) => Note.fromMap(map)).toList();
    if (hasUpgraded) {updateIndexes();}
  }

  Future updateIndexes() async {
    // Iterate through each note, and update it's index
    Batch batch = database.batch();
    for (int i = 0; i < list.length; i++){
      batch.update(tableName, 
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

    database.insert(tableName, note);
    List<Map<String, Object?>> lastRow = await database.query(tableName, orderBy: "_id DESC",limit: 1);
    list.add(Note.fromMap(lastRow[0]));
    return (list.length - 1);
  }

  Future insertNote(Note note, int index) async {
    // Inserts note into given index

    Batch batch = database.batch();
    for (int i = index; i < list.length; i++){
      // Iterate from index to end of list
      // Incrementing each index, to give space to insert given note
      batch.update(tableName, 
        {"list_index": (i + 1)}, 
        where: "_id = ?", 
        whereArgs: [list[i].id]
      );
    }
    await batch.commit(noResult: true);

    // Add note to index
    Map<String, Object?> noteMap = note.toMap();
    noteMap["list_index"] = index;
    database.insert(tableName, noteMap);
    list.insert(index, note);
  }

  Future updateNote(Note note) async {
    // Updates the note in database
    // NOTE: list should already have been updated
    await database.update(tableName, note.toMap(), where: "_id = ?", whereArgs: [note.id]);
  }

  Future deleteNote(Note note) async {
    // Deletes note in database and list
    await database.delete(tableName, where: '_id = ?', whereArgs: [note.id]);
    list.remove(note);
    updateIndexes();
  }

  Future swapNotes(int note1Index, int note2Index) async {
    // Swaps 2 notes in database and list
    Note note1 = list[note1Index];
    Note note2 = list[note2Index];

    // Swap notes in database
    await database.update(tableName,
      {"list_index": note2Index},
      where: "_id = ?", whereArgs: [note1.id]
    );
    await database.update(tableName,
      {"list_index": note1Index},
      where: "_id = ?", whereArgs: [note2.id]
    );

    // Swap notes in list
    list[note1Index] = note2;
    list[note2Index] = note1;
  }

  Future reorderNotesDB(Note note, int oldIndex, int newIndex) async {
    // Reorders notes in database
    // NOTE: list should already be reordered
    Batch batch = database.batch();
    int start = oldIndex;
    int end = newIndex;
    if (newIndex < oldIndex){
      start = newIndex;
      end = oldIndex;
    }

    for (int i = start; i <= end; i++){
      // Update list_index based on list
      // Between old and new indexes
      batch.update(tableName, 
        {"list_index": i}, 
        where: "_id = ?", 
        whereArgs: [list[i].id]
      );
    }
    await batch.commit(noResult: true);
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
