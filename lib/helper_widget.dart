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