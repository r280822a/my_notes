import 'package:flutter/material.dart';
import 'package:my_notes/notes_db.dart';

class RawDescFormField extends StatelessWidget {
  const RawDescFormField({
    super.key,
    required this.note,
    required this.notesDB,
    required this.textController,
  });

  final Note note;
  final NotesDatabase notesDB;
  final TextEditingController textController;

  @override
  Widget build(BuildContext context) {
    // TextFormField for unrendered description (mainly for testing)
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
      controller: textController,

      onChanged: (value) {
        note.description = value;
        notesDB.updateNote(note);
      },
    );
  }
}