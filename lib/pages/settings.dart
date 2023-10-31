import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:my_notes/widgets/frosted.dart';
import 'package:my_notes/utils/consts.dart';
import 'package:my_notes/widgets/backup_bottom_sheet.dart';
import 'package:my_notes/widgets/error_alert_dialog.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:io/io.dart' as io;
import 'package:sqflite/sqflite.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Future<String?> getUserBackupPath(BuildContext context) async {
    // Returns path to backup folder, that user can access
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
      if (mounted) {
        showDialog(
          context: context,
          builder:(context) => ErrorAlertDialog(
            platformException: err as PlatformException
          ),
        );
      }
    }
    return directory?.path;
  }

  Future<String> fillRootBackupDirectory() async {
    // Get path to root backup directory (user cannot access this dir)
    // Used to create the backup.zip file

    Directory docDir = await getApplicationDocumentsDirectory();
    String docPath = docDir.path.toString();

    String backupPath = join(docPath, "backup"); // Full path to backup
    Directory backupDirectory = Directory(backupPath);

    if (backupDirectory.existsSync()){
      // Empty directory
      backupDirectory.deleteSync(recursive: true);
    }
    backupDirectory.createSync(recursive: true);

    // Path to database
    String databasePath = join(await getDatabasesPath(), "notes.db");
    File databaseFile = File(databasePath);
    print(databaseFile.readAsBytesSync());

    // Copy local images. then copy database
    io.copyPathSync(await Consts.getLocalImagesPath(), join(backupPath, "local_images"));
    databaseFile.copySync(join(backupPath, "notes.db"));

    return backupPath;
  }

  Future<String> getRootRestorePath() async {
    Directory docDir = await getApplicationDocumentsDirectory();
    String docPath = docDir.path.toString();

    String restorePath = join(docPath, "restore"); // Full path to backup
    Directory restoreDirectory = Directory(restorePath);

    if (restoreDirectory.existsSync()){
      // Empty directory
      restoreDirectory.deleteSync(recursive: true);
    }
    restoreDirectory.createSync(recursive: true);

    return restorePath;
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

              showModalBottomSheet(
                // To display backup info to user
                context: context,
                builder: (BuildContext context) => const BackupBottomSheet()
              );

              // First request storage permissions
              if ((await Permission.storage.request().isGranted) && mounted) {
                // Get user backup path, and create a backup.zip file object
                String? backupPath = await getUserBackupPath(context);
                final zipFile = File(join(backupPath!, "backup.zip"));

                // Fill root backup directory, ready to zip
                String backup = await fillRootBackupDirectory();
                final Directory backupDir = Directory(backup);

                try {
                  // Create zip from root backup directory,
                  // Storing it in user backup directory
                  await ZipFile.createFromDirectory(
                    sourceDir: backupDir,
                    zipFile: zipFile,
                    recurseSubDirs: true
                  );
                  if (mounted) {
                    // Give user a second to read text before popping bottomsheet
                    sleep(const Duration(seconds: 1));
                    Navigator.pop(context);
                  }
                  Fluttertoast.showToast(msg: "Backup completed");
                } catch (err) {
                  if (mounted) {
                    showDialog(
                      context: context,
                      builder:(context) => ErrorAlertDialog(
                        platformException: err as PlatformException
                      ),
                    );
                  }
                }
              }
            },
            title: const Text("Backup"),
            subtitle: const Text("Backup data to file, so you can restore it later"),
            leading: const Icon(Icons.backup_outlined)
          ),

          // To restore data
          ListTile(
            onTap: () async {
              // Restore notes database + local images from given file

              if ((await Permission.storage.request().isGranted) && mounted) {
                // Get user backup path, and backup.zip file object
                String? backupPath = await getUserBackupPath(context);
                final zipFile = File(join(backupPath!, "backup.zip"));

                String rootRestorePath = await getRootRestorePath();
                final Directory destinationDir = Directory(rootRestorePath);
                try {
                  await ZipFile.extractToDirectory(
                    zipFile: zipFile,
                    destinationDir: destinationDir
                  );

                  String restoredDBPath = join(rootRestorePath, "notes.db");
                  File restoredDatabase = File(restoredDBPath);

                  String databasePath = join(await getDatabasesPath(), "notes.db");

                  restoredDatabase.copySync(databasePath);

                  String restoredLocalImagesPath = join(
                    rootRestorePath, "local_images"
                  );
                  io.copyPathSync(
                    restoredLocalImagesPath,
                    await Consts.getLocalImagesPath()
                  );
                } catch (err) {
                  if (mounted) {
                    showDialog(
                      context: context,
                      builder:(context) => ErrorAlertDialog(
                        platformException: err as PlatformException
                      ),
                    );
                  }
                }
              }
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
