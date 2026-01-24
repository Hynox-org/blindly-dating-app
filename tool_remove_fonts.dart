import 'dart:io';

void main() async {
  final dir = Directory('lib');
  if (!dir.existsSync()) {
    print('lib directory not found');
    return;
  }

  final files = dir
      .listSync(recursive: true)
      .where((f) => f is File && f.path.endsWith('.dart'))
      .cast<File>();

  for (final file in files) {
    try {
      final lines = await file.readAsLines();
      final newLines = <String>[];
      bool modified = false;

      for (final line in lines) {
        // Check for hardcoded families
        // We match strictly on the property usage
        if (line.contains("fontFamily: 'Poppins'") ||
            line.contains("fontFamily: 'Inter'") ||
            line.contains("fontFamily: \"Poppins\"") ||
            line.contains("fontFamily: \"Inter\"")) {
          modified = true;
          // Skip this line (remove it)
          continue;
        }
        newLines.add(line);
      }

      if (modified) {
        await file.writeAsString(newLines.join('\n'));
        print('Updated ${file.path}');
      }
    } catch (e) {
      print('Error processing ${file.path}: $e');
    }
  }
  print('Done.');
}
