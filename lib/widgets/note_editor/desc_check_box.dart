import 'package:flutter/material.dart';
import 'package:my_notes/notes_db.dart';
import 'package:my_notes/widgets/note_editor/desc_form_field.dart';

class DescCheckBox extends StatelessWidget {
  const DescCheckBox({
    super.key,
    required this.textControllers,
    required this.descriptionList,
    required this.note,
    required this.notesDB,
    required this.index,
    required this.initValue,
    required this.hasMultiLines,
    required this.isTicked,
    required this.selectDescCheckBox,
    required this.removeDescCheckBox,
  });

  final List<TextEditingController> textControllers;
  final List<String> descriptionList;
  final Note note;
  final NotesDatabase notesDB;
  final bool isTicked;
  final int index;
  final String initValue;
  final bool hasMultiLines;
  final Function selectDescCheckBox;
  final Function removeDescCheckBox;

  @override
  Widget build(BuildContext context) {
    // To build checkbox
    return Row(
      children: [
        Checkbox(
          value: isTicked,
          onChanged: (bool? value) {
            selectDescCheckBox(isTicked, index);
          },
        ),
        Flexible(
          child: DescFormField(
            textControllers: textControllers,
            descriptionList: descriptionList,
            note: note,
            notesDB: notesDB,
            index: index,
            initValue: initValue,
            hasMultiLines: false
          )
        ),
        IconButton(
          onPressed: () {
            removeDescCheckBox(index);
          }, 
          icon: const Icon(Icons.delete_outline)
        )
      ],
    );
  }
}