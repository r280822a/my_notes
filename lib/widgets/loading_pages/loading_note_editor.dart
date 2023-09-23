import 'package:flutter/material.dart';

class LoadingNoteEditor extends StatelessWidget {
  const LoadingNoteEditor({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                child: Row(
                  children: [
                    Icon(Icons.copy),
                    SizedBox(width: 10),
                    Text("Copy"),
                  ],
                )
              ),
              const PopupMenuItem(
                child: Row(
                  children: [
                    Icon(Icons.edit_note),
                    SizedBox(width: 10),
                    Text("View raw"),
                  ],
                )
              ),
              PopupMenuItem(
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red[600]),
                    const SizedBox(width: 10),
                    const Text("Delete"),
                  ],
                )
              ),
            ]
          ),
        ],
      ),


      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display note
            SizedBox(height: 35),
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
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.add_photo_alternate, size: 28),
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ],
        ),
      ),
    );
  }
}
