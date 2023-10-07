import 'package:flutter/material.dart';
import 'package:my_notes/notes_database.dart';
import 'package:my_notes/desc_splitter.dart';
import 'package:my_notes/widgets/rounded_square.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Network image for description with remove button
class DescNetworkImage extends StatelessWidget {
  const DescNetworkImage({
    super.key,
    required this.note,
    required this.notesDB,
    required this.descSplitter,
    required this.index,
    required this.link,
    required this.altText,
    required this.setState,
  });

  final Note note;
  final NotesDatabase notesDB;
  final DescSplitter descSplitter;
  final int index;
  final String link;
  final String altText;
  final Function setState;

  @override
  Widget build(BuildContext context) {
    double size = 60;

    return PopupMenuButton(
      position: PopupMenuPosition.under,
      tooltip: altText,
      onOpened: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },

      itemBuilder: (context) => [
        PopupMenuItem(
          // Popup item to remove image
          onTap: () {
            // Remove image from description
            descSplitter.list.removeAt(index);
            String newDescription = descSplitter.list.join("\n");
            note.description = newDescription;
            notesDB.updateNote(note);
            
            Fluttertoast.showToast(msg: "Removed image");
            setState();
          },
          child: const Row(
            children: [
              Icon(Icons.delete_outline),
              SizedBox(width: 10),
              Text("Remove image"),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Image.network(
          link,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;

            // Progress indicator when loading
            return RoundedSquare(
              size: size, 
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null ? 
                  loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
              ),
            );
          },

          errorBuilder: (context, error, stackTrace) {
            // Error icon if not found
            return RoundedSquare(size: size, child: const Icon(Icons.error));
          },
        ),
      ),
    );
  }
}