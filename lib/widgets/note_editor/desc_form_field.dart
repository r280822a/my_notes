import 'package:flutter/material.dart';
import 'package:my_notes/notes_database.dart';
import 'package:my_notes/desc_splitter.dart';
import 'package:my_notes/consts.dart';

// TextFormField that displays/edits rendered description
class DescFormField extends StatelessWidget {
  const DescFormField({
    super.key,
    required this.note,
    required this.notesDB,
    required this.descSplitter,
    required this.index,
    required this.textController,
    required this.focusNode,
  });

  final Note note;
  final NotesDatabase notesDB;
  final DescSplitter descSplitter;
  final int index;
  final TextEditingController textController;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: const InputDecoration(
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),

      key: Key(textController.text.toString() + index.toString()),
      maxLines: null,
      controller: textController,
      focusNode: focusNode,

      onChanged: (value) {
        // Update textblock, when changed

        int cbIndex = descSplitter.list[index].indexOf(Consts.checkboxStr);
        int cbTickedIndex = descSplitter.list[index].indexOf(Consts.checkboxTickedStr);

        if (cbIndex == 0) {
          value = "${Consts.checkboxStr}$value";
        } else if (cbTickedIndex == 0){
          value = "${Consts.checkboxTickedStr}$value";
        }
        descSplitter.list[index] = value;
        String newDescription = descSplitter.list.join("\n");

        note.description = newDescription;
        notesDB.updateNote(note);
      },
    );
  }
}
