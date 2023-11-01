import 'package:flutter/material.dart';
import 'package:my_notes/pages/home.dart';
import 'package:my_notes/pages/note_editor.dart';
import 'package:my_notes/pages/local_images.dart';
import 'package:my_notes/pages/settings.dart';
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
            "/local_image_attachments":(context) => const LocalImages(),
            "/settings":(context) => const Settings(),
          },
        );
      }
    );
  }
}
