import 'package:flutter/material.dart';
import 'dart:io';
import 'package:my_notes/desc_splitter.dart';
import 'package:my_notes/widgets/rounded_square.dart';
import 'package:my_notes/widgets/delete_alert_dialog.dart';
import 'package:path/path.dart' as p;
import 'package:fluttertoast/fluttertoast.dart';

import 'alt_text_alert_dialog.dart';

// File image for description with remove & delete buttons
class DescLocalImage extends StatelessWidget {
  const DescLocalImage({
    super.key,
    required this.descSplitter,
    required this.path,
    required this.imageName,
    required this.altText,
    required this.index,
    required this.setState,
  });

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
          // Popup item to add alt text/tooltip
          onTap: () {
            TextEditingController altController = TextEditingController();
            showDialog(
              context: context,
              builder: (context) => AltTextAlertDialog(
                textFieldController: altController,
                descSplitter: descSplitter,
                index: index,
                setState: setState
              ),
            );
          },
          child: const Row(
            children: [
              Icon(Icons.textsms_outlined),
              SizedBox(width: 10),
              Text("Add alt text"),
            ],
          ),
        ),
        PopupMenuItem(
          // Popup item to remove image
          onTap: () {
            // Remove image from description
            // Doesn't delete file
            descSplitter.list.removeAt(index);
            descSplitter.joinDescription();

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
        PopupMenuItem(
          // Popup item to delete image
          onTap: () {
            // Delete image
            showDialog(
              context: context,
              builder: (context) => DeleteAlertDialog(
                item: "image",
                deleteFunction: () {
                  // Remove image from description
                  descSplitter.list.removeAt(index);
                  descSplitter.joinDescription();

                  // Delete image file
                  File imageFile = File(p.join(path, imageName));
                  if (imageFile.existsSync()){
                    imageFile.deleteSync();
                  }

                  setState();
                }
              ),
            );
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
            // Error icon if not found
            return RoundedSquare(size: size, child: const Icon(Icons.error));
          },
        ),
      ),
    );
  }
}