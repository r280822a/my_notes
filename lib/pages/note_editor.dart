import 'package:flutter/material.dart';
import 'package:my_notes/notes_db.dart';
import 'package:intl/intl.dart';

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
  
  final String checkboxStr = "▢ ";

  // For each TextFormField
  List<String> descriptionList = []; // Seperate item for each textblock and checkbox
  List<TextEditingController> textControllers = [];

  TextFormField _textFormField(int index, String initValue, bool hasMultiLines) {
    // Builds TextFormField for each textblock and checkbox
    return TextFormField(
      decoration: const InputDecoration(
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),

      key: Key(initValue.toString() + index.toString()),
      maxLines: hasMultiLines ? null : 1,
      controller: textControllers[index],

      onChanged: (value) {
        int cbIndex = descriptionList[index].indexOf(checkboxStr);
        if (cbIndex == 0) {
          value = "$checkboxStr$value";
        }
        descriptionList[index] = value;
        String newDescription = descriptionList.join("\n");

        note.description = newDescription;
        notesDB.updateNote(note);
      },
    );
  }

  Row _checkBox(int index, String initValue, bool hasMultiLines){
    // To build checkbox
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: (bool? value) {
            // Select checkbox
            setState(() {
              this.value = !this.value;
            });
          },
        ),
        Flexible(
          child: _textFormField((descriptionList.length - 1), initValue, false)
        ),
        IconButton(
          onPressed: () {
            // Remove checkbox
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
    // Renders any checkboxes

    // Clear before rendering
    descriptionList.clear();
    textControllers.clear();

    // List of textformfields and checkboxes for description
    List<Widget> renderedText = [];
    String description = note.description;

    // List<String> lineSplitText = const LineSplitter().convert(description);
    List<String> lineSplitText = description.split("\n");

    if ((lineSplitText.isEmpty) || (lineSplitText.length == 1)){
      // If only 1 line or blank

      // Add text to lists
      descriptionList.add(description);
      textControllers.add(TextEditingController(text: description));
      return Expanded(
        child: _textFormField((descriptionList.length - 1), description, true),
      );
    }

    List<String> textBuffer = [];
    bool endsInCheckbox = false;
    for (String line in lineSplitText){
      // Render line by line
      int cbIndex = line.indexOf(checkboxStr);

      if (cbIndex == 0){
        // If line is a checkbox
        if (textBuffer.isNotEmpty && !(textBuffer.every((element) => element == ""))){
          // If any text in text buffer
          // Join together to form 1 textblock
          String join = textBuffer.join("\n");

          // Add textblock to lists
          descriptionList.add(join);
          textControllers.add(TextEditingController(text: join));
          renderedText.add(_textFormField((descriptionList.length - 1), join, true));
          textBuffer = []; // Reset buffer
        }

        // Add checkbox to lists
        descriptionList.add(line);
        textControllers.add(TextEditingController(text: line.substring(2)));
        renderedText.add(_checkBox(
          (descriptionList.length - 1), 
          line.substring(2), 
          false
        ));
        endsInCheckbox = true;
      } else {
        // If not, add line to buffer
        textBuffer.add(line);
        endsInCheckbox = false;
      }
    }


    if ((textBuffer.isNotEmpty) || (endsInCheckbox)){
      String value = ""; // Blank line if ends in checkbox
      if (textBuffer.isNotEmpty){
        // If any text in text buffer
        // Join together to form 1 textblock
        value = textBuffer.join("\n");
      }

      // Add textblock to lists
      descriptionList.add(value);
      textControllers.add(TextEditingController(text: value));
      renderedText.add(
        Expanded(
          child: _textFormField((descriptionList.length - 1), value, true)
        ),
      );
    }


    // To give space for floatingactionbutton
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
    // Set attributes
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
                  // Adds checkbox

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

                  // Add checkbox string
                  List<String> textSplit = descriptionList[descIndex].split("\n");
                  textSplit.insert(substringSplit.length, checkboxStr);
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
