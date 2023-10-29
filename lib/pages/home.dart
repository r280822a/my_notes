import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_notes/utils/notes_database.dart';
import 'package:my_notes/widgets/loading_pages/loading_home.dart';
import 'package:my_notes/widgets/delete_alert_dialog.dart';
import 'package:my_notes/widgets/frosted.dart';
import 'package:my_notes/widgets/home/note_card.dart';
import 'package:my_notes/widgets/home/notes_search_anchor.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late NotesDatabase notesDB;
  bool loading = true;

  List<bool> isSelected = []; // Check if note is selected for given index
  bool selectModeEnabled = false;

  final SearchController searchController = SearchController();

  @override
  void initState() {
    super.initState();
    getDatabase();
  }

  void getDatabase() async {
    // Open database, turns database to list
    notesDB = NotesDatabase();

    await notesDB.open();
    await notesDB.toList();

    isSelected = List.filled(notesDB.list.length, false, growable: true);
    loading = false;
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose(); // Dispose of search controller
  }

  void selectCard(index) {
    // Select card/note at given index
    isSelected[index] = !isSelected[index];
    if (isSelected.every((element) => element == false)) {
      selectModeEnabled = false;
    } else {
      selectModeEnabled = true;
    }
  }

  List<Note> getSelectedNotes() {
    // Return list of notes that are currently selected
    List<Note> selectedNotes = [];
    for (int i = 0; i < isSelected.length; i++){
      if (isSelected[i]){
        selectedNotes.add(notesDB.list[i]);
      }
    }

    return selectedNotes;
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {return const LoadingHome();}

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,

      extendBodyBehindAppBar: true,
      appBar: AppBar(
        // For frosted look
        backgroundColor: Theme.of(context).colorScheme.inversePrimary.withAlpha(190),
        scrolledUnderElevation: 0,
        flexibleSpace: Frosted(child: Container(color: Colors.transparent)),

        // Display cancel button for select mode, else search button
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
          isSelected: isSelected,
          controller: searchController,
          update: () {
            isSelected = List.filled(notesDB.list.length, false, growable: true);
            setState(() {});
          }
        ),

        // Display buttons for select mode, else local images page button
        actions: selectModeEnabled ? [
          IconButton(
            tooltip: "Swap notes",
            onPressed: () async {
              List<Note> notesToSwap = getSelectedNotes();
              // Only swap if exactly 2 selected
              if (notesToSwap.length != 2){
                Fluttertoast.showToast(
                  msg: "Swapping only works when exactly 2 notes selected",
                  toastLength: Toast.LENGTH_LONG
                );
              } else{
                int note1Index = notesDB.list.indexOf(notesToSwap[0]);
                int note2Index = notesDB.list.indexOf(notesToSwap[1]);
                await notesDB.swapNotes(note1Index, note2Index);
              }
              setState(() {});
            },
            icon: const Icon(Icons.swap_horiz_outlined)
          ),
          IconButton(
            tooltip: "Delete note(s)",
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => DeleteAlertDialog(
                  item: "note(s)",
                  deleteFunction: () async {
                    List<Note> notesToDelete = getSelectedNotes();
                    // Delete all selected notes
                    for (int i = 0; i < notesToDelete.length; i++){
                      await notesDB.deleteNote(notesToDelete[i]);
                    }
                    // Cancel selection
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
              // Open local images page
              await Navigator.pushNamed(
                context,
                "/local_image_attachments",
              );
            },
            icon: const Icon(Icons.photo_library_outlined)
          )
        ],
      ),


      body: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
        child: ReorderableGridView.builder(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          onReorder: (oldIndex, newIndex) async {
            // Reorder notes, after dragging

            // First reorder list, to update UI
            final Note noteToReorder = notesDB.list[oldIndex];
            notesDB.list.remove(noteToReorder);
            notesDB.list.insert(newIndex, noteToReorder);

            // Update selection
            isSelected.removeAt(oldIndex);
            isSelected.insert(newIndex, false);
            selectCard(newIndex);
            setState(() {});
            // Reorder database in background
            await notesDB.reorderNotesDB(noteToReorder, oldIndex, newIndex);
          },
          dragStartDelay: const Duration(milliseconds: 250),
          onDragStart: (dragIndex) {
            // Essentially activates when long pressing
            // Select note/card, if not in select mode
            if (!selectModeEnabled){
              HapticFeedback.selectionClick();
              selectCard(dragIndex);
              setState(() {});
            }
          },
          dragWidgetBuilderV2: DragWidgetBuilderV2(builder: (int index, Widget child, ImageProvider? screenshot) {
            return NoteCard(
              notesDB: notesDB,
              isSelected: isSelected,
              index: index,
              hasBorder: true,
            );
          }),

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
                // If in select mode, select note/card
                // Else, open note editor page for given note
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

              // Preview of note
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

          // Open note editor page for empty note
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
