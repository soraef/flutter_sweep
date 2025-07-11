import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:flutter_osouji/src/commands/run_cmd.dart';
import 'package:flutter_osouji/src/commands/dry_run_cmd.dart';

void main(List<String> args) async {
  final runner = CommandRunner('flutter_osouji', 'おそうじ - Fast Flutter project cleaner')
    ..addCommand(RunCmd())
    ..addCommand(DryRunCmd());

  try {
    await runner.run(args);
  } on UsageException catch (e) {
    stderr.writeln(e);
    exitCode = 64;
  }
}
