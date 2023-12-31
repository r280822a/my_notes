import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_notes/utils/common.dart';
import 'package:my_notes/utils/notes_database.dart';
import 'package:my_notes/widgets/delete_alert_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';

// PopupMenuButton for options to interact with note
class OptionsMenu extends StatelessWidget {
  const OptionsMenu({
    super.key,
    required this.note,
    required this.notesDB,
    required this.displayRaw,
    required this.mounted,
    required this.toggleRawRendered,
  });

  final Note note;
  final NotesDatabase notesDB;
  final bool displayRaw;
  final bool mounted;
  final Function toggleRawRendered;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      tooltip: "More options",
      itemBuilder: (context) => [
        PopupMenuItem(
          onTap: () {
            // Copy note to clipboard
            final String copiedText = "${note.title}\n\n${note.description}";
            Clipboard.setData(ClipboardData(text: copiedText));
            Fluttertoast.showToast(msg: "Copied to clipboard");
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
            // Display raw/rendered description
            toggleRawRendered();
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
          onTap: () {
            // Delete note
            showDialog(
              context: context,
              builder: (context) => DeleteAlertDialog(
                item: "note",
                deleteFunction: () async {
                  await notesDB.deleteNote(note);
                  if (mounted){
                    Navigator.pop(context);
                  }
                }
              )
            );
          },
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: Common.getDeleteColor(context)),
              const SizedBox(width: 10),
              const Text("Delete note"),
            ],
          )
        ),
      ]
    );
  }
}
