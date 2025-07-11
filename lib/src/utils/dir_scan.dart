import 'dart:io';
import 'package:yaml/yaml.dart';

class FlutterProject {
  final Directory directory;

  FlutterProject(this.directory);

  String get path => directory.path;
}

Future<List<FlutterProject>> scanProjects(
  String rootPath, {
  String? exclude,
  void Function(String currentPath, int projectsFound)? onProgress,
  int maxDepth = 10, // Limit scanning depth to avoid going too deep
}) async {
  final projects = <FlutterProject>[];
  final rootDir = Directory(rootPath);

  if (!await rootDir.exists()) {
    throw ArgumentError('Directory does not exist: $rootPath');
  }

  await _scanRecursive(rootDir, projects, exclude, onProgress, 0, maxDepth);
  return projects;
}

Future<void> _scanRecursive(
  Directory dir,
  List<FlutterProject> projects,
  String? exclude,
  void Function(String currentPath, int projectsFound)? onProgress,
  int currentDepth,
  int maxDepth,
) async {
  // Stop if we've reached maximum depth
  if (currentDepth >= maxDepth) {
    return;
  }

  try {
    var dirCount = 0;
    await for (final entity in dir.list()) {
      if (entity is Directory) {
        final dirName = entity.path.split(Platform.pathSeparator).last;

        // Skip common non-project directories
        if (_shouldSkipDirectory(dirName)) {
          continue;
        }

        // Skip deep system paths that are unlikely to contain Flutter projects
        if (_shouldSkipPath(entity.path)) {
          continue;
        }

        dirCount++;
        // Report progress every 5 directories or when projects are found (reduced frequency)
        if (dirCount % 5 == 0) {
          onProgress?.call(entity.path, projects.length);
        }

        // Check if this directory is a Flutter project
        final pubspecFile = File('${entity.path}/pubspec.yaml');
        if (await pubspecFile.exists()) {
          if (await _isFlutterProject(pubspecFile)) {
            projects.add(FlutterProject(entity));
            onProgress?.call(entity.path,
                projects.length); // Always update when projects found
            continue; // Don't recurse into Flutter projects
          }
        }

        // Recurse into subdirectories with increased depth
        await _scanRecursive(
            entity, projects, exclude, onProgress, currentDepth + 1, maxDepth);
      }
    }
  } catch (e) {
    // Skip directories we can't access
  }
}

bool _shouldSkipDirectory(String dirName) {
  // Skip all hidden directories (starting with .)
  if (dirName.startsWith('.')) {
    return true;
  }

  // Skip system and common non-development directories
  const skipDirs = {
    // Platform-specific Flutter directories
    'ios',
    'android',
    'web',
    'linux',
    'macos',
    'windows',

    // Flutter version management
    'fvm',
  };

  return skipDirs.contains(dirName);
}

bool _shouldSkipPath(String fullPath) {
  // Skip paths that contain certain system or cache patterns
  final skipPatterns = [
    '/Library/',
    '/System/',
    '/Applications/',
    '/.git/',
    '/.svn/',
    '/node_modules/',
    '/venv/',
    '/vendor/',
    '/.vscode/',
    '/.idea/',
    '/Cache/',
    '/Caches/',
    '/temp/',
    '/log/',
    '/logs/',
  ];

  return skipPatterns.any((pattern) => fullPath.contains(pattern));
}

Future<bool> _isFlutterProject(File pubspecFile) async {
  try {
    final content = await pubspecFile.readAsString();
    final yaml = loadYaml(content);

    if (yaml is YamlMap) {
      return yaml.containsKey('flutter');
    }
    return false;
  } catch (e) {
    return false;
  }
}
