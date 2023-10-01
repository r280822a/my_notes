import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:ui';
import 'package:my_notes/notes_db.dart';
import 'package:my_notes/desc_splitter.dart';
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

  late DescSplitter descSplitter;
  String path = "";
  bool displayRaw = false;

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
    int cbIndex = descSplitter.list[index].indexOf(checkboxStr);
    int cbTickedIndex = descSplitter.list[index].indexOf(checkboxTickedStr);

    if (cbIndex == 0) {
      value = "$checkboxStr$value";
    } else if (cbTickedIndex == 0){
      value = "$checkboxTickedStr$value";
    }
    descSplitter.list[index] = value;
    String newDescription = descSplitter.list.join("\n");

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
    descSplitter.list[index] = str + descSplitter.list[index].substring(2);

    // Update note
    String newDescription = descSplitter.list.join("\n");
    note.description = newDescription;
    notesDB.updateNote(note);

    setState(() {});
  }

  void removeDescCheckBox(int index){
    // Remove checkbox
    descSplitter.list.removeAt(index);
    String newDescription = descSplitter.list.join("\n");
    note.description = newDescription;
    notesDB.updateNote(note);

    setState(() {});
  }

  void removeDescNetworkImage(int index){
    // Remove image
    descSplitter.list.removeAt(index);
    String newDescription = descSplitter.list.join("\n");
    note.description = newDescription;
    notesDB.updateNote(note);

    setState(() {});
  }

  void deleteDescLocalImage(int index, String imageName){
    // Deletes image
    descSplitter.list.removeAt(index);
    String newDescription = descSplitter.list.join("\n");
    note.description = newDescription;
    notesDB.updateNote(note);

    File imageFile = File(p.join(path, imageName));
    if (imageFile.existsSync()){
      imageFile.deleteSync();
    }

    setState(() {});
  }


  // ===== Renderer =====
  void toggleRawRendered(){
    // Toggles raw/rendered descripiton
    displayRaw = !displayRaw;
    setState(() {});
  }


  // ===== Methods used in build function =====
  Map<String, int> getCurrentTextPos(){
    // Gets current position of the cursor

    // Default offset and index are at end
    int descIndex = (descSplitter.list.length - 1);
    int offset = descSplitter.list[descIndex].length;

    // Find currently selected text controller
    // Store its index and offset
    for (int i = 0; i < descSplitter.textControllers.length; i++){
      final int baseOffset = descSplitter.textControllers[i].selection.baseOffset;
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
    String substring = descSplitter.list[descIndex].substring(0, offset);
    List<String> substringSplit = substring.split("\n");

    // Add string
    List<String> textSplit = descSplitter.list[descIndex].split("\n");
    textSplit.insert(substringSplit.length, strToAdd);
    descSplitter.list[descIndex] = textSplit.join("\n");

    // Update note
    String newDescription = descSplitter.list.join("\n");
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

    descSplitter = DescSplitter(note: note);
    descSplitter.splitDescription();

    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(note.time);
    String time = DateFormat('dd MMMM yyyy - hh:mm').format(dateTime);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background.withAlpha(190),
        scrolledUnderElevation: 0,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(color: Colors.transparent),
          ),
        ),

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
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: displayRaw ? ListView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          children: [
            TitleFormField(note: note, notesDB: notesDB),
            const Divider(),
            Text(
              time,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).unselectedWidgetColor),
            ),
            const SizedBox(height: 10),

            RawDescFormField(note: note, notesDB: notesDB),
            const SizedBox(height: 60)
          ],
        ) : ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          itemCount: descSplitter.list.length,
          itemBuilder: (context, index) {
            String text = descSplitter.list[index];
            Widget widget;

            int cbIndex = text.indexOf(checkboxStr);
            int cbTickedIndex = text.indexOf(checkboxTickedStr);
            bool isTicked = false;

            // Matches any string matching "[img](...)" with '...' being anything
            int imgIndex = text.indexOf(RegExp(r'^\[img\]\(([^]*)\)$'));

            if ((cbIndex == 0) || (cbTickedIndex == 0)){
              // If line is a checkbox

              isTicked = false;
              if (cbTickedIndex == 0){isTicked = true;}

              // Add checkbox
              widget = DescCheckBox(
                textControllers: descSplitter.textControllers,
                index: index,
                initValue: text.substring(2),
                updateDescFormField: updateDescFormField,
                isTicked: isTicked,
                selectDescCheckBox: selectDescCheckBox,
                removeDescCheckBox: removeDescCheckBox
              );
            } else if (imgIndex == 0) {
              // Get link for image

              String image = text.substring(6);
              image = image.substring(0, image.length - 1);

              // Add image
              if (image.startsWith("assets/")){
                image = image.substring(7, image.length);
                widget = DescLocalImage(
                  path: path,
                  imageName: image,
                  index: index,
                  deleteDescLocalImage: deleteDescLocalImage
                );
              } else {
                widget = DescNetworkImage(
                  link: image,
                  index: index,
                  removeDescNetworkImage: removeDescNetworkImage
                );
              }
            } else {
              // Add textblock
              widget = DescFormField(
                textControllers: descSplitter.textControllers,
                index: index,
                initValue: text,
                updateDescFormField: updateDescFormField
              );
            }

            if (index == 0){
              return Column(
                children: [
                  TitleFormField(note: note, notesDB: notesDB),
                  const Divider(),
                  Text(
                    time,
                    style: TextStyle(color: Theme.of(context).unselectedWidgetColor),
                  ),
                  const SizedBox(height: 10),
                  widget
                ],
              );
            } else if (index == (descSplitter.list.length - 1)){
              return Column(
                children: [
                  widget,
                  const SizedBox(height: 60)
                ],
              );
            }

            return widget;
          }
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
