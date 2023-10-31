import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:my_notes/widgets/frosted.dart';
import 'package:my_notes/utils/consts.dart';
import 'package:my_notes/widgets/backup_bottom_sheet.dart';
import 'package:my_notes/widgets/restore_bottom_sheet.dart';
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
      // Return path to own 'My_Notes' folder by default
      directory = Directory('/storage/emulated/0/My_Notes');
      directory.createSync(recursive: true);

      // If doesn't exist, fallback to getExternalStorageDirectory
      if (!await directory.exists()) {
        directory = await getExternalStorageDirectory();
      }
    } catch (err) {
      // If error occured, display error alert dialog to inform user
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
    // Fill root backup directory with database, and local images
    // Return path to root backup directory
    // NOTE: user cannot access this directory

    Directory docDir = await getApplicationDocumentsDirectory();
    String docPath = docDir.path.toString();

    String backupPath = join(docPath, "backup"); // Full path to backup
    Directory backupDirectory = Directory(backupPath);

    if (backupDirectory.existsSync()){
      // Empty directory, if exists
      backupDirectory.deleteSync(recursive: true);
    }
    backupDirectory.createSync(recursive: true);

    // Path to database, that app uses
    String databasePath = join(await getDatabasesPath(), "notes.db");
    File databaseFile = File(databasePath);

    // Copy local images, then copy database. Both to root backup directory 
    io.copyPathSync(await Consts.getLocalImagesPath(), join(backupPath, "local_images"));
    databaseFile.copySync(join(backupPath, "notes.db"));

    return backupPath;
  }

  Future<String> getRootRestorePath() async {
    // Returns path to root backup directory
    // NOTE: user cannot access this directory

    Directory docDir = await getApplicationDocumentsDirectory();
    String docPath = docDir.path.toString();

    String restorePath = join(docPath, "restore"); // Full path to restore
    Directory restoreDirectory = Directory(restorePath);

    if (restoreDirectory.existsSync()){
      // Empty directory, if exists
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
              // Backup notes database + local images to 'My_Notes' folder

              showModalBottomSheet(
                // To display backup info to user
                context: context,
                builder: (BuildContext context) => const BackupBottomSheet()
              );

              // First request storage permissions
              if ((await Permission.storage.request().isGranted) && mounted) {
                // Get user backup path, and instantiate a backup.zip file object
                String? backupPath = await getUserBackupPath(context);
                File zipFile = File(join(backupPath!, "backup.zip"));

                // Fill root backup directory, ready to zip
                String backup = await fillRootBackupDirectory();
                Directory backupDir = Directory(backup);

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
                    sleep(const Duration(seconds: 2));
                    Navigator.pop(context);
                  }
                  Fluttertoast.showToast(msg: "Backup completed");
                } catch (err) {
                  // If error occured, display error alert dialog to inform user
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
              // Restore notes database + local images from own 'My_Notes' folder

              showModalBottomSheet(
                // To display restore info to user
                context: context,
                builder: (BuildContext context) => const RestoreBottomSheet()
              );

              // First request storage permissions
              if ((await Permission.storage.request().isGranted) && mounted) {
                // Get user backup path, and instantiate backup.zip file object
                String? backupPath = await getUserBackupPath(context);
                File zipFile = File(join(backupPath!, "backup.zip"));

                // Get (and empty) root restore path, ready to extract
                String rootRestorePath = await getRootRestorePath();
                Directory destinationDir = Directory(rootRestorePath);

                try {
                  // Extract backup.zip to root restore path
                  await ZipFile.extractToDirectory(
                    zipFile: zipFile,
                    destinationDir: destinationDir
                  );

                  // Restored database file object
                  String restoredDBPath = join(rootRestorePath, "notes.db");
                  File restoredDatabase = File(restoredDBPath);
                  // Path to database, that app uses
                  String databasePath = join(await getDatabasesPath(), "notes.db");
                  // Copy restored database file to database that app uses
                  restoredDatabase.copySync(databasePath);

                  // Path to restored local images
                  String restoredLocalImagesPath = join(rootRestorePath, "local_images");
                  // Copy restored local images to local images directory that app uses
                  io.copyPathSync(
                    restoredLocalImagesPath,
                    await Consts.getLocalImagesPath()
                  );

                  if (mounted) {
                    // Give user a second to read text before popping bottomsheet
                    // NOTE: Slightly longer sleep than backing up
                    // since extracting is generally faster
                    sleep(const Duration(seconds: 3));
                    Navigator.pop(context);
                  }
                  Fluttertoast.showToast(msg: "Restore completed");
                } catch (err) {
                  // If error occured, display error alert dialog to inform user
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
