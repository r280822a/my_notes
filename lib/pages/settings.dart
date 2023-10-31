import 'package:flutter/material.dart';
import 'package:my_notes/widgets/frosted.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        // For frosted look
        backgroundColor: Theme.of(context).colorScheme.inversePrimary.withAlpha(190),
        scrolledUnderElevation: 0,
        flexibleSpace: Frosted(child: Container(color: Colors.transparent)),

        title: const Text("Settings"),
        titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onBackground,
          fontWeight: FontWeight.bold,
          fontSize: 23,
        ),
      ),

      body: ListView(
        children: [
          // App Icon
          Padding(
            padding: const EdgeInsets.all(20),
            child: Image.asset(
              "icon/icon_rounded.png",
              fit: BoxFit.fitHeight,
              height: 150,
            ),
          ),

          // App Name + Version
          ListTile(
            title: const Text(
              "My Notes",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25),
            ),
            subtitle: Text(
              "v3.4.0",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),

          // To view local image attachments
          ListTile(
            onTap: () async {
              // Open local images page
              await Navigator.pushNamed(
                context,
                "/local_image_attachments",
              );
            },
            title: const Text("View local image attachments"),
            leading: const Icon(Icons.photo_library_outlined),
            minVerticalPadding: 25
          ),

          // To backup data
          ListTile(
            onTap: () {
              // Backup notes database + local images to downloads
              
            },
            title: const Text("Backup"),
            subtitle: const Text("Last backup: 20th October 2023"),
            leading: const Icon(Icons.backup_outlined)
          ),

          // To restore data
          ListTile(
            onTap: () {
              // Restore notes database + local images from given file
              
            },
            title: const Text("Restore"),
            leading: const Icon(Icons.settings_backup_restore_outlined),
            minVerticalPadding: 25
          ),
        ],
      )
    );
  }
}