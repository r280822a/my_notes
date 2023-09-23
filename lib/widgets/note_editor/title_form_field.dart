import 'package:flutter/material.dart';
import 'package:my_notes/notes_db.dart';

class TitleFormField extends StatelessWidget {
  const TitleFormField({
    super.key,
    required this.note,
    required this.notesDB,
  });

  final Note note;
  final NotesDatabase notesDB;

  @override
  Widget build(BuildContext context) {
    // Builds TextFormField for title
    return TextFormField(
      decoration: const InputDecoration(
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),

      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 23,
      ),
      maxLines: 1,
      initialValue: note.title,
      onChanged: (value) {
        note.title = value;
        notesDB.updateNote(note);
      },
    );
  }
}