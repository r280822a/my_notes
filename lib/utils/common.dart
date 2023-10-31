import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

// Stores all reused constants/variables, and functions
class Common {
  // Checkbox symbols
  static const String checkboxStr = "☐ ";
  static const String checkboxTickedStr = "☑ ";

  // For any string matching "![...](...)", with '...' being anything
  static final RegExp imageRegex = RegExp(r'!\[(.*?)\]\((.*?)\)');

  static Future<String> getNotesDatabasePath() async {
    // Get path to notes database
    return p.join(await getDatabasesPath(), "notes.db");
  }

  static Future<String> getLocalImagesPath() async {
    // Get path to local images folder

    Directory docDir = await getApplicationDocumentsDirectory();
    String docPath = docDir.path.toString();

    String oldPath = p.join(docPath, "assets");
    Directory oldDir = Directory(oldPath); // Outdated path/directory name
    String path = p.join(docPath, "local_images"); // Full path to local images

    if (oldDir.existsSync()){
      // If old path exists & contains nothing, delete directory
      // Else rename to new path
      if (oldDir.listSync().isEmpty){
        oldDir.deleteSync();
      } else {
        oldDir.renameSync(path);
      }
    }

    // Create folder if there isn't one already
    Directory(path).createSync(recursive: true);
    return path;
  }
}