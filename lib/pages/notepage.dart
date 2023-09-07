import 'package:flutter/material.dart';
import 'package:my_notes/notes_db.dart';

class NotePage extends StatefulWidget {
  const NotePage({super.key});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  TextFormField textFormBuilder(Note note, NotesDatabase notesClass, bool isTitle){
    return TextFormField(
      style: TextStyle(
        fontWeight: isTitle ? FontWeight.bold : FontWeight.normal,
        fontSize: isTitle ? 23 : 16,
      ),
      maxLines: isTitle ? 1 : null,
      decoration: const InputDecoration(
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),
      initialValue: isTitle ? note.title : note.description,
      onChanged: (value) {
        isTitle ? note.title : note.description = value;
        notesClass.updateNote(note);
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    Map result = ModalRoute.of(context)!.settings.arguments as Map;
    Note note = result["note"];
    NotesDatabase notesClass = result["notesClass"];

    return Scaffold(
      appBar: AppBar(),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            textFormBuilder(note, notesClass, true),
            const Divider(),
            Expanded(
              child: textFormBuilder(note, notesClass, false),
            ),
          ],
        ),
      ),
    );
  }
}
