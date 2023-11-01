import 'package:flutter/material.dart';

// Scaffold used as loading screen for LocalImages page
// Also used if no local images stored
// No buttons work
class LoadingLocalImages extends StatelessWidget {
  const LoadingLocalImages({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Local Image Attachments"),
        titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onBackground,
          fontWeight: FontWeight.bold,
          fontSize: 23,
        ),
      ),

      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library,
              size: 150
            ),
            Text(
              "No images",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              "Local images attached to notes will appear here",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}