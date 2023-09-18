
import 'package:flutter/material.dart';
import 'package:my_notes/notes_db.dart';
import 'package:intl/intl.dart';
// import 'dart:convert';

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


  bool value = false; // TEMPORARY

  late Note note;
  late NotesDatabase notesDB;
  List<String> descriptionList = [];
  List<TextEditingController> textControllers = [];
  // TextEditingController textController = TextEditingController();

  TextFormField _textFormField(int index, String initValue, bool hasMultiLines) {
    return TextFormField(
      decoration: const InputDecoration(
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),

      key: Key(initValue.toString() + index.toString()),
      // initialValue: initValue,
      maxLines: hasMultiLines ? null : 1,
      controller: textControllers[index],

      onChanged: (value) {
        int cbIndex = descriptionList[index].indexOf("▢ ");
        if (cbIndex == 0) {
          value = "▢ $value";
        }
        descriptionList[index] = value;
        String newDescription = descriptionList.join("\n");

        note.description = newDescription;
        notesDB.updateNote(note);
      },
    );
  }

  Row _checkBox(String line, int index, String initValue, bool hasMultiLines){
    return Row(
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
          child: _textFormField((descriptionList.length - 1), line.substring(2), false)
        ),
        IconButton(
          onPressed: () {
            descriptionList.removeAt(index);
            String newDescription = descriptionList.join("\n");
            note.description = newDescription;
            notesDB.updateNote(note);

            setState(() {});
          }, 
          icon: const Icon(Icons.delete_outline)
        )
      ],
    );
  }

  Widget renderer() {
    descriptionList.clear();
    textControllers.clear();

    List<Widget> renderedText = [];
    String description = note.description;

    // List<String> lineSplitText = const LineSplitter().convert(description);
    List<String> lineSplitText = description.split("\n");
    List<String> textBuffer = [];

    bool endsInCheckbox = false;

    if ((lineSplitText.isEmpty) || (lineSplitText.length == 1)){
      descriptionList.add(description);
      textControllers.add(TextEditingController(text: description));
      return Expanded(
        child: _textFormField((descriptionList.length - 1), description, true),
      );
    }

    for (String line in lineSplitText){
      int cbIndex = line.indexOf("▢ ");

      if (cbIndex == 0){
        if (textBuffer.isNotEmpty){
          String join = textBuffer.join("\n");
          descriptionList.add(join);
          textControllers.add(TextEditingController(text: join));
          renderedText.add(_textFormField((descriptionList.length - 1), join, true));
          textBuffer = [];
        }

        descriptionList.add(line);
        textControllers.add(TextEditingController(text: line.substring(2)));
        renderedText.add(_checkBox(
          line, 
          (descriptionList.length - 1), 
          line.substring(2), 
          false
        ));
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

      descriptionList.add(value);
      textControllers.add(TextEditingController(text: value));
      renderedText.add(
        Expanded(
          child: _textFormField((descriptionList.length - 1), value, true)
        ),
      );
    }

    renderedText.add(
      const SizedBox(height: 60),
    );

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
    note = arguments["note"];
    notesDB = arguments["notesDB"];

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
            icon: const Icon(Icons.delete_outline),
            color: Colors.red[600],
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
            renderer(),
            // Expanded(
            //   child: textFormBuilder(note, notesDB, false),
            // ),
            // const SizedBox(height: 60),
          ],
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      floatingActionButton: Material(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: IconButton(
                onPressed: () {
                  // Default offset and index are at end
                  int descIndex = (descriptionList.length - 1);
                  int offset = descriptionList[descIndex].length;

                  // Find currently selected text controller
                  // Store its index and offset
                  for (int i = 0; i < textControllers.length; i++){
                    final int baseOffset = textControllers[i].selection.baseOffset;
                    if (baseOffset != -1){
                      descIndex = i;
                      offset = baseOffset;
                    }
                  }

                  // Split text from start till index 
                  // To find which line to add checkbox (at substringSplit.length)
                  String substring = descriptionList[descIndex].substring(0, offset);
                  List<String> substringSplit = substring.split("\n");

                  // Add checkbox
                  List<String> textSplit = descriptionList[descIndex].split("\n");
                  textSplit.insert(substringSplit.length, "▢ ");
                  descriptionList[descIndex] = textSplit.join("\n");

                  // Update note
                  String newDescription = descriptionList.join("\n");
                  note.description = newDescription;
                  notesDB.updateNote(note);

                  setState(() {});
                },
                icon: const Icon(Icons.add_box_outlined),
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
