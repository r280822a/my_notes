import 'package:flutter/material.dart';
import 'dart:io';
import 'package:my_notes/widgets/frosted.dart';
import 'package:my_notes/utils/consts.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:io/io.dart' as io;
import 'package:sqflite/sqflite.dart';
import 'package:permission_handler/permission_handler.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Future<String?> getUserBackupPath() async {
    Directory? directory;
    try {
      // Return path to own folder by default
      directory = Directory('/storage/emulated/0/My_Notes');
      directory.createSync(recursive: true);
      // If doesn't exist, fallback to getExternalStorageDirectory
      if (!await directory.exists()) {
        directory = await getExternalStorageDirectory();
      }
    } catch (err) {
      print(err);
    }
    return directory?.path;
  }

  Future<String> fillRootBackupDirectory() async {
    // Get path to root backup directory (user cannot access this dir)
    // Used to create the backup.zip file

    Directory docDir = await getApplicationDocumentsDirectory();
    String docPath = docDir.path.toString();
    String path = join(docPath, "backup"); // Full path to backup
    Directory(path).deleteSync(recursive: true); // Empty directory
    Directory(path).createSync(recursive: true);

    // Path to database
    String databasePath = join(await getDatabasesPath(), "notes.db");
    File databaseFile = File(databasePath);

    // Copy local images. then copy database
    io.copyPathSync(await Consts.getLocalImagesPath(), join(path, "local_images"));
    databaseFile.copySync(join(path, "notes.db"));

    // TESTING
    List<FileSystemEntity> files = Directory(path).listSync();
    print(files);

    return path;
  }

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
            onTap: () async {
              // Backup notes database + local images to downloads
              // First request storage permissions
              if (await Permission.storage.request().isGranted) {
                // Get user backup path, and create a backup.zip file object
                String? backupPath = await getUserBackupPath();
                final zipFile = File(join(backupPath!, "backup.zip"));
                print(backupPath); // TESTING

                // Fill root backup directory, ready to zip
                String backup = await fillRootBackupDirectory();
                final Directory backupDir = Directory(backup);

                try {
                  // Create zip from root backup directory,
                  // Storing it in user backup directory
                  ZipFile.createFromDirectory(
                    sourceDir: backupDir,
                    zipFile: zipFile,
                    recurseSubDirs: true
                  );
                } catch (err) {
                  print(err);
                }
              }
            },
            title: const Text("Backup"),
            subtitle: const Text("Backup data to file, so you can restore it later"),
            leading: const Icon(Icons.backup_outlined)
          ),

          // To restore data
          ListTile(
            onTap: () {
              // Restore notes database + local images from given file
              
            },
            title: const Text("Restore"),
            subtitle: const Text("Restore data from backup file"),
            leading: const Icon(Icons.settings_backup_restore_outlined),
          ),
        ],
      )
    );
  }
}