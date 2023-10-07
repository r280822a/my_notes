import 'package:flutter/material.dart';

// Scaffold used as loading screen for NoteEditor page
class LoadingNoteEditor extends StatelessWidget {
  const LoadingNoteEditor({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert)
          )
        ]
      ),


      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 15),
            Divider(),
          ],
        ),
      ),


      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Material(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.add_box_outlined),
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.add_photo_alternate_outlined),
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ],
        ),
      ),
    );
  }
}
