## 0.2.0

### Features
- Smart Flutter project detection via `pubspec.yaml` scanning
- High-performance parallel execution with configurable concurrency
- Real-time scanning progress with current directory display
- Intelligent directory filtering (system folders, hidden dirs, fvm, etc.)
- Size analysis before and after cleaning
- Beautiful CLI interface with animated progress indicators
- Two operation modes: `run` (clean) and `dry-run` (analyze only)

### Commands
- `flutter_sweep run [directory] [options]` - Clean Flutter projects
- `flutter_sweep dry-run [directory] [options]` - Analyze cleanable size

### Options
- `--concurrency, -j` - Number of parallel jobs (default: CPU cores)
- `--exclude` - Glob pattern to exclude directories  
- `--verbose, -v` - Verbose output

### Performance
- ~1.9s per GB cleaned on modern SSD systems
- Smart skipping of system/cache/hidden directories
- Maximum 10-level depth scanning
- Memory-efficient streaming directory traversal
