import 'package:flutter/material.dart';
import 'package:my_notes/notes_db.dart';
import 'package:my_notes/pages/note_editor.dart';

class DescFormField extends StatelessWidget {
  const DescFormField({
    super.key,
    required this.textControllers,
    required this.descriptionList,
    required this.note,
    required this.notesDB,
    required this.index,
    required this.initValue,
    required this.hasMultiLines,
  });

  final List<TextEditingController> textControllers;
  final List<String> descriptionList;
  final Note note;
  final NotesDatabase notesDB;
  final int index;
  final String initValue;
  final bool hasMultiLines;

  @override
  Widget build(BuildContext context) {
    // Builds TextFormField for each textblock and checkbox
    return TextFormField(
      decoration: const InputDecoration(
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),

      key: Key(initValue.toString() + index.toString()),
      maxLines: hasMultiLines ? null : 1,
      controller: textControllers[index],

      onChanged: (value) {
        int cbIndex = descriptionList[index].indexOf(checkboxStr);
        int cbTickedIndex = descriptionList[index].indexOf(checkboxTickedStr);

        if (cbIndex == 0) {
          value = "$checkboxStr$value";
        } else if (cbTickedIndex == 0){
          value = "$checkboxTickedStr$value";
        }
        descriptionList[index] = value;
        String newDescription = descriptionList.join("\n");

        note.description = newDescription;
        notesDB.updateNote(note);
      },
    );
  }
}
