import 'package:flutter/material.dart';
import 'package:my_notes/notes_db.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class NoteEditor extends StatefulWidget {
  const NoteEditor({super.key});

  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  TextFormField textFormBuilder(Note note, NotesDatabase notesDB, bool isTitle){
    // To edit title/description
    return TextFormField(
      decoration: const InputDecoration(
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),

      style: TextStyle(
        fontWeight: isTitle ? FontWeight.bold : FontWeight.normal,
        fontSize: isTitle ? 23 : 16,
      ),
      maxLines: isTitle ? 1 : null,
      initialValue: isTitle ? note.title : note.description,
      onChanged: (value) {
        isTitle ? note.title = value : note.description = value;
        notesDB.updateNote(note);
      },
    );
  }

  bool value = false;

  TextFormField _textFormField(String initValue, bool hasMultiLines) {
    return TextFormField(
      decoration: const InputDecoration(
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),

      initialValue: initValue,
      maxLines: hasMultiLines ? null : 1,
    );
  }

  Widget renderer(String text) {
    List<Widget> renderedText = [];

    List<String> lineSplitText = const LineSplitter().convert(text);
    List<String> textBuffer = [];

    bool endsInCheckbox = false;

    if ((lineSplitText.isEmpty) || (lineSplitText.length == 1)){
      return Expanded(
        child: _textFormField(text, true),
      );
    }

    for (String line in lineSplitText){
      int cbIndex = line.indexOf("cb:");

      if (cbIndex != -1){
        if (textBuffer.isNotEmpty){
          String join = textBuffer.join("\n");
          renderedText.add(_textFormField(join, true));
          textBuffer = [];
        }

        renderedText.add(
          Row(
            children: [
              Checkbox(
                value: value,
                onChanged: (bool? value) {
                  setState(() {
                    this.value = !this.value;
                  });
                },
              ),
              Flexible(
                child: _textFormField(line.substring(3), false)
              ),
            ],
          )
        );
        endsInCheckbox = true;
      } else {
        textBuffer.add(line);
        endsInCheckbox = false;
      }
    }


    if ((textBuffer.isNotEmpty) || (endsInCheckbox)){
      String value = "";
      if (textBuffer.isNotEmpty){
        value = textBuffer.join("\n");
      }
      renderedText.add(
        Expanded(
          child: _textFormField(value, true)
        ),
      );
      if (textBuffer.isNotEmpty){
        textBuffer = [];
      }
    }

    return Expanded(
      child: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: renderedText,
            ),
          )
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    // Retrieve arguements from previous page
    Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    Note note = arguments["note"];
    NotesDatabase notesDB = arguments["notesDB"];

    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(note.time);
    String time = DateFormat('dd MMMM yyyy - hh:mm').format(dateTime);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              // Deletes note
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
            // Display note
            textFormBuilder(note, notesDB, true),
            const Divider(),
            Text(
              time,
              style: TextStyle(color: Theme.of(context).unselectedWidgetColor),
            ),
            const SizedBox(height: 10),
            renderer(note.description),
            // Expanded(
            //   child: textFormBuilder(note, notesDB, false),
            // ),
          ],
        ),
      ),
    );
  }
}
