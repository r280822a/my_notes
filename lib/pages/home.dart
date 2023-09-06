import 'package:flutter/material.dart';
import 'package:my_notes/main.dart';
import 'package:my_notes/notes_db.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:sqflite/sqflite.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  void addNote(){
    setState(() {
      notes.add(["",""]);
    });
  }

  late Database notesDB;

  void getDatabase() async {
    notesDB = await NotesDatabase.open();
    print(notesDB);

    NotesDatabase.test(notesDB);
    NotesDatabase.test(notesDB);
    print(await notesDB.query("notes"));
  }

  @override
  Widget build(BuildContext context) {
    getDatabase();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Home"),
      ),

      body: MasonryGridView.count(
        padding: const EdgeInsets.all(8),
        itemCount: notes.length,
        crossAxisCount: 2,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        itemBuilder: (context, index) {
          final note = notes[index];

          return GestureDetector(
            onTap: () async {
              await Navigator.pushNamed(
                context,
                "/note",
                arguments: index,
              );
              setState(() {});
            },

            child: Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note[0],
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      note[1],
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: addNote,
        tooltip: 'Add note',
        child: const Icon(Icons.add),
      ),
    );
  }
}
