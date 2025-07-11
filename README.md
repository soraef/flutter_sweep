# flutter_sweep

Fast parallel Flutter project cleaner that sweeps build artifacts.

## Features

- 🔍 **Smart Detection**: Automatically finds Flutter projects by scanning `pubspec.yaml` files
- ⚡ **Parallel Execution**: Leverages multiple CPU cores for maximum performance  
- 📊 **Size Analysis**: Shows how much space you'll free before and after cleaning
- 🎨 **Beautiful Output**: Colorful, progress-aware CLI interface with real-time scanning progress
- 🚀 **High Performance**: ~1.9s per GB cleaned on modern SSD systems
- 📈 **Progress Tracking**: Real-time scanning progress with current directory and project count

## Installation

```bash
# Install from pub.dev (when published)
dart pub global activate flutter_sweep

# Or run locally
dart pub get
dart bin/flutter_sweep.dart run
```

## Usage

### Basic Commands

```bash
# Clean all Flutter projects in current directory (default)
flutter_sweep run

# Clean projects in specific directory with 8 parallel jobs  
flutter_sweep run ./my_projects --concurrency=8

# Dry run - see what would be cleaned without actually cleaning
flutter_sweep dry-run

# Clean with verbose output
flutter_sweep run --verbose
```

### Expected Output

```console
# Run mode with real-time scanning progress
$ flutter_sweep run ./dev --concurrency=8
🔍 Scanning /dev/projects/app1 (0 found)...
🔍 Scanning /dev/projects/app2 (1 found)...
🔍 Scanning /dev/projects/app3 (2 found)...
🔍 Scanning … 12 Flutter projects detected
⚡ Cleaning (8 parallel jobs) …
  ✔ /dev/app1                784 MB  ⏱ 3.2 s
  ✔ /dev/app2               1.1 GB   ⏱ 2.9 s
  ✖ /dev/app3                  —     🚫 flutter not found
  …
🧹  Finished in 12.7 s. Freed 8.6 GB (11 projects OK, 1 failed)

# Dry run mode
$ flutter_sweep dry-run
🔍 Found 12 Flutter projects
📊 Cleanable sizes:
  📁 /dev/app1               784 MB
  📁 /dev/app2               1.1 GB
  …
💾 Total cleanable size: 9.4 GB
```

### Options

| Option | Description | Default |
|--------|-------------|---------|
| `--concurrency, -j` | Number of parallel jobs | Number of CPU cores |
| `--exclude` | Glob pattern to exclude directories | None |
| `--verbose, -v` | Verbose output | false |

### Examples

```bash
# Clean with custom concurrency
flutter_sweep run --concurrency=4

# Exclude example directories  
flutter_sweep run --exclude "**/example/**"

# Verbose output
flutter_sweep run --verbose
```

## How it Works

1. **Discovery**: Recursively scans directories for `pubspec.yaml` files
2. **Validation**: Checks if projects contain Flutter dependencies (`flutter:` key)
3. **Analysis**: Calculates size of cleanable directories (`build/`, `.dart_tool/`, etc.)
4. **Execution**: Runs `flutter clean` in parallel across all found projects
5. **Reporting**: Shows cleaned size and execution time

## Performance

- **Smart Skipping**: Avoids scanning `.git`, `node_modules`, and other non-project directories
- **Parallel I/O**: Maximizes disk throughput with concurrent operations  
- **Memory Efficient**: Streams directory contents instead of loading everything into memory

Typical performance: ~1.9s per GB cleaned on modern SSD systems with 8+ cores.

## Development

```bash
# Clone and setup
git clone <repository>
cd flutter_sweep
dart pub get

# Run tests
dart test

# Run locally
dart bin/flutter_sweep.dart run ./test_projects
dart bin/flutter_sweep.dart dry-run

# Run with global activation (for testing)
dart pub global activate --source path .
flutter_sweep run
```

## Project Structure

```
flutter_sweep/
├── bin/
│   └── flutter_sweep.dart          # CLI entry point
├── lib/
│   ├── flutter_sweep.dart          # Library exports
│   └── src/
│       ├── commands/
│       │   ├── run_cmd.dart         # Run command implementation
│       │   └── dry_run_cmd.dart     # Dry-run command implementation
│       └── utils/
│           ├── dir_scan.dart        # Directory scanning utilities
│           ├── size.dart            # Size calculation utilities
│           ├── clean.dart           # Flutter clean execution
│           └── logger.dart          # Logging utilities
├── test/
│   └── flutter_sweep_test.dart      # Unit tests
└── pubspec.yaml                     # Dependencies
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Run `dart test` to ensure tests pass
6. Submit a pull request

## License

MIT License - see LICENSE file for details.
