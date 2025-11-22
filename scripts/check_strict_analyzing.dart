// Printing as output.
// ignore_for_file: avoid_print

import 'dart:io';

const analysisOptionsLightweight = './analysis_options.yaml';
const analysisOptionsLightweightBackup = './analysis_options.yaml.bak';
const analysisOptionsStrict = './analysis_options.strict.yaml';

Future<int> main() async {
  final lightWeightOptionsFile = File(analysisOptionsLightweight);
  final strictOptionsFile = File(analysisOptionsStrict);
  if (!lightWeightOptionsFile.existsSync() || !strictOptionsFile.existsSync()) {
    print('failed to run strict check: analysis options file not exists');
    return 1;
  }

  // Backup options.
  await lightWeightOptionsFile.copy(analysisOptionsLightweightBackup);
  await strictOptionsFile.copy(analysisOptionsLightweight);

  // Analyzing
  final p = await Process.run('dart', ['analyze', '--fatal-warnings', '--fatal-infos', 'lib']);

  final ret = p.exitCode;
  stdout.write(p.stdout);
  stderr.write(p.stderr);
  if (ret != 0) {
    stderr.writeln('strict check no passed, ret=$ret');
  }

  // Restore options.
  await File(analysisOptionsLightweightBackup).rename(lightWeightOptionsFile.path);

  return exit(ret);
}
