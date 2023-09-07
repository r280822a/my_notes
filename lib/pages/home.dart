import 'package:flutter/material.dart';
import 'package:my_notes/main.dart';
import 'package:my_notes/notes_db.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

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

  late NotesDatabase notesClass;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    getDatabase();
  }

  void getDatabase() async {
    notesClass = NotesDatabase();

    await notesClass.open();
    await notesClass.toList();

    // await notesClass.addNote("Title", "This is a note");
    // await notesClass.addNote("Another title", "this is another note");
    // await notesClass.addNote("Title12345678912345678912345", "1234567981234567891234567891234567891234");
    loading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {return loadingScreen(context);}

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Home"),
      ),

      body: MasonryGridView.count(
        padding: const EdgeInsets.all(8),
        itemCount: notesClass.notes.length,
        crossAxisCount: 2,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        itemBuilder: (context, index) {
          final Note note = notesClass.notes[index];

          return GestureDetector(
            onTap: () async {
              await Navigator.pushNamed(
                context,
                "/note",
                arguments: {"notesClass":notesClass, "note":notesClass.notes[index]},
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
                      note.title,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      note.description,
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
