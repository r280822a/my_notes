import 'package:flutter/material.dart';

// Bottom Sheet to display information while restoring
class RestoreBottomSheet extends StatelessWidget {
  const RestoreBottomSheet({
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
                // Restore icon, row used to fill horizontally
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.settings_backup_restore,
                    size: 120,
                  ),
                ],
              ),
              Text(
                "Restoring...",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                "Restoring data from 'backup.zip' file in 'My_Notes' folder",
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
