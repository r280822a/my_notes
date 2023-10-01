import 'package:flutter/material.dart';
import 'package:my_notes/widgets/home/note_card.dart';
import 'package:my_notes/notes_db.dart';

class NotesSearchAnchor extends StatelessWidget {
  const NotesSearchAnchor({
    super.key,
    required this.notesDB,
    required this.controller,
    required this.isSelected,
    required this.update,
  });

  final NotesDatabase notesDB;
  final SearchController controller;
  final List<bool> isSelected;
  final Function update;

  @override
  Widget build(BuildContext context) {
    return SearchAnchor(
      // Allows you to search for a note, based on title
      searchController: controller,
      builder: (BuildContext context, SearchController controller) {
        return IconButton(
          tooltip: "Search notes",
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
                  update();
                },
                child: NoteCard(
                  notesDB: notesDB,
                  isSelected: isSelected,
                  index: i,
                ),
              )
            );
          }
        }
        return cardList;
      }
    );
  }
}