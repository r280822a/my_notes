import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:my_notes/notes_database.dart';
import 'package:my_notes/desc_splitter.dart';
import 'package:my_notes/consts.dart';
import 'package:my_notes/widgets/note_editor/all.dart';
import 'package:my_notes/widgets/frosted.dart';
import 'package:my_notes/widgets/loading_pages/loading_note_editor.dart';
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
  TextEditingController rawTextController = TextEditingController();
  FocusNode rawFocusNode = FocusNode();
  late String time;

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

  void toggleRawRendered(){
    // Toggle raw/rendered description
    displayRaw = !displayRaw;
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    if (path == ""){return const LoadingNoteEditor();}

    // Retrieve arguements from previous page
    Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    // Set note attributes
    note = arguments["note"];
    notesDB = arguments["notesDB"];

    // Split description
    descSplitter = DescSplitter(note: note);
    descSplitter.splitDescription();

    rawTextController.text = note.description;

    // Set time
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(note.time);
    time = DateFormat('dd MMMM yyyy - hh:mm').format(dateTime);

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
        child: GestureDetector(
          onTap: () {
            // Focus on bottom-most TextFormField, when tapping background
            if (displayRaw){
              rawFocusNode.requestFocus();
            } else {
              descSplitter.focusNodes[descSplitter.focusNodes.length - 1].requestFocus();
            }
          },

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
              RawDescFormField(
                note: note, 
                notesDB: notesDB,
                textController: rawTextController,
                focusNode: rawFocusNode
              ),
              const SizedBox(height: 80)
            ],
          ) : ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            itemCount: descSplitter.list.length,
            itemBuilder: (context, index) {
              // Display rendered note description

              String text = descSplitter.list[index]; // Text to render
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
                  note: note,
                  notesDB: notesDB,
                  descSplitter: descSplitter,
                  textController: descSplitter.textControllers[index],
                  focusNode: descSplitter.focusNodes[index],
                  index: index,
                  isTicked: isTicked,
                  setState: () {setState(() {});},
                );
              } else if (imgIndex == 0) {
                // If image
        
                // Removes '![]', and everything inside
                String imageName = text.replaceAll(RegExp(r'!\[.*?\]'), "");
                imageName = imageName.substring(1, imageName.length - 1);
        
                // Removes '()', and everything inside
                String altText = text.replaceAll(RegExp(r'\(.*?\)'), "");
                altText = altText.substring(2, altText.length - 1);
        
                // Add image
                if (imageName.startsWith("assets/")){
                  // Remove "assets/" at beginning for local image
                  imageName = imageName.substring(7, imageName.length);
                  widget = DescLocalImage(
                    note: note,
                    notesDB: notesDB,
                    descSplitter: descSplitter,
                    index: index,
                    path: path,
                    imageName: imageName,
                    altText: altText,
                    setState: () {setState(() {});},
                  );
                } else {
                  widget = DescNetworkImage(
                    note: note,
                    notesDB: notesDB,
                    descSplitter: descSplitter,
                    index: index,
                    link: imageName,
                    altText: altText,
                    setState: () {setState(() {});}
                  );
                }
              } else {
                // Add textblock
                widget = DescFormField(
                  note: note,
                  notesDB: notesDB,
                  descSplitter: descSplitter,
                  textController: descSplitter.textControllers[index],
                  focusNode: descSplitter.focusNodes[index],
                  index: index,
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
                // If end, to account for DockedActionBar
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
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: DockedActionBar(
        note: note,
        notesDB: notesDB,
        descSplitter: descSplitter,
        displayRaw: displayRaw,
        path: path,
        rawTextController: rawTextController,
        setState: () {setState(() {});},
      ),
    );
  }
}
