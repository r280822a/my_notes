import 'package:flutter/material.dart';
import 'package:my_notes/pages/home.dart';
import 'package:my_notes/pages/editnote.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:dynamic_color/dynamic_color.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder:(ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp(
          themeMode: ThemeMode.system,
          theme: ThemeData(
            colorScheme: lightDynamic,
            useMaterial3: true
          ),
          darkTheme: ThemeData(
            colorScheme: darkDynamic,
            useMaterial3: true
          ),
          routes: {
            "/": (context) => const Home(),
            "/note":(context) => const EditNote(),
          },
        );
      }
    );
  }
}


Scaffold loadingScreen(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: const Text("Home"),
    ),

    backgroundColor: Theme.of(context).colorScheme.surfaceVariant,

    body: MasonryGridView.count(
      padding: const EdgeInsets.all(8),
      itemCount: 10,
      crossAxisCount: 2,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      itemBuilder: (context, index) {
        return Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surface,
          child: Container(
            padding: const EdgeInsets.all(8),
            child: const SizedBox(
              height: 100,
            )
          ),
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