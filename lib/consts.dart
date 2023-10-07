// Stores all reused constants
class Consts{
  // Checkbox symbols
  static const String checkboxStr = "☐ ";
  static const String checkboxTickedStr = "☑ ";

  // For any string matching "![...](...)", with '...' being anything
  static RegExp imageRegex = RegExp(r'!\[(.*?)\]\((.*?)\)');
}