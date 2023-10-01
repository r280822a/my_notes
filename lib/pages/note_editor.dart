import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:my_notes/notes_db.dart';
import 'package:my_notes/desc_splitter.dart';
import 'package:my_notes/consts.dart';
import 'package:my_notes/widgets/note_editor/all.dart';
import 'package:my_notes/widgets/frosted.dart';
import 'package:my_notes/widgets/loading_pages/loading_note_editor.dart';
import 'package:image_picker/image_picker.dart';
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

  late DescSplitter descSplitter;
  String path = "";
  bool displayRaw = false;

  @override
  void initState() {
    super.initState();
    getPath();
  }

  void getPath() async {
    // Store path for local images
    Directory docDir = await getApplicationDocumentsDirectory();
    String docPath = docDir.path.toString();
    path = p.join(docPath, "assets");
    await Directory(path).create(recursive: true);
    setState(() {});
  }

  // ===== Methods used in imported widgets =====
  void updateDescFormField(int index, String value){
    // Update textblock, when changed

    int cbIndex = descSplitter.list[index].indexOf(Consts.checkboxStr);
    int cbTickedIndex = descSplitter.list[index].indexOf(Consts.checkboxTickedStr);

    if (cbIndex == 0) {
      value = "${Consts.checkboxStr}$value";
    } else if (cbTickedIndex == 0){
      value = "${Consts.checkboxTickedStr}$value";
    }
    descSplitter.list[index] = value;
    String newDescription = descSplitter.list.join("\n");

    note.description = newDescription;
    notesDB.updateNote(note);
  }

  void selectDescCheckBox(int index, bool isTicked){
    // Select checkbox

    // Symbol to put at start
    String str = Consts.checkboxTickedStr;
    if (isTicked){
      str = Consts.checkboxStr;
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
    // Delete image
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
    // Toggle raw/rendered description
    displayRaw = !displayRaw;
    setState(() {});
  }


  // ===== Methods used in build function =====
  Map<String, int> getCurrentTextPos(){
    // Get current position of the cursor

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
    // Add non-text widget (checkbox or image)

    // Split text from start till index
    // To find which line to add string
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
    // Let user pick image
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image == null) {return "";}

    // Convert XFile to file
    File imageFile = File(image.path);

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

    // Split description
    descSplitter = DescSplitter(note: note);
    descSplitter.splitDescription();

    // Set time
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(note.time);
    String time = DateFormat('dd MMMM yyyy - hh:mm').format(dateTime);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        // For frosted look
        backgroundColor: Theme.of(context).colorScheme.background.withAlpha(190),
        scrolledUnderElevation: 0,
        flexibleSpace: Frosted(child: Container(color: Colors.transparent)),

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
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: displayRaw ? ListView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          children: [
            // Title and time
            TitleFormField(note: note, notesDB: notesDB),
            const Divider(),
            Text(
              time,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).unselectedWidgetColor),
            ),
            const SizedBox(height: 10),

            // Display raw note description
            RawDescFormField(note: note, notesDB: notesDB),
            const SizedBox(height: 80)
          ],
        ) : ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          itemCount: descSplitter.list.length,
          itemBuilder: (context, index) {
            // Display rendered note description

            // Text to render
            String text = descSplitter.list[index];
            Widget widget;

            // Indexes for non-text widgets
            int cbIndex = text.indexOf(Consts.checkboxStr);
            int cbTickedIndex = text.indexOf(Consts.checkboxTickedStr);
            int imgIndex = text.indexOf(Consts.imageRegex);
            bool isTicked = false;

            if ((cbIndex == 0) || (cbTickedIndex == 0)){
              // If checkbox

              isTicked = false;
              if (cbTickedIndex == 0){isTicked = true;}

              // Add checkbox
              widget = DescCheckBox(
                textController: descSplitter.textControllers[index],
                index: index,
                initValue: text.substring(2),
                updateDescFormField: updateDescFormField,
                isTicked: isTicked,
                selectDescCheckBox: selectDescCheckBox,
                removeDescCheckBox: removeDescCheckBox
              );
            } else if (imgIndex == 0) {
              // If image

              // Removes '![]', and everything inside them
              String imageName = text.replaceAll(RegExp(r'!\[.*?\]'), "");
              imageName = imageName.substring(1, imageName.length - 1);

              // Removes '()', and everything inside them
              String altText = text.replaceAll(RegExp(r'\(.*?\)'), "");
              altText = altText.substring(2, altText.length - 1);

              // Add image
              if (imageName.startsWith("assets/")){
                // Remove "assets/" at beginning if local image
                imageName = imageName.substring(7, imageName.length);
                widget = DescLocalImage(
                  path: path,
                  imageName: imageName,
                  altText: altText,
                  index: index,
                  deleteDescLocalImage: deleteDescLocalImage
                );
              } else {
                widget = DescNetworkImage(
                  link: imageName,
                  altText: altText,
                  index: index,
                  removeDescNetworkImage: removeDescNetworkImage
                );
              }
            } else {
              // Add textblock
              widget = DescFormField(
                textController: descSplitter.textControllers[index],
                index: index,
                initValue: text,
                updateDescFormField: updateDescFormField
              );
            }

            if (index == 0){
              // If beginning, add title and time
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
              // If end, add some space so you can type
              return Column(
                children: [
                  widget,
                  const SizedBox(height: 80)
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
