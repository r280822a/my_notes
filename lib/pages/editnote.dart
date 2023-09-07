import 'package:flutter/material.dart';
import 'package:my_notes/notes_db.dart';

class EditNote extends StatefulWidget {
  const EditNote({super.key});

  @override
  State<EditNote> createState() => _EditNoteState();
}

class _EditNoteState extends State<EditNote> {
  TextFormField textFormBuilder(Note note, NotesDatabase notesDB, bool isTitle){
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
        isTitle ? note.title = value : note.description = value;
        notesDB.updateNote(note);
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    Map result = ModalRoute.of(context)!.settings.arguments as Map;
    Note note = result["note"];
    NotesDatabase notesDB = result["notesDB"];

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              await notesDB.deleteNote(note);
              if (mounted){
                Navigator.pop(context);
              }
            }, 
            icon: const Icon(Icons.delete_outline_outlined)
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            textFormBuilder(note, notesDB, true),
            const Divider(),
            Text(
              note.time,
              style: const TextStyle(color: Colors.black54),
            ),
            Expanded(
              child: textFormBuilder(note, notesDB, false),
            ),
          ],
        ),
      ),
    );
  }
}
