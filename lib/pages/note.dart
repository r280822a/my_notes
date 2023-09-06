import 'package:flutter/material.dart';
import 'package:my_notes/main.dart';

class Note extends StatefulWidget {
  const Note({super.key});

  @override
  State<Note> createState() => _NoteState();
}

class _NoteState extends State<Note> {
  TextFormField textFormBuilder(int index, bool isTitle){
    return TextFormField(
      style: TextStyle(
        fontWeight: isTitle ? FontWeight.bold : FontWeight.normal,
        fontSize: isTitle ? 25 : 20,
      ),
      maxLines: isTitle ? 1 : null,
      decoration: const InputDecoration(
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),
      initialValue: notes[index][isTitle ? 0 : 1],
      onChanged: (value) {
        notes[index][isTitle ? 0 : 1] = value;
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    int index = ModalRoute.of(context)!.settings.arguments as int;

    return Scaffold(
      appBar: AppBar(),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            textFormBuilder(index, true),
            const Divider(),
            Expanded(
              child: textFormBuilder(index, false),
            ),
          ],
        ),
      ),
    );
  }
}
