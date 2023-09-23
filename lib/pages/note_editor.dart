import 'package:flutter/material.dart';
import 'package:my_notes/notes_db.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:my_notes/helper_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

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


  void selectDescCheckBox(bool isTicked, int index){
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

  void updateDescFormField(String value, int index){
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
        child: DescFormField(textControllers: textControllers, checkboxStr: checkboxStr, checkboxTickedStr: checkboxTickedStr, descriptionList: descriptionList, note: note, notesDB: notesDB, index: (descriptionList.length - 1), initValue: description, hasMultiLines: true, updateDescFormField: updateDescFormField),
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
        if (textBuffer.isNotEmpty && !((textBuffer.length == 1) && (textBuffer[0] == ""))){
          // If any text in text buffer (ignore single line gaps)
          // Join together to form 1 textblock
          String join = textBuffer.join("\n");

          // Add textblock to lists
          descriptionList.add(join);
          textControllers.add(TextEditingController(text: join));
          renderedText.add(DescFormField(textControllers: textControllers, checkboxStr: checkboxStr, checkboxTickedStr: checkboxTickedStr, descriptionList: descriptionList, note: note, notesDB: notesDB, index: (descriptionList.length - 1), initValue: join, hasMultiLines: true, updateDescFormField: updateDescFormField));
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
        renderedText.add(DescCheckBox(textControllers: textControllers, checkboxStr: checkboxStr, checkboxTickedStr: checkboxTickedStr, descriptionList: descriptionList, note: note, notesDB: notesDB, isTicked: isTicked, index: (descriptionList.length - 1), initValue: line.substring(2), hasMultiLines: false, selectDescCheckBox: selectDescCheckBox, removeDescCheckBox: removeDescCheckBox, updateDescFormField: updateDescFormField));
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
          renderedText.add(DescLocalImage(path: path, imageName: image, index: (descriptionList.length - 1), deleteDescLocalImage: deleteDescLocalImage));
        } else {
          renderedText.add(DescNetworkImage(link: image, index: (descriptionList.length - 1), removeDescNetworkImage: removeDescNetworkImage,));
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
          child: DescFormField(textControllers: textControllers, checkboxStr: checkboxStr, checkboxTickedStr: checkboxTickedStr, descriptionList: descriptionList, note: note, notesDB: notesDB, index: (descriptionList.length - 1), initValue: value, hasMultiLines: true, updateDescFormField: updateDescFormField)
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

    await imageFile.copy("$path/$imageName");
    return imageName;
  }



  @override
  Widget build(BuildContext context) {
    if (path == ""){return loadingNoteEditorScreen(context);}

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
      floatingActionButton: Material(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: IconButton(
                onPressed: () {
                  Map<String, int> currentPos = getCurrentTextPos();
                  int descIndex = currentPos["descIndex"] as int;
                  int offset = currentPos["offset"] as int;
                  addNonText(checkboxStr, descIndex, offset);
                },
                icon: const Icon(Icons.add_box_outlined),
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return SizedBox(
                      height: 120,
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          TextButton(
                            onPressed: () async {
                              // Adds local image
                              Navigator.pop(context);
                              String imageName = await pickImage();

                              Map<String, int> currentPos = getCurrentTextPos();
                              int descIndex = currentPos["descIndex"] as int;
                              int offset = currentPos["offset"] as int;

                              String link = "[img](assets/$imageName)";
                              addNonText(link, descIndex, offset);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Theme.of(context).colorScheme.onBackground,
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.photo_library_outlined),
                                SizedBox(width: 10),
                                Text("Add Local Image")
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Adds network image
                              Navigator.pop(context);
                              Map<String, int> currentPos = getCurrentTextPos();
                              int descIndex = currentPos["descIndex"] as int;
                              int offset = currentPos["offset"] as int;

                              TextEditingController linkController = TextEditingController();
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Enter image link below"),
                                  content: TextField(
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      label: Text("Link"),
                                    ),
                                    controller: linkController,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        if (linkController.text != ""){
                                          String link = "[img](${linkController.text})";
                                          addNonText(link, descIndex, offset);
                                        }
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Ok")
                                    )
                                  ],
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Theme.of(context).colorScheme.onBackground,
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.insert_link_outlined),
                                SizedBox(width: 10),
                                Text("Add Network Image")
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              icon: const Icon(Icons.add_photo_alternate_outlined),
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ],
        ),
      ),
    );
  }
}
