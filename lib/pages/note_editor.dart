import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_notes/notes_database.dart';
import 'package:my_notes/desc_splitter.dart';
import 'package:my_notes/consts.dart';
import 'package:my_notes/widgets/note_editor/all.dart';
import 'package:my_notes/widgets/frosted.dart';
import 'package:my_notes/widgets/loading_pages/loading_note_editor.dart';

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
  bool initialised = false;
  ScrollController scrollController = ScrollController();
  bool showTitle = false;

  @override
  void initState() {
    super.initState();
    getPath();
    scrollController.addListener(() {
      // To show/hide title in appbar when scrolling
      if ((scrollController.position.pixels > 50) && (showTitle == false)){
        setState(() {showTitle = true;});
      } else if ((scrollController.position.pixels < 50) && (showTitle == true)){
        setState(() {showTitle = false;});
      }
    });
  }

  void getPath() async {
    // Store path for local images folder
    path = await Consts.getLocalImagesPath();
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    // Dispose of all text controllers and focus nodes
    for (int i = 0; i < descSplitter.textControllers.length; i++){
      descSplitter.textControllers[i].dispose();
    }
    for (int i = 0; i < descSplitter.focusNodes.length; i++){
      descSplitter.focusNodes[i].dispose();
    }
    scrollController.dispose(); // Dispose of scroll controller
  }

  void toggleRawRendered() {
    // Toggle raw/rendered description
    displayRaw = !displayRaw;
    updateDescription();
    setState(() {});
  }

  void updateDescription() {
    // Split description / set raw text
    descSplitter.splitDescription();
    rawTextController.text = note.description;
  }


  @override
  Widget build(BuildContext context) {
    if (path == ""){return const LoadingNoteEditor();}

    if (!initialised){
      // Only run once, on initalisation

      // Retrieve arguements from previous page
      Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
      // Set note attributes
      note = arguments["note"];
      notesDB = arguments["notesDB"];

      // Set description
      descSplitter = DescSplitter(note: note, notesDB: notesDB);
      updateDescription();

      // Set time
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(note.time);
      time = DateFormat('dd MMMM yyyy - hh:mm').format(dateTime);

      initialised = true;
    }


    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        // For frosted look
        backgroundColor: Theme.of(context).colorScheme.background.withAlpha(190),
        scrolledUnderElevation: 0,
        flexibleSpace: Frosted(child: Container(color: Colors.transparent)),

        title: showTitle ? Text(note.title) : const Text(""),
        titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onBackground,
          fontWeight: FontWeight.bold,
          fontSize: 23,
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
        padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).viewInsets.bottom),
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
            controller: scrollController,
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
            controller: scrollController,
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
                  descSplitter: descSplitter,
                  textController: descSplitter.textControllers[index],
                  focusNode: descSplitter.focusNodes[index],
                  index: index,
                  isTicked: isTicked,
                  setState: () {setState(() {updateDescription();});},
                );
              } else if (imgIndex == 0) {
                // If image

                // Remove '![...](', with '...' being anything
                String imageName = text.replaceAll(RegExp(r'!\[(.*?)\]\('), "");
                // Remove ')' at end
                imageName = imageName.substring(0, imageName.length - 1);

                // Remove '](...)', with '...' being anything
                String altText = text.replaceAll(RegExp(r'\]\((.*?)\)'), "");
                // Remove '![' at beginning
                altText = altText.substring(2, altText.length);

                // Add image
                if ((imageName.startsWith("assets/")) || (imageName.startsWith("local_images/"))){
                  if (imageName.startsWith("assets/")){
                    // Update from "assets/" to "local_images/"
                    descSplitter.list[index] = descSplitter.list[index].replaceAll(
                      "assets/", "local_images/");
                    descSplitter.joinDescription();
                  }

                  // Remove "local_images/" at beginning for image name
                  imageName = imageName.replaceAll("local_images/", "");
                  widget = DescLocalImage(
                    descSplitter: descSplitter,
                    index: index,
                    path: path,
                    imageName: imageName,
                    altText: altText,
                    setState: () {setState(() {updateDescription();});},
                  );
                } else {
                  widget = DescNetworkImage(
                    descSplitter: descSplitter,
                    index: index,
                    link: imageName,
                    altText: altText,
                    setState: () {setState(() {updateDescription();});}
                  );
                }
              } else {
                // Add textblock
                widget = DescFormField(
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
                // If end, add space to account for DockedActionBar
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

      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: DockedActionBar(
          note: note,
          notesDB: notesDB,
          descSplitter: descSplitter,
          displayRaw: displayRaw,
          path: path,
          rawTextController: rawTextController,
          setState: () {setState(() {
            FocusManager.instance.primaryFocus?.unfocus();
            updateDescription();
          });},
        ),
      ),
    );
  }
}
