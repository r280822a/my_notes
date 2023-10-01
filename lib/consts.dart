class Consts{
  // Checkbox symbols
  static const String checkboxStr = "☐ ";
  static const String checkboxTickedStr = "☑ ";

  // Matches any string matching "![...](...)" with '...' being anything
  static RegExp imageRegex = RegExp(r'!\[(.*?)\]\((.*?)\)');
}