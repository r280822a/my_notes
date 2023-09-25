import 'package:flutter/material.dart';

class DescFormField extends StatelessWidget {
  const DescFormField({
    super.key,
    required this.textControllers,
    required this.index,
    required this.initValue,
    required this.updateDescFormField,
  });

  final List<TextEditingController> textControllers;
  final int index;
  final String initValue;
  final Function updateDescFormField;

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
      maxLines: null,
      controller: textControllers[index],

      onChanged: (value) {
        updateDescFormField(index, value);
      },
    );
  }
}
