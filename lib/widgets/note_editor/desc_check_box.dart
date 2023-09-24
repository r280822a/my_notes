import 'package:flutter/material.dart';
import 'package:my_notes/widgets/note_editor/desc_form_field.dart';

class DescCheckBox extends StatelessWidget {
  const DescCheckBox({
    super.key,
    required this.textControllers,
    required this.index,
    required this.initValue,
    required this.hasMultiLines,
    required this.updateDescFormField,
    required this.isTicked,
    required this.selectDescCheckBox,
    required this.removeDescCheckBox,
  });

  final List<TextEditingController> textControllers;
  final int index;
  final String initValue;
  final bool hasMultiLines;
  final Function updateDescFormField;
  final bool isTicked;
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
            updateDescFormField: updateDescFormField,
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