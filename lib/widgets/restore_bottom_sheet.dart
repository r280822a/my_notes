import 'package:flutter/material.dart';

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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.settings_backup_restore,
                    size: 125,
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
