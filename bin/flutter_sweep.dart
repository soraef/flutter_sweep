import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:flutter_sweep/src/commands/run_cmd.dart';
import 'package:flutter_sweep/src/commands/dry_run_cmd.dart';

void main(List<String> args) async {
  final runner = CommandRunner('flutter_sweep', 'Sweep build junk fast.')
    ..addCommand(RunCmd())
    ..addCommand(DryRunCmd());

  try {
    await runner.run(args);
  } on UsageException catch (e) {
    stderr.writeln(e);
    exitCode = 64;
  }
}
