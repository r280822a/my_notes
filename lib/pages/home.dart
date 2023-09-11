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

  // List to see if note is selected
  List<bool> isSelected = [];
  bool selectModeEnabled = false;

  @override
  void initState() {
    super.initState();
    getDatabase();
  }

  void getDatabase() async {
    // Opens database, turns database to list
    notesDB = NotesDatabase();

    await notesDB.open();
    await notesDB.toList();

    isSelected = List.filled(notesDB.list.length, false, growable: true);
    loading = false;
    setState(() {});
  }

  void selectCard(index){
    // Selects card at given index
    isSelected[index] = !isSelected[index];
    if (isSelected.every((element) => element == false)) {
      selectModeEnabled = false;
    } else {
      selectModeEnabled = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {return loadingScreen(context);}

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Home"),
        // If a card is selected then display buttons, else display nothing
        leading: selectModeEnabled ? IconButton(
          onPressed: () {
            // Close select mode, set all items in isSelected to false
            selectModeEnabled = false;
            isSelected = List.filled(isSelected.length, false, growable: true);
            setState(() {});
          },
          icon: const Icon(Icons.close)
        ) : null,
        actions: selectModeEnabled ? [
          IconButton(
            onPressed: () async {
              // Find notes to swap
              List<Note> notesToSwap = [];
              for (int i = 0; i < isSelected.length; i++){
                if (isSelected[i]){
                  notesToSwap.add(notesDB.list[i]);
                }
              }
              // Only swap if exactly 2 selected
              if (notesToSwap.length != 2){
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Swapping only works with 2 notes"),
                ));
              } else{
                await notesDB.swapNote(notesToSwap[0], notesToSwap[1]);
              }
              setState(() {});
            },
            icon: const Icon(Icons.swap_horiz_outlined)
          ),
          IconButton(
            onPressed: () async {
              // Find notes to delete
              List<Note> notesToDelete = [];
              for (int i = 0; i < isSelected.length; i++){
                if (isSelected[i]){
                  notesToDelete.add(notesDB.list[i]);
                }
              }
              // Delete all selected notes
              for (int i = 0; i < notesToDelete.length; i++){
                await notesDB.deleteNote(notesToDelete[i]);
              }
              isSelected = List.filled(notesDB.list.length, false, growable: true);
              selectModeEnabled = false;
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
          // For each note in notesDB.list
          final Note note = notesDB.list[index];

          return GestureDetector(
            onTap: () async {
              // If select mode is enabled, select card
              // Else, open note editor
              if (selectModeEnabled){
                selectCard(index);
              } else{
                await Navigator.pushNamed(
                  context,
                  "/note_editor",
                  arguments: {"notesDB":notesDB, "note":notesDB.list[index]},
                );
                // Update in case note deleted
                isSelected = List.filled(notesDB.list.length, false, growable: true);
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
                  // If selected, add border
                  color: isSelected[index] ? Theme.of(context).colorScheme.outline : Theme.of(context).colorScheme.surface,
                  width: isSelected[index] ? 3 : 0,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Preview of note
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
          // Add empty note
          int index = await notesDB.addNote("", "");

          // Open note editor
          if (mounted) {
            await Navigator.pushNamed(
              context,
              "/note_editor",
              arguments: {"notesDB":notesDB, "note":notesDB.list[index]},
            );
          }
          isSelected = List.filled(notesDB.list.length, false, growable: true);
          setState(() {});
        },
        tooltip: "Add note",
        child: const Icon(Icons.add),
      ),
    );
  }
}
