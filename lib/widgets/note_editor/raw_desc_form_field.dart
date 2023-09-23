import 'package:flutter/material.dart';
import 'package:my_notes/notes_db.dart';

class RawDescFormField extends StatelessWidget {
  const RawDescFormField({
    super.key,
    required this.note,
    required this.notesDB,
  });

  final Note note;
  final NotesDatabase notesDB;

  @override
  Widget build(BuildContext context) {
    // Builds TextFormField for unrendered description (mainly for testing)
    // Only affects checkboxes
    return TextFormField(
      decoration: const InputDecoration(
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),

      style: const TextStyle(
        fontWeight: FontWeight.normal,
        fontSize: 16,
      ),
      maxLines: null,
      initialValue: note.description,
      onChanged: (value) {
        note.description = value;
        notesDB.updateNote(note);
      },
    );
  }
}