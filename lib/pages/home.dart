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
  late NotesDatabase notesDB;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    getDatabase();
  }

  void getDatabase() async {
    notesDB = NotesDatabase();

    await notesDB.open();
    await notesDB.toList();

    // await notesDB.addNote("Title", "This is a note");
    // await notesDB.addNote("Another title", "this is another note");
    // await notesDB.addNote("Title12345678912345678912345", "1234567981234567891234567891234567891234");
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
        itemCount: notesDB.list.length,
        crossAxisCount: 2,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        itemBuilder: (context, index) {
          final Note note = notesDB.list[index];

          return GestureDetector(
            onTap: () async {
              await Navigator.pushNamed(
                context,
                "/note",
                arguments: {"notesDB":notesDB, "note":notesDB.list[index]},
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
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      note.description,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 5,
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
        onPressed: () async {
          int index = await notesDB.addNote("", "");
          
          if (mounted) {
            await Navigator.pushNamed(
              context,
              "/note",
              arguments: {"notesDB":notesDB, "note":notesDB.list[index]},
            );
          }
          setState(() {});
        },
        tooltip: "Add note",
        child: const Icon(Icons.add),
      ),
    );
  }
}
