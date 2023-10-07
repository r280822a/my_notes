import 'package:flutter/material.dart';

// AlertDialog for deleting something
class DeleteAlertDialog extends StatelessWidget {
  const DeleteAlertDialog({
    super.key,
    required this.item,
    required this.deleteFunction,
  });

  final String item;
  final Function deleteFunction;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Are you sure?",
        style: TextStyle(fontWeight: FontWeight.bold)
      ),
      content: Text(
        "Are you sure you want to delete this $item? This cannot be undone",
        style: const TextStyle(fontSize: 16)
      ),
      actions: [
        TextButton(
          onPressed: () {
            deleteFunction();
            Navigator.pop(context);
          },
          child: Text(
            "Yes",
            style: TextStyle(
              fontSize: 16,
              color: Colors.red[600]
            )
          )
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            "No",
            style: TextStyle(fontSize: 16)
          ),
        )
      ],
    );
  }
}