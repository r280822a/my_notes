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

  List<bool> selectedCards = [];
  bool selectMode = false;

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
    selectedCards = List.filled(notesDB.list.length, false, growable: true);
    setState(() {});
  }

  void selectCard(index){
    selectedCards[index] = !selectedCards[index];
    if (selectedCards.every((element) => element == false)) {
      selectMode = false;
    } else {
      selectMode = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {return loadingScreen(context);}

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Home"),
        leading: selectMode ? IconButton(
          onPressed: () {
            selectMode = false;
            selectedCards = List.filled(selectedCards.length, false, growable: true);
            setState(() {});
          },
          icon: const Icon(Icons.close)
        ) : null,
        actions: selectMode ? [
          IconButton(
            onPressed: () async {
              List<Note> notesToDelete = [];
              for (int i = 0; i < selectedCards.length; i++){
                if (selectedCards[i]){
                  notesToDelete.add(notesDB.list[i]);
                }
              }
              for (int i = 0; i < notesToDelete.length; i++){
                await notesDB.deleteNote(notesToDelete[i]);
              }
              selectMode = false;
              selectedCards = List.filled(notesDB.list.length, false, growable: true);
              setState(() {});
            }, 
            icon: const Icon(Icons.delete_outline_outlined)
          )
        ] : [],
      ),

      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,

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
              if (selectMode){
                selectCard(index);
              } else{
                await Navigator.pushNamed(
                  context,
                  "/note",
                  arguments: {"notesDB":notesDB, "note":notesDB.list[index]},
                );
                selectedCards = List.filled(notesDB.list.length, false, growable: true);
              }
              setState(() {});
            },

            onLongPress: () {
              selectCard(index);
              setState(() {});
            },

            child: Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(
                  color: selectedCards[index] ? Theme.of(context).colorScheme.outline : Theme.of(context).colorScheme.surface,
                  width: selectedCards[index] ? 3 : 0,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.title,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).textSelectionTheme.selectionColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      note.description,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 5,
                      style: TextStyle(
                        color: Theme.of(context).unselectedWidgetColor,
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
          selectedCards.add(false);
          
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
