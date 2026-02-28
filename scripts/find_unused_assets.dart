import 'dart:io';

void main() {
  final assetsDir = Directory('assets');
  if (!assetsDir.existsSync()) {
    print('No assets directory found.');
    return;
  }

  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    print('No lib directory found.');
    return;
  }

  // Get all files in assets directory
  final assetFiles = assetsDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) {
        final ext = file.path.split('.').last.toLowerCase();
        return [
          'png',
          'jpg',
          'jpeg',
          'gif',
          'svg',
          'webp',
          'ttf',
          'otf',
        ].contains(ext);
      })
      .map((file) => file.path.replaceAll('\\', '/'))
      .toList();

  // Read all dart files
  final dartFiles = libDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .toList();

  final allDartCode = StringBuffer();
  for (final file in dartFiles) {
    allDartCode.write(file.readAsStringSync());
  }

  final codeStr = allDartCode.toString();

  final unusedAssets = <String>[];
  for (final asset in assetFiles) {
    final fileName = asset.split('/').last;
    final fileNameWithoutExt = fileName.split('.').first;

    // Check if the filename is mentioned anywhere in the code.
    // This is a naive check but works well to catch obviously unused assets.
    if (!codeStr.contains(fileName) && !codeStr.contains(fileNameWithoutExt)) {
      unusedAssets.add(asset);
    }
  }

  final outFile = File('unused_assets_out.txt');
  outFile.writeAsStringSync(
    'Found ${unusedAssets.length} potentially unused assets:\n',
  );
  for (final asset in unusedAssets) {
    outFile.writeAsStringSync('- $asset\n', mode: FileMode.append);
  }
  print('Done. Results saved to unused_assets_out.txt');
}
