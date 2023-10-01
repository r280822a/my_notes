import 'package:flutter/material.dart';

class DescFormField extends StatelessWidget {
  const DescFormField({
    super.key,
    required this.textController,
    required this.index,
    required this.initValue,
    required this.updateDescFormField,
  });

  final TextEditingController textController;
  final int index;
  final String initValue;
  final Function updateDescFormField;

  @override
  Widget build(BuildContext context) {
    // TextFormField for textblock (and checkbox)
    return TextFormField(
      decoration: const InputDecoration(
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),

      key: Key(initValue.toString() + index.toString()),
      maxLines: null,
      controller: textController,

      onChanged: (value) {
        updateDescFormField(index, value);
      },
    );
  }
}
