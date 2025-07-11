import 'dart:io';

Future<bool> cleanProject(Directory projectDir) async {
  try {
    final result = await Process.run(
      'flutter',
      ['clean'],
      workingDirectory: projectDir.path,
    );
    
    return result.exitCode == 0;
  } catch (e) {
    return false;
  }
}

Future<bool> isFlutterAvailable() async {
  try {
    final result = await Process.run('flutter', ['--version']);
    return result.exitCode == 0;
  } catch (e) {
    return false;
  }
}