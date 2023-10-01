import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_notes/notes_db.dart';
import 'package:my_notes/widgets/loading_pages/loading_home.dart';
import 'package:my_notes/widgets/delete_alert_dialog.dart';
import 'package:my_notes/widgets/frosted.dart';
import 'package:my_notes/widgets/home/note_card.dart';
import 'package:my_notes/widgets/home/notes_search_anchor.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late NotesDatabase notesDB;
  bool loading = true;

  // List to see if note is selected for given index
  List<bool> isSelected = [];
  bool selectModeEnabled = false;

  final SearchController controller = SearchController();

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
    if (loading) {return const LoadingHome();}

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary.withAlpha(190),
        scrolledUnderElevation: 0,
        flexibleSpace: Frosted(child: Container(color: Colors.transparent)),

        // Display cancel button for select mode, else display search
        leading: selectModeEnabled ? IconButton(
          tooltip: "Cancel selection",
          onPressed: () {
            // Close select mode, set all items in isSelected to false
            isSelected = List.filled(isSelected.length, false, growable: true);
            selectModeEnabled = false;
            setState(() {});
          },
          icon: const Icon(Icons.close)
        ) : NotesSearchAnchor(
          notesDB: notesDB,
          controller: controller,
          isSelected: isSelected,
          update: () {
            // Update in case note deleted
            isSelected = List.filled(notesDB.list.length, false, growable: true);
            setState(() {});
          }
        ),
      
        // Display buttons for select mode, else nothing
        actions: selectModeEnabled ? [
          IconButton(
            tooltip: "Swap notes",
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
            tooltip: "Delete notes",
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => DeleteAlertDialog(
                  item: "note(s)",
                  deleteFunction: () async {
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
                  }
                )
              );
            }, 
            icon: const Icon(Icons.delete_outline),
            color: Colors.red[600],
          )
        ] : [
          IconButton(
            tooltip: "View local image attachments",
            onPressed: () async {
              await Navigator.pushNamed(
                context,
                "/local_image_attachments",
              );
            },
            icon: const Icon(Icons.photo_library_outlined)
          )
        ],
      ),


      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,


      body: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
        child: ReorderableGridView.builder(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          onReorder: (oldIndex, newIndex) async {
            final Note noteToReorder = notesDB.list[oldIndex];
            await notesDB.deleteNote(noteToReorder);
            await notesDB.insertNote(noteToReorder, newIndex);
            // final element = notesDB.list.removeAt(oldIndex);
            // notesDB.list.insert(newIndex, element);
      
            isSelected.removeAt(oldIndex);
            isSelected.insert(newIndex, false);
            selectCard(newIndex);
            setState(() {});
          },
          dragStartDelay: const Duration(milliseconds: 250),
          onDragStart: (dragIndex) {
            if (!selectModeEnabled){
              HapticFeedback.selectionClick();
              selectCard(dragIndex);
            }
            setState(() {});
          },
          dragWidgetBuilderV2: DragWidgetBuilderV2(builder: (int index, Widget child, ImageProvider? screenshot) {
            return NoteCard(
              notesDB: notesDB,
              isSelected: isSelected,
              index: index,
              autoSelect: false
            );
          }),
      
          // padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: 155,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
      
      
          itemCount: notesDB.list.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              key: Key(notesDB.list.elementAt(index).id.toString()),
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

              child: NoteCard(
                notesDB: notesDB,
                isSelected: isSelected,
                index: index,
              ),
            );
          },
        ),
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
