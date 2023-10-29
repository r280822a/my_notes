import 'package:flutter/material.dart';
import 'package:my_notes/utils/desc_splitter.dart';
import 'package:my_notes/utils/consts.dart';
import 'package:my_notes/widgets/note_editor/desc_form_field.dart';
import 'package:fluttertoast/fluttertoast.dart';

// DescFormField with a checkbox and button to delete itself
class DescCheckBox extends StatelessWidget {
  const DescCheckBox({
    super.key,
    required this.descSplitter,
    required this.textController,
    required this.focusNode,
    required this.index,
    required this.isTicked,
    required this.setState,
  });

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
            descSplitter.joinDescription();
            setState();
          },
        ),
        Flexible(
          child: DescFormField(
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
            descSplitter.joinDescription();

            Fluttertoast.showToast(msg: "Removed checkbox");
            setState();
          }, 
          icon: const Icon(Icons.delete_outline)
        )
      ],
    );
  }
}