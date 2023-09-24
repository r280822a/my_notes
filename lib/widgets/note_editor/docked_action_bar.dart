import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:my_notes/pages/note_editor.dart';

class DockedActionBar extends StatelessWidget {
  const DockedActionBar({
    super.key,
    required this.getCurrentTextPos,
    required this.addNonText,
    required this.pickImage,
  });

  final Function getCurrentTextPos;
  final Function addNonText;
  final Function pickImage;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
              // Adds checkbox
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
            // Adds image
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
                          // Local image button
                          TextButton(
                            onPressed: () async {
                              // Adds local image
                              Navigator.pop(context);
                              String imageName = await pickImage();
      
                              if (imageName != ""){
                                Map<String, int> currentPos = getCurrentTextPos();
                                int descIndex = currentPos["descIndex"] as int;
                                int offset = currentPos["offset"] as int;
      
                                String link = "[img](assets/$imageName)";
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
                                Text("Add Local Image")
                              ],
                            ),
                          ),
                          // Network image button
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
