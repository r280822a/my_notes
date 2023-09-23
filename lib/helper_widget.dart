import 'package:flutter/material.dart';

Scaffold loadingHomeScreen(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      leading: IconButton(
        icon: const Icon(Icons.search),
        onPressed: () {},
      ),
    ),

    backgroundColor: Theme.of(context).colorScheme.surfaceVariant,

    body: GridView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: 10,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        mainAxisExtent: 150,
      ),
      itemBuilder: (context, index) {
        return Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surface,
          child: Container(),
        );
      },
    ),

    floatingActionButton: FloatingActionButton(
      onPressed: () {},
      tooltip: 'Add note',
      child: const Icon(Icons.add),
    ),
  );
}

Scaffold loadingNoteEditorScreen(BuildContext context){
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


SizedBox roundedSquare(double size, Widget child, BuildContext context) {
  return SizedBox(
    // Progress indicator inside square with rounded edges
    height: size,
    width: size,
    child: Stack(
      children: <Widget>[
        Center(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: const BorderRadius.all(Radius.circular(20))
            ),
            child: SizedBox(height: size, width: size)
          ),
        ),
        Center(child: child),
      ],
    ),
  );
}