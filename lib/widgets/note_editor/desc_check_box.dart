import 'package:flutter/material.dart';
import 'package:my_notes/widgets/note_editor/desc_form_field.dart';

class DescCheckBox extends StatelessWidget {
  const DescCheckBox({
    super.key,
    required this.textController,
    required this.index,
    required this.initValue,
    required this.updateDescFormField,
    required this.isTicked,
    required this.selectDescCheckBox,
    required this.removeDescCheckBox,
  });

  final TextEditingController textController;
  final int index;
  final String initValue;
  final Function updateDescFormField;
  final bool isTicked;
  final Function selectDescCheckBox;
  final Function removeDescCheckBox;

  @override
  Widget build(BuildContext context) {
    // Checkbox with TextFormField and delete button
    return Row(
      children: [
        Checkbox(
          value: isTicked,
          onChanged: (bool? value) {
            selectDescCheckBox(index, isTicked);
          },
        ),
        Flexible(
          child: DescFormField(
            textController: textController,
            updateDescFormField: updateDescFormField,
            index: index,
            initValue: initValue,
          )
        ),
        IconButton(
          tooltip: "Delete checkbox",
          onPressed: () {
            removeDescCheckBox(index);
          }, 
          icon: const Icon(Icons.delete_outline)
        )
      ],
    );
  }
}