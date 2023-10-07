import 'package:flutter/material.dart';
import 'dart:io';
import 'package:my_notes/notes_db.dart';
import 'package:my_notes/desc_splitter.dart';
import 'package:my_notes/consts.dart';
import 'package:my_notes/widgets/frosted.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

class DockedActionBar extends StatelessWidget {
  const DockedActionBar({
    super.key,
    required this.note,
    required this.notesDB,
    required this.descSplitter,
    required this.displayRaw,
    required this.path,
    required this.rawTextController,
    required this.setState
  });

  final Note note;
  final NotesDatabase notesDB;
  final DescSplitter descSplitter;
  final bool displayRaw;
  final String path;
  final TextEditingController rawTextController;
  final Function setState;

  Map<String, int> getCurrentTextPos(){
    // Get current position of the cursor

    // Default offset and index are at end
    int descIndex = (descSplitter.list.length - 1);
    int offset = descSplitter.list[descIndex].length;

    if (displayRaw == true){
      offset = rawTextController.selection.baseOffset;
      return {
        "descIndex": -1,
        "offset": offset
      };
    }

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

    String desc = note.description;
    if (descIndex != -1) {desc = descSplitter.list[descIndex];}

    // Split text from start till index
    // To find which line to add string
    String substring = desc.substring(0, offset);
    List<String> substringSplit = substring.split("\n");

    // Add string
    List<String> textSplit = desc.split("\n");
    textSplit.insert(substringSplit.length, strToAdd);
    desc = textSplit.join("\n");

    // Update note
    if (descIndex != -1) {
      descSplitter.list[descIndex] = desc;
      String newDescription = descSplitter.list.join("\n");
      note.description = newDescription;
    } else {
      note.description = desc;
    }
    notesDB.updateNote(note);

    setState();
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

  @override
  Widget build(BuildContext context) {
    // Add non-text widgets to description
    return Frosted(
      child: Container(
        color: Theme.of(context).colorScheme.background.withAlpha(190),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
              // Add checkbox
              child: IconButton(
                tooltip: "Add checkbox",
                onPressed: () {
                  Map<String, int> currentPos = getCurrentTextPos();
                  int descIndex = currentPos["descIndex"] as int;
                  int offset = currentPos["offset"] as int;
                  addNonText(Consts.checkboxStr, descIndex, offset);
                },
                icon: const Icon(Icons.add_box_outlined),
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            // Add image
            IconButton(
              tooltip: "Add image",
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) => AddImageBottomSheet(
                    pickImage: pickImage,
                    getCurrentTextPos: getCurrentTextPos,
                    addNonText: addNonText
                  ),
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

class AddImageBottomSheet extends StatelessWidget {
  const AddImageBottomSheet({
    super.key,
    required this.pickImage,
    required this.getCurrentTextPos,
    required this.addNonText,
  });

  final Function pickImage;
  final Function getCurrentTextPos;
  final Function addNonText;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Local image button
              TextButton(
                onPressed: () async {
                  // Add local image
                  Navigator.pop(context);
                  String imageName = await pickImage();
                    
                  if (imageName != ""){
                    Map<String, int> currentPos = getCurrentTextPos();
                    int descIndex = currentPos["descIndex"] as int;
                    int offset = currentPos["offset"] as int;
                    
                    String link = "![](assets/$imageName)";
                    addNonText(link, descIndex, offset);
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onBackground,
                ),
                child: const Row(
                  children: [
                    Icon(Icons.photo_library_outlined),
                    SizedBox(width: 10),
                    Text(
                      "Add Local Image",
                      style: TextStyle(fontSize: 16),
                    )
                  ],
                ),
              ),
              // Network image button
              TextButton(
                onPressed: () {
                  // Add network image
                  Navigator.pop(context);
                  Map<String, int> currentPos = getCurrentTextPos();
                  int descIndex = currentPos["descIndex"] as int;
                  int offset = currentPos["offset"] as int;
                    
                  TextEditingController linkController = TextEditingController();
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      // Lets user add link
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
                              String link = "![](${linkController.text})";
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
                    Text(
                      "Add Network Image",
                      style: TextStyle(fontSize: 16)
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
