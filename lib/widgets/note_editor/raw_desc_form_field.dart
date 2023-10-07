import 'package:flutter/material.dart';
import 'package:my_notes/notes_database.dart';

class RawDescFormField extends StatelessWidget {
  const RawDescFormField({
    super.key,
    required this.note,
    required this.notesDB,
    required this.textController,
    required this.focusNode
  });

  final Note note;
  final NotesDatabase notesDB;
  final TextEditingController textController;
  final FocusNode focusNode;

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
      focusNode: focusNode,

      onChanged: (value) {
        note.description = value;
        notesDB.updateNote(note);
      },
    );
  }
}