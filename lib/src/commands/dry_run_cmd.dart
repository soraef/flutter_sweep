import 'dart:io';
import 'package:args/command_runner.dart';
import '../utils/dir_scan.dart';
import '../utils/size.dart';
import '../utils/logger.dart';

class DryRunCmd extends Command {
  @override
  final String name = 'dry-run';
  
  @override
  final String description = 'Analyze cleanable size without actually cleaning.';

  DryRunCmd() {
    argParser
      ..addFlag(
        'verbose',
        abbr: 'v',
        help: 'Verbose output',
        negatable: false,
      )
      ..addOption(
        'exclude',
        help: 'Glob pattern to exclude directories',
      );
  }

  @override
  Future<void> run() async {
    final logger = AppLogger();
    final root = argResults!.rest.isNotEmpty ? argResults!.rest.first : '.';
    final exclude = argResults!['exclude'] as String?;

    // Scan for projects with progress updates
    final progress = logger.startProgressWithUpdates('🔍 Starting scan...');
    List<FlutterProject> projects;
    try {
      projects = await scanProjects(
        root, 
        exclude: exclude,
        onProgress: (currentPath, projectsFound) {
          logger.updateProgress(progress, currentPath, projectsFound);
        },
      );
    } catch (e) {
      progress.complete('❌ Failed to scan directory');
      logger.error('Error scanning directory: $e');
      exitCode = 1;
      return;
    }
    progress.complete('🔍 Found ${projects.length} Flutter projects');

    if (projects.isEmpty) {
      logger.warn('No Flutter projects found in $root');
      return;
    }

    // Calculate sizes
    final results = <Map<String, dynamic>>[];
    var totalSize = 0;

    final sizeProgress = logger.startProgress('📊 Calculating sizes...');
    
    for (final project in projects) {
      final size = await getCleanableSize(project.directory);
      totalSize += size;
      
      results.add({
        'path': project.path,
        'size': size,
        'size_human': formatBytes(size),
      });
    }
    
    sizeProgress.complete();

    // Output results in pretty format
    logger.info('🔍 Found ${projects.length} Flutter projects');
    logger.info('📊 Cleanable sizes:');
    
    for (final result in results) {
      logger.progress('📁', result['path'] as String, result['size_human'] as String);
    }
    
    logger.success('💾 Total cleanable size: ${formatBytes(totalSize)}');

  }
}