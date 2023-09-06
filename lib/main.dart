import 'package:flutter/material.dart';
import 'package:my_notes/pages/home.dart';
import 'package:my_notes/pages/note.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      routes: {
        "/": (context) => const Home(),
        "/note":(context) => const Note(),
      },
    );
  }
}

List<List<String>> notes = [
  ["Title", "This is a note"],
  ["Another title", "this is another note"],
  ["Title12345678912345678912345", "1234567981234567891234567891234567891234"]
];