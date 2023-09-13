import 'package:flutter/material.dart';
import 'package:my_notes/pages/home.dart';
import 'package:my_notes/pages/note_editor.dart';
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
          // Uses dynamic colors, follows system theme
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
            "/note_editor":(context) => const NoteEditor(),
          },
        );
      }
    );
  }
}

// [Temporarily in main.dart]
Scaffold loadingScreen(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: const Text("Home"),
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