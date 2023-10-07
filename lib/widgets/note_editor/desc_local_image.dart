import 'package:flutter/material.dart';
import 'dart:io';
import 'package:my_notes/notes_db.dart';
import 'package:my_notes/desc_splitter.dart';
import 'package:my_notes/widgets/rounded_square.dart';
import 'package:path/path.dart' as p;

class DescLocalImage extends StatelessWidget {
  const DescLocalImage({
    super.key,
    required this.note,
    required this.notesDB,
    required this.descSplitter,
    required this.path,
    required this.imageName,
    required this.altText,
    required this.index,
    required this.setState,
  });

  final Note note;
  final NotesDatabase notesDB;
  final DescSplitter descSplitter;
  final int index;
  final String path;
  final String imageName;
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
          // Popup menu to remove image
          onTap: () {
            // Remove image
            descSplitter.list.removeAt(index);
            String newDescription = descSplitter.list.join("\n");
            note.description = newDescription;
            notesDB.updateNote(note);

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
        PopupMenuItem(
          // Popup menu to delete image
          onTap: () {
            // Delete image
            descSplitter.list.removeAt(index);
            String newDescription = descSplitter.list.join("\n");
            note.description = newDescription;
            notesDB.updateNote(note);

            File imageFile = File(p.join(path, imageName));
            if (imageFile.existsSync()){
              imageFile.deleteSync();
            }

            setState();
          },
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red[600]),
              const SizedBox(width: 10),
              const Text("Delete image"),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Image.file(
          File(p.join(path, imageName)),

          errorBuilder: (context, error, stackTrace) {
            // Error icon inside square with rounded edges
            return RoundedSquare(size: size, child: const Icon(Icons.error));
          },
        ),
      ),
    );
  }
}