import 'package:flutter/material.dart';

// AlertDialog for displaying errors
class ErrorAlertDialog extends StatelessWidget {
  const ErrorAlertDialog({
    super.key,
    required this.exception
  });

  final Exception exception;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Error occured",
        style: TextStyle(fontWeight: FontWeight.bold)
      ),
      content: Text(
        exception.toString(),
        style: const TextStyle(fontSize: 16)
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            "Ok",
            style: TextStyle(fontSize: 16)
          )
        ),
      ]
    );
  }
}