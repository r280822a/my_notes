import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:my_notes/notes_db.dart';
import 'package:my_notes/widgets/note_editor/all.dart';
import 'package:my_notes/widgets/loading_pages/loading_note_editor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;


// Checkbox symbols
const String checkboxStr = "☐ ";
const String checkboxTickedStr = "☑ ";

class NoteEditor extends StatefulWidget {
  const NoteEditor({super.key});

  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  late Note note;
  late NotesDatabase notesDB;

  // For each DescFormField
  List<String> descriptionList = []; // Seperate item for each textblock and checkbox
  List<TextEditingController> textControllers = [];

  bool displayRaw = false;

  String path = "";

  @override
  void initState() {
    super.initState();
    getPath();
  }

  void getPath() async {
    // Stores path for local images
    Directory docDir = await getApplicationDocumentsDirectory();
    String docPath = docDir.path.toString();
    path = p.join(docPath, "assets");
    await Directory(path).create(recursive: true);
    setState(() {});
  }

  // ===== Methods used in imported widgets =====
  void updateDescFormField(int index, String value){
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
  }

  void selectDescCheckBox(int index, bool isTicked){
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
  }

  void removeDescCheckBox(int index){
    // Remove checkbox
    descriptionList.removeAt(index);
    String newDescription = descriptionList.join("\n");
    note.description = newDescription;
    notesDB.updateNote(note);

    setState(() {});
  }

  void removeDescNetworkImage(int index){
    // Remove image
    descriptionList.removeAt(index);
    String newDescription = descriptionList.join("\n");
    note.description = newDescription;
    notesDB.updateNote(note);

    setState(() {});
  }

  void deleteDescLocalImage(int index, String imageName){
    // Deletes image
    descriptionList.removeAt(index);
    String newDescription = descriptionList.join("\n");
    note.description = newDescription;
    notesDB.updateNote(note);

    File(p.join(path, imageName)).deleteSync();

    setState(() {});
  }


  // ===== Renderer =====
  void toggleRawRendered(){
    // Toggles raw/rendered descripiton
    displayRaw = !displayRaw;
    setState(() {});
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
        if (textBuffer.isNotEmpty && !((textBuffer.length == 1) && (textBuffer[0] == ""))){
          // If any text in text buffer (ignore single line gaps)
          // Join together to form 1 textblock
          String join = textBuffer.join("\n");

          // Add textblock to lists
          descriptionList.add(join);
          textControllers.add(TextEditingController(text: join));
          renderedText.add(DescFormField(
            textControllers: textControllers,
            index: (descriptionList.length - 1),
            initValue: join,
            hasMultiLines: true,
            updateDescFormField: updateDescFormField
          ));
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
        renderedText.add(DescCheckBox(
          textControllers: textControllers,
          index: (descriptionList.length - 1),
          initValue: line.substring(2),
          hasMultiLines: false,
          updateDescFormField: updateDescFormField,
          isTicked: isTicked,
          selectDescCheckBox: selectDescCheckBox,
          removeDescCheckBox: removeDescCheckBox
        ));
        endsInNonText = true;
      } else if (imgIndex == 0) {
        // Get link for image

        String image = line.substring(6);
        image = image.substring(0, image.length - 1);

        // Add image to lists
        descriptionList.add(line);
        textControllers.add(TextEditingController(text: line));
        if (image.startsWith("assets/")){
          image = image.substring(7, image.length);
          renderedText.add(DescLocalImage(
            path: path,
            imageName: image,
            index: (descriptionList.length - 1),
            deleteDescLocalImage: deleteDescLocalImage
          ));
        } else {
          renderedText.add(DescNetworkImage(
            link: image,
            index: (descriptionList.length - 1),
            removeDescNetworkImage: removeDescNetworkImage
          ));
        }
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
          child: DescFormField(
            textControllers: textControllers,
            index: (descriptionList.length - 1),
            initValue: value,
            hasMultiLines: true,
            updateDescFormField: updateDescFormField
          )
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


  // ===== Methods used in build function =====
  Map<String, int> getCurrentTextPos(){
    // Gets current position of the cursor

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

    Map<String, int> result = {
      "descIndex": descIndex,
      "offset": offset
    };
    return result;
  }

  void addNonText(String strToAdd, int descIndex, int offset) {
    // Adds non text widget (checkbox or image)

    // Split text from start till index 
    // To find which line to add string (at substringSplit.length)
    String substring = descriptionList[descIndex].substring(0, offset);
    List<String> substringSplit = substring.split("\n");

    // Add string
    List<String> textSplit = descriptionList[descIndex].split("\n");
    textSplit.insert(substringSplit.length, strToAdd);
    descriptionList[descIndex] = textSplit.join("\n");

    // Update note
    String newDescription = descriptionList.join("\n");
    note.description = newDescription;
    notesDB.updateNote(note);

    setState(() {});
  }

  Future<String> pickImage() async {
    File imageFile;
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image == null) {return "";}

    // Convert XFile to file
    imageFile = File(image.path);

    // Copy image to new path
    List split = p.split(image.path);
    String imageName = split[split.length - 1];

    imageFile.copySync("$path/$imageName");
    return imageName;
  }


  // ===== Build function =====
  @override
  Widget build(BuildContext context) {
    if (path == ""){return const LoadingNoteEditor();}

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
          OptionsMenu(
            note: note,
            notesDB: notesDB,
            displayRaw: displayRaw,
            mounted: mounted,
            toggleRawRendered: toggleRawRendered,
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display note
            TitleFormField(note: note, notesDB: notesDB),
            const Divider(),
            Text(
              time,
              style: TextStyle(color: Theme.of(context).unselectedWidgetColor),
            ),
            const SizedBox(height: 10),

            displayRaw ? Expanded(child: RawDescFormField(note: note, notesDB: notesDB)) : renderer(),
            displayRaw ? const SizedBox(height: 40) : const SizedBox(height: 0),
          ],
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: DockedActionBar(
        getCurrentTextPos: getCurrentTextPos,
        addNonText: addNonText,
        pickImage: pickImage
      ),
    );
  }
}
