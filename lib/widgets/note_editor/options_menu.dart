import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_notes/notes_db.dart';

class OptionsMenu extends StatelessWidget {
  const OptionsMenu({
    super.key,
    required this.note,
    required this.displayRaw,
    required this.notesDB,
    required this.mounted,
  });

  final Note note;
  final bool displayRaw;
  final NotesDatabase notesDB;
  final bool mounted;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
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
            // toggleRawRendered();
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
    );
  }
}
