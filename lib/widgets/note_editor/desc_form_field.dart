import 'package:flutter/material.dart';
import 'package:my_notes/utils/desc_splitter.dart';
import 'package:my_notes/utils/common.dart';

// TextFormField that displays/edits rendered description
class DescFormField extends StatelessWidget {
  const DescFormField({
    super.key,
    required this.descSplitter,
    required this.index,
    required this.textController,
    required this.focusNode,
  });

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

        // Adds checkbox symbol if checkbox
        int cbIndex = descSplitter.list[index].indexOf(Common.checkboxStr);
        int cbTickedIndex = descSplitter.list[index].indexOf(Common.checkboxTickedStr);
        if (cbIndex == 0) {
          value = "${Common.checkboxStr}$value";
        } else if (cbTickedIndex == 0){
          value = "${Common.checkboxTickedStr}$value";
        }
        
        // Update note
        descSplitter.list[index] = value;
        descSplitter.joinDescription();
      },
    );
  }
}
