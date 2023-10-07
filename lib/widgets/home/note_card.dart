import 'package:flutter/material.dart';
import 'package:my_notes/notes_database.dart';

class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.notesDB,
    required this.isSelected,
    required this.index,
    this.border = false,
  });

  final NotesDatabase notesDB;
  final List<bool> isSelected;
  final int index;
  final bool border;

  @override
  Widget build(BuildContext context) {
    final Note note = notesDB.list[index];

    BorderSide borderSide = BorderSide(
      // If selected, add border
      color: isSelected[index] ? Theme.of(context).colorScheme.outline : Theme.of(context).colorScheme.surface,
      width: 3,
    );

    if (border) {
      // Always add border
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
}
