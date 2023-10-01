import 'package:flutter/material.dart';
import 'package:my_notes/widgets/rounded_square.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

class DescLocalImage extends StatelessWidget {
  const DescLocalImage({
    super.key,
    required this.path,
    required this.imageName,
    required this.altText,
    required this.index,
    required this.deleteDescLocalImage,
  });

  final String path;
  final String imageName;
  final String altText;
  final int index;
  final Function deleteDescLocalImage;

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
          // Popup menu to delete image
          onTap: () {
            deleteDescLocalImage(index, imageName);
          },
          child: const Row(
            children: [
              Icon(Icons.delete_outline),
              SizedBox(width: 10),
              Text("Delete image"),
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