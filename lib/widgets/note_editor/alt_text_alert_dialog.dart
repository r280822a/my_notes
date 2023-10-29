import 'package:flutter/material.dart';
import 'package:my_notes/utils/desc_splitter.dart';

// AlertDialog to alt text to given image
class AltTextAlertDialog extends StatelessWidget {
  const AltTextAlertDialog({
    super.key,
    required this.textFieldController,
    required this.descSplitter,
    required this.index,
    required this.setState,
  });

  final TextEditingController textFieldController;
  final DescSplitter descSplitter;
  final int index;
  final Function setState;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // Let user add alt text
      title: const Text("Enter alt text below"),
      content: Wrap(
        children: [
          const Text(
            "Alt text appears when long pressing image (like a tooltip)\n",
            style: TextStyle(fontSize: 16)
          ),
          TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              label: Text("Alt text"),
            ),
            controller: textFieldController,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Removes '()', and everything inside
            String altText = descSplitter.list[index].replaceAll(RegExp(r'\(.*?\)'), "");
            altText = altText.substring(2, altText.length - 1);

            descSplitter.list[index] = descSplitter.list[index].replaceFirst(
              "[$altText]", "[${textFieldController.text}]");
            descSplitter.joinDescription();
            setState();
            Navigator.pop(context);
          },
          child: const Text("Ok")
        )
      ],
    );
  }
}