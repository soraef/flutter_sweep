import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:pool/pool.dart';
import '../utils/dir_scan.dart';
import '../utils/size.dart';
import '../utils/clean.dart';
import '../utils/logger.dart';

class RunCmd extends Command {
  @override
  final String name = 'run';
  
  @override
  final String description = 'Run flutter clean for all projects.';

  RunCmd() {
    argParser
      ..addOption(
        'concurrency',
        abbr: 'j',
        help: 'Number of parallel jobs',
        defaultsTo: Platform.numberOfProcessors.toString(),
      )
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
    final concurrency = int.tryParse(argResults!['concurrency'] as String) ?? Platform.numberOfProcessors;
    final exclude = argResults!['exclude'] as String?;

    // Check if flutter is available
    if (!await isFlutterAvailable()) {
      logger.error('Flutter is not available. Please install Flutter and add it to your PATH.');
      exitCode = 1;
      return;
    }

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
    progress.complete('🔍 Scanning … ${projects.length} Flutter projects detected');

    if (projects.isEmpty) {
      logger.warn('No Flutter projects found in $root');
      return;
    }

    // Run cleaning with parallel execution
    logger.info('⚡ Cleaning (${concurrency} parallel jobs) …');
    
    final pool = Pool(concurrency);
    var successCount = 0;
    var failedCount = 0;
    var totalFreed = 0;

    final stopwatch = Stopwatch()..start();

    await Future.wait(projects.map((project) => pool.withResource(() async {
      final projectStopwatch = Stopwatch()..start();
      
      // Get size before cleaning
      final sizeBefore = await getCleanableSize(project.directory);
      
      // Clean the project
      final success = await cleanProject(project.directory);
      
      projectStopwatch.stop();
      
      if (success) {
        successCount++;
        totalFreed += sizeBefore;
        logger.progress(
          '✔',
          project.path,
          formatBytes(sizeBefore),
          time: '${(projectStopwatch.elapsedMilliseconds / 1000).toStringAsFixed(1)} s',
        );
      } else {
        failedCount++;
        logger.progress('✖', project.path, '—', time: '🚫 flutter not found');
      }
    })));

    stopwatch.stop();

    // Summary
    logger.success(
      '🧹  Finished in ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(1)} s. '
      'Freed ${formatBytes(totalFreed)} ($successCount projects OK, $failedCount failed)'
    );

    if (failedCount > 0) {
      exitCode = 1;
    }
  }
}