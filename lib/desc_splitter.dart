import 'package:flutter/material.dart';
import 'package:my_notes/notes_db.dart';
import 'package:my_notes/consts.dart';

class DescSplitter{
  // Holds seperate item for each textblock, checkbox, and image
  List<String> list = [];
  List<TextEditingController> textControllers = [];
  List<FocusNode> focusNodes = [];
  Note note;

  DescSplitter({required this.note,});

  void splitDescription() {
    // Splits description into seperate items 
    // for each textblock, checkbox, and image
    list.clear();
    textControllers.clear();
    focusNodes.clear();

    String description = note.description;
    List<String> lineSplitText = description.split("\n");
    List<String> textBuffer = [];
    bool endsInNonText = false;

    for (String line in lineSplitText){
      // Split line by line
      int cbIndex = line.indexOf(Consts.checkboxStr);
      int cbTickedIndex = line.indexOf(Consts.checkboxTickedStr);
      int imgIndex = line.indexOf(Consts.imageRegex);

      if ((cbIndex == 0) || (cbTickedIndex == 0) || (imgIndex == 0)){
        // If about to add a non-text item
        if (textBuffer.isNotEmpty && !((textBuffer.length == 1) && (textBuffer[0] == ""))){
          // If any text in text buffer (ignore single line gaps)
          // Join together to form 1 textblock
          String join = textBuffer.join("\n");

          // Add textblock to lists
          list.add(join);
          textControllers.add(TextEditingController(text: join));
          focusNodes.add(FocusNode());
          textBuffer = []; // Reset buffer
        }
      }

      if ((cbIndex == 0) || (cbTickedIndex == 0)){
        // Add checkbox to lists
        list.add(line);
        textControllers.add(TextEditingController(text: line.substring(2)));
        focusNodes.add(FocusNode());
        endsInNonText = true;
      } else if (imgIndex == 0) {
        // Add image to lists
        list.add(line);
        textControllers.add(TextEditingController(text: line));
        focusNodes.add(FocusNode());
        endsInNonText = true;
      } else {
        // If not, add line to buffer
        textBuffer.add(line);
        endsInNonText = false;
      }
    }


    if ((textBuffer.isNotEmpty) || (endsInNonText)){
      String value = ""; // Blank line if ends in non-text
      if (textBuffer.isNotEmpty){
        // If any text in text buffer
        // Join together to form 1 textblock
        value = textBuffer.join("\n");
      }

      // Add textblock to lists
      list.add(value);
      textControllers.add(TextEditingController(text: value));
      focusNodes.add(FocusNode());
    }
  }
}