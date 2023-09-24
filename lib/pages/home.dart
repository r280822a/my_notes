import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_notes/notes_db.dart';
import 'package:my_notes/widgets/loading_pages/loading_home.dart';
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


  Card buildCard(int index, bool isDragBuilder){
    // Builds card for a given note
    final Note note = notesDB.list[index];

    BorderSide borderSide = BorderSide(
      // If selected, add border
      color: isSelected[index] ? Theme.of(context).colorScheme.outline : Theme.of(context).colorScheme.surface,
      width: isSelected[index] ? 3 : 0,
    );

    if (isDragBuilder) {
      // Always add border if called from drag widget builder
      borderSide = BorderSide(
        color: Theme.of(context).colorScheme.outline,
        width: 3,
      );
    }

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: borderSide,
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
              maxLines: 4,
              style: TextStyle(
                color: Theme.of(context).unselectedWidgetColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {return const LoadingHome();}

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        // Display cancel button for select mode, else display search
        leading: selectModeEnabled ? IconButton(
          onPressed: () {
            // Close select mode, set all items in isSelected to false
            isSelected = List.filled(isSelected.length, false, growable: true);
            selectModeEnabled = false;
            setState(() {});
          },
          icon: const Icon(Icons.close)
        ) : SearchAnchor(
          // Allows you to search for a note, based on title
          searchController: controller,
          builder: (BuildContext context, SearchController controller) {
            return IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {controller.openView();},
            );
          },
          viewBuilder: (Iterable<Widget> iterable) {
            // Builds general layout
            return GridView(
              // Same layout as body
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 155,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),

              children: iterable.toList(),
            );
          },

          suggestionsBuilder: 
          (BuildContext context, SearchController controller) {
            // Builds search results
            if (controller.text.isEmpty){return [];}

            List<Widget> cardList = [];

            for (int i = 0; i < notesDB.list.length; i++){
              if (notesDB.list[i].title.toLowerCase().contains(controller.text.toLowerCase())){
                // If note title typed in text field, add card
                cardList.add(
                  GestureDetector(
                    onTap: () async {
                      // Open note editor
                      await Navigator.pushNamed(
                        context,
                        "/note_editor",
                        arguments: {"notesDB":notesDB, "note":notesDB.list[i]},
                      );
                      // Update in case note deleted
                      isSelected = List.filled(notesDB.list.length, false, growable: true);
                      setState(() {});
                    },
                    child: buildCard(i, false)
                  )
                );
              }
            }
            return cardList;
          }
        ),

        // Display buttons for select mode, else nothing
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
            icon: const Icon(Icons.delete_outline),
            color: Colors.red[600],
          )
        ] : [
          IconButton(
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


      body: ReorderableGridView.builder(
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
          return buildCard(index, true);
        }),

        padding: const EdgeInsets.all(8),
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

            child: buildCard(index, false),
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
