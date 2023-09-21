import 'package:flutter/material.dart';
import 'package:my_notes/notes_db.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:my_notes/helper_widget.dart';

class NoteEditor extends StatefulWidget {
  const NoteEditor({super.key});

  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  late Note note;
  late NotesDatabase notesDB;
  
  // Checkbox symbols
  final String checkboxStr = "☐ ";
  final String checkboxTickedStr = "☑ ";

  // For each _textFormField
  List<String> descriptionList = []; // Seperate item for each textblock and checkbox
  List<TextEditingController> textControllers = [];

  bool displayRaw = false;

  TextFormField _titleField(){
    // Builds TextFormField for title
    return TextFormField(
      decoration: const InputDecoration(
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),

      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 23,
      ),
      maxLines: 1,
      initialValue: note.title,
      onChanged: (value) {
        note.title = value;
        notesDB.updateNote(note);
      },
    );
  }

  TextFormField _rawDescFormField(){
    // Builds TextFormField for unrendered description (mainly for testing)
    // Only affects checkboxes
    return TextFormField(
      decoration: const InputDecoration(
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),

      style: const TextStyle(
        fontWeight: FontWeight.normal,
        fontSize: 16,
      ),
      maxLines: null,
      initialValue: note.description,
      onChanged: (value) {
        note.description = value;
        notesDB.updateNote(note);
      },
    );
  }


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
        int cbTickedIndex = descriptionList[index].indexOf(checkboxTickedStr);

        if (cbIndex == 0) {
          value = "$checkboxStr$value";
        } else if (cbTickedIndex == 0){
          value = "$checkboxTickedStr$value";
        }
        descriptionList[index] = value;
        String newDescription = descriptionList.join("\n");

        note.description = newDescription;
        notesDB.updateNote(note);
      },
    );
  }

  Row _checkBox(bool isTicked, int index, String initValue, bool hasMultiLines){
    // To build checkbox
    return Row(
      children: [
        Checkbox(
          value: isTicked,
          onChanged: (bool? value) {
            // Select checkbox

            // Symbol to put at start
            String str = checkboxTickedStr;
            if (isTicked){
              str = checkboxStr;
            }

            // Change checkbox symbol
            descriptionList[index] = str + descriptionList[index].substring(2);

            // Update note
            String newDescription = descriptionList.join("\n");
            note.description = newDescription;
            notesDB.updateNote(note);

            setState(() {});
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
    bool endsInNonText = false;
    bool isTicked = false;
    for (String line in lineSplitText){
      // Render line by line
      int cbIndex = line.indexOf(checkboxStr);
      int cbTickedIndex = line.indexOf(checkboxTickedStr);

      // Matches any string matching "[img](...)" with '...' being anything
      int imgIndex = line.indexOf(RegExp(r'^\[img\]\(([^]*)\)$'));

      if ((cbIndex == 0) || (cbTickedIndex == 0) || (imgIndex == 0)){
        // If about to add a non-text widget
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
      }

      if ((cbIndex == 0) || (cbTickedIndex == 0)){
        // If line is a checkbox

        isTicked = false;
        if (cbTickedIndex == 0){
          isTicked = true;
        }

        // Add checkbox to lists
        descriptionList.add(line);
        textControllers.add(TextEditingController(text: line.substring(2)));
        renderedText.add(_checkBox(
          isTicked,
          (descriptionList.length - 1), 
          line.substring(2), 
          false
        ));
        endsInNonText = true;
      } else if (imgIndex == 0) {
        // Get link for image
        String link = line.substring(6);
        link = link.substring(0, link.length - 1);

        double size = 60;

        // Add image to lists
        descriptionList.add(line);
        textControllers.add(TextEditingController(text: line));
        renderedText.add(Container(
          padding: const EdgeInsets.all(8.0),
          child: Image.network(
            link,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;

              return roundedSquare(
                // Progress indicator inside square with rounded edges
                size, 
                CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null ? 
                    loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
                ),
                context
              );
            },

            errorBuilder: (context, error, stackTrace) {
              // Error icon inside square with rounded edges
              return roundedSquare(size, const Icon(Icons.error), context);
            },
          ),
        ));
        endsInNonText = true;
      } else {
        // If not, add line to buffer
        textBuffer.add(line);
        endsInNonText = false;
      }
    }


    if ((textBuffer.isNotEmpty) || (endsInNonText)){
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
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () {
                  // Copies note to clipboard
                  String copiedText = "${note.title}\n\n${note.description}";
                  Clipboard.setData(ClipboardData(text: copiedText));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Copied to clipboard"),
                      behavior: SnackBarBehavior.floating
                    ),
                  );
                },
                child: const Row(
                  children: [
                    Icon(Icons.copy),
                    SizedBox(width: 10),
                    Text("Copy"),
                  ],
                )
              ),
              PopupMenuItem(
                onTap: () {
                  // Displays raw/rendered descripiton
                  displayRaw = !displayRaw;
                  setState(() {});
                },
                child: Row(
                  children: [
                    const Icon(Icons.edit_note),
                    const SizedBox(width: 10),
                    Text(displayRaw ? "View rendered" : "View raw"),
                  ],
                )
              ),
              PopupMenuItem(
                onTap: () async {
                  // Deletes note
                  await notesDB.deleteNote(note);
                  if (mounted){
                    Navigator.pop(context);
                  }
                },
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red[600]),
                    const SizedBox(width: 10),
                    const Text("Delete"),
                  ],
                )
              ),
            ]
          ),
        ],
      ),


      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display note
            _titleField(),
            const Divider(),
            Text(
              time,
              style: TextStyle(color: Theme.of(context).unselectedWidgetColor),
            ),
            const SizedBox(height: 10),

            displayRaw ? Expanded(child: _rawDescFormField()) : renderer(),
            displayRaw ? const SizedBox(height: 30) : const SizedBox(height: 0),
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
