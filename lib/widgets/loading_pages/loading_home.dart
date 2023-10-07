import 'package:flutter/material.dart';

// Scaffold used as loading screen for Home page
// No buttons work
class LoadingHome extends StatelessWidget {
  const LoadingHome({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library_outlined),
            onPressed: () {},
          )
        ],
      ),

      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,

      body: GridView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: 10,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: 155,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
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
}
