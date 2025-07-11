import 'dart:io';

Future<int> dirSize(Directory dir) async {
  int totalSize = 0;
  
  try {
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) {
        try {
          final stat = await entity.stat();
          totalSize += stat.size;
        } catch (e) {
          // Skip files we can't access
        }
      }
    }
  } catch (e) {
    // Skip directories we can't access
  }
  
  return totalSize;
}

Future<int> getCleanableSize(Directory projectDir) async {
  int totalSize = 0;
  
  final cleanableDirs = [
    'build',
    '.dart_tool',
    'android/.gradle',
    'android/build',
    'ios/build',
    'web/build',
    'linux/build',
    'macos/build',
    'windows/build',
  ];
  
  for (final dirName in cleanableDirs) {
    final dir = Directory('${projectDir.path}/$dirName');
    if (await dir.exists()) {
      totalSize += await dirSize(dir);
    }
  }
  
  return totalSize;
}

String formatBytes(int bytes) {
  if (bytes < 1024) return '${bytes}B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
  if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
}