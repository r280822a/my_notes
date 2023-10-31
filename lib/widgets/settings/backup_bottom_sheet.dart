import 'package:flutter/material.dart';

// Bottom Sheet to display information while backing up
class BackupBottomSheet extends StatelessWidget {
  const BackupBottomSheet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            children: [
              Row(
                // Backup icon, row used to fill horizontally
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.backup,
                    size: 150,
                  ),
                ],
              ),
              Text(
                "Backing up...",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                "Backing up data to 'backup.zip' file in 'My_Notes' folder",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              )
            ],
          )
        )
      ],
    );
  }
}
