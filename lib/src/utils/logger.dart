import 'package:mason_logger/mason_logger.dart';

class AppLogger {
  final Logger _logger;
  
  AppLogger() : _logger = Logger();
  
  void info(String message) {
    _logger.info(message);
  }
  
  void success(String message) {
    _logger.success(message);
  }
  
  void error(String message) {
    _logger.err(message);
  }
  
  void warn(String message) {
    _logger.warn(message);
  }
  
  void progress(String icon, String path, String size, {String? time}) {
    final timeStr = time != null ? '  ⏱ $time' : '';
    _logger.info('  $icon $path ${size.padLeft(10)}$timeStr');
  }
  
  Progress startProgress(String message) {
    return _logger.progress(message);
  }
  
  Progress startProgressWithUpdates(String initialMessage) {
    return _logger.progress(initialMessage);
  }
  
  void updateProgress(Progress progress, String currentPath, int projectsFound) {
    final shortPath = _shortenPath(currentPath, 50);
    progress.update('🔍 Scanning $shortPath ($projectsFound found)');
  }
  
  String _shortenPath(String path, int maxLength) {
    if (path.length <= maxLength) return path;
    
    final parts = path.split('/');
    if (parts.length <= 2) return path;
    
    // Show first and last parts with ... in between
    final first = parts.first;
    final last = parts.last;
    final shortened = '$first/.../$last';
    
    if (shortened.length <= maxLength) return shortened;
    
    // If still too long, truncate the last part
    final availableForLast = maxLength - first.length - 5; // 5 for "/.../"
    if (availableForLast > 0) {
      final truncatedLast = last.length > availableForLast 
          ? '${last.substring(0, availableForLast - 3)}...'
          : last;
      return '$first/.../$truncatedLast';
    }
    
    return '...${path.substring(path.length - maxLength + 3)}';
  }
}