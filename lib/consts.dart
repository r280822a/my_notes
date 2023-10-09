import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// Stores all reused constants/variables, and functions
class Consts{
  // Checkbox symbols
  static const String checkboxStr = "☐ ";
  static const String checkboxTickedStr = "☑ ";

  // For any string matching "![...](...)", with '...' being anything
  static RegExp imageRegex = RegExp(r'!\[(.*?)\]\((.*?)\)');

  static Future<String> getLocalImagesPath() async {
    // Get path to local images folder

    Directory docDir = await getApplicationDocumentsDirectory();
    String docPath = docDir.path.toString();
    String path = p.join(docPath, "local_images"); // Full path to local images

    // Create folder if there isn't one already
    Directory(path).createSync(recursive: true);
    return path;
  }
}