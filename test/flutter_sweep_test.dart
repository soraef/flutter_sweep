import 'dart:io';
import 'package:test/test.dart';
import 'package:flutter_sweep/src/utils/dir_scan.dart';
import 'package:flutter_sweep/src/utils/size.dart';

void main() {
  group('Directory Scanning', () {
    late Directory tempDir;
    
    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('flutter_sweep_test');
    });
    
    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });
    
    test('should detect Flutter project with pubspec.yaml containing flutter', () async {
      // Create a mock Flutter project
      final projectDir = Directory('${tempDir.path}/test_project');
      await projectDir.create();
      
      final pubspecFile = File('${projectDir.path}/pubspec.yaml');
      await pubspecFile.writeAsString('''
name: test_project
description: A test Flutter project
environment:
  sdk: '>=3.0.0 <4.0.0'
dependencies:
  flutter:
    sdk: flutter
''');
      
      final projects = await scanProjects(tempDir.path);
      
      expect(projects.length, equals(1));
      expect(projects.first.path, equals(projectDir.path));
    });
    
    test('should not detect non-Flutter project', () async {
      // Create a mock non-Flutter project
      final projectDir = Directory('${tempDir.path}/test_project');
      await projectDir.create();
      
      final pubspecFile = File('${projectDir.path}/pubspec.yaml');
      await pubspecFile.writeAsString('''
name: test_project
description: A test Dart project
environment:
  sdk: '>=3.0.0 <4.0.0'
dependencies:
  http: ^1.0.0
''');
      
      final projects = await scanProjects(tempDir.path);
      
      expect(projects.length, equals(0));
    });
    
    test('should skip common non-project directories', () async {
      // Create directories that should be skipped
      final skipDirs = ['.git', '.dart_tool', 'build', 'node_modules'];
      
      for (final dirName in skipDirs) {
        final dir = Directory('${tempDir.path}/$dirName');
        await dir.create();
        
        final pubspecFile = File('${dir.path}/pubspec.yaml');
        await pubspecFile.writeAsString('''
name: test_project
dependencies:
  flutter:
    sdk: flutter
''');
      }
      
      final projects = await scanProjects(tempDir.path);
      
      expect(projects.length, equals(0));
    });
  });
  
  group('Size Calculation', () {
    test('should format bytes correctly', () {
      expect(formatBytes(512), equals('512B'));
      expect(formatBytes(1024), equals('1.0KB'));
      expect(formatBytes(1024 * 1024), equals('1.0MB'));
      expect(formatBytes(1024 * 1024 * 1024), equals('1.0GB'));
      expect(formatBytes(1536), equals('1.5KB'));
    });
  });
}
