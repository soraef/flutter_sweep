# flutter_osouji

**おそうじ (osouji)** means "cleaning" in Japanese 🧹

Fast parallel Flutter project cleaner that sweeps build artifacts with smart detection and beautiful progress tracking.

## Why "おそうじ"?

In Japanese culture, cleaning (おそうじ/osouji) is not just about tidiness—it's about creating a fresh, organized environment that promotes productivity and peace of mind. This tool embodies that philosophy by efficiently cleaning up Flutter project build artifacts, giving you a clean slate to work with.

Just like the traditional Japanese practice of year-end cleaning (大掃除/oosouji), flutter_osouji helps you maintain a clutter-free development environment! 🎌

## Features

- 🔍 **Smart Detection**: Automatically finds Flutter projects by scanning `pubspec.yaml` files
- ⚡ **Parallel Execution**: Leverages multiple CPU cores for maximum performance  
- 📊 **Size Analysis**: Shows how much space you'll free before and after cleaning
- 🎨 **Beautiful Output**: Colorful, progress-aware CLI interface with real-time scanning progress
- 🚀 **High Performance**: ~1.9s per GB cleaned on modern SSD systems
- 📈 **Progress Tracking**: Real-time scanning progress with current directory and project count

## Installation

```bash
# Install from pub.dev
dart pub global activate flutter_osouji

# Or run locally
dart pub get
dart bin/flutter_osouji.dart run
```

## Usage

### Basic Commands

```bash
# Clean all Flutter projects in current directory (default)
flutter_osouji run

# Clean projects in specific directory with 8 parallel jobs  
flutter_osouji run ./my_projects --concurrency=8

# Dry run - see what would be cleaned without actually cleaning
flutter_osouji dry-run

# Clean with verbose output
flutter_osouji run --verbose
```

### Expected Output

```console
# Run mode with real-time scanning progress
$ flutter_osouji run ./dev --concurrency=8
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
$ flutter_osouji dry-run
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
flutter_osouji run --concurrency=4

# Exclude example directories  
flutter_osouji run --exclude "**/example/**"

# Verbose output
flutter_osouji run --verbose
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
cd flutter_osouji
dart pub get

# Run tests
dart test

# Run locally
dart bin/flutter_osouji.dart run ./test_projects
dart bin/flutter_osouji.dart dry-run

# Run with global activation (for testing)
dart pub global activate --source path .
flutter_osouji run
```

## Project Structure

```
flutter_osouji/
├── bin/
│   └── flutter_osouji.dart          # CLI entry point
├── lib/
│   ├── flutter_osouji.dart          # Library exports
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
│   └── flutter_osouji_test.dart      # Unit tests
└── pubspec.yaml                     # Dependencies
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Run `dart test` to ensure tests pass
6. Submit a pull request

## About the Name

**flutter_osouji** combines Flutter development with the Japanese concept of cleaning (おそうじ). In Japan, cleaning is considered a meditative practice that brings clarity and focus. Similarly, this tool brings clarity to your development environment by efficiently removing build clutter.

The name reflects our philosophy: development should be clean, organized, and mindful—just like traditional Japanese practices! 🇯🇵

## License

MIT License - see LICENSE file for details.
