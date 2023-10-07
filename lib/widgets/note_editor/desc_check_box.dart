import 'package:flutter/material.dart';
import 'package:my_notes/notes_database.dart';
import 'package:my_notes/desc_splitter.dart';
import 'package:my_notes/consts.dart';
import 'package:my_notes/widgets/note_editor/desc_form_field.dart';

// DescFormField with a checkbox and button to delete itself
class DescCheckBox extends StatelessWidget {
  const DescCheckBox({
    super.key,
    required this.note,
    required this.notesDB,
    required this.descSplitter,
    required this.textController,
    required this.focusNode,
    required this.index,
    required this.isTicked,
    required this.setState,
  });

  final Note note;
  final NotesDatabase notesDB;
  final DescSplitter descSplitter;
  final TextEditingController textController;
  final FocusNode focusNode;
  final int index;
  final bool isTicked;
  final Function setState;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: isTicked,
          onChanged: (bool? value) {
            // Ticks/Unticks checkbox

            // Symbol to put at start
            String symbol = Consts.checkboxTickedStr;
            if (isTicked){
              symbol = Consts.checkboxStr;
            }

            // Change checkbox symbol
            descSplitter.list[index] = symbol + descSplitter.list[index].substring(2);

            // Update note
            String newDescription = descSplitter.list.join("\n");
            note.description = newDescription;
            notesDB.updateNote(note);
            setState();
          },
        ),
        Flexible(
          child: DescFormField(
            note: note,
            notesDB: notesDB,
            descSplitter: descSplitter,
            textController: textController,
            focusNode: focusNode,
            index: index,
          )
        ),
        IconButton(
          tooltip: "Remove checkbox",
          onPressed: () {
            // Remove checkbox
            descSplitter.list.removeAt(index);
            String newDescription = descSplitter.list.join("\n");
            note.description = newDescription;
            notesDB.updateNote(note);
            setState();
          }, 
          icon: const Icon(Icons.delete_outline)
        )
      ],
    );
  }
}