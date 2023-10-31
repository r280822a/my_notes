import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ErrorAlertDialog extends StatelessWidget {
  const ErrorAlertDialog({
    super.key,
    required this.platformException
  });

  final PlatformException platformException;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Error occured",
        style: TextStyle(fontWeight: FontWeight.bold)
      ),
      content: Text(
        platformException.toString(),
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