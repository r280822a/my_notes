import 'package:flutter/material.dart';
import 'package:my_notes/widgets/rounded_square.dart';

class DescNetworkImage extends StatelessWidget {
  const DescNetworkImage({
    super.key,
    required this.link,
    required this.index,
    required this.removeDescNetworkImage,
  });

  final String link;
  final int index;
  final Function removeDescNetworkImage;

  @override
  Widget build(BuildContext context) {
    double size = 60;

    return PopupMenuButton(
      position: PopupMenuPosition.under,
      onOpened: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },

      itemBuilder: (context) => [
        PopupMenuItem(
          onTap: () {
            removeDescNetworkImage(index);
          },
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red[600]),
              const SizedBox(width: 10),
              const Text("Delete"),
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

            return RoundedSquare(
              // Progress indicator inside square with rounded edges
              size: size, 
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null ? 
                  loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
              ),
            );
          },

          errorBuilder: (context, error, stackTrace) {
            // Error icon inside square with rounded edges
            return RoundedSquare(size: size, child: const Icon(Icons.error));
          },
        ),
      ),
    );
  }
}