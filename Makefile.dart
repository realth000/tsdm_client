// ignore_for_file: file_names
// ignore_for_file: avoid_print

import 'dart:io';

Future<int> main(List<String> args) async {
  var ret = 0;
  print('<make> starting with args $args');
  if (args.isEmpty) {
    ret = await runBuildRunner();
    if (ret == 0) {
      ret = await runDrift();
    }
  } else {
    ret = switch (args.first) {
      'build' || 'b' => await runBuildRunner(),
      'gitsumu' || 'g' => await runGitsumu(),
      'drift' || 'd' => await runDrift(),
      final v => () {
          stderr.writeln('unknown arg: $v');
          return 1;
        }(),
    };
  }

  if (ret == 0) {
    print('<make> done');
  } else {
    stderr.writeln('<make> failed with code $ret');
  }
  return ret;
}

Future<int> runBuildRunner() async {
  print('<make> running build runner...');
  final p = await Process.run('dart', ['run', 'build_runner', 'build', '-d']);
  stdout.write(p.stdout);
  stderr.write(p.stderr);
  if (p.exitCode != 0) {
    stderr.writeln('failed to run build_runner, ret=${p.exitCode}');
    return 1;
  }
  return 0;
}

Future<int> runGitsumu() async {
  print('<make> running gitsumu...');
  final p = await Process.run('dart', ['run', 'gitsumu']);
  stdout.write(p.stdout);
  stderr.write(p.stderr);
  if (p.exitCode != 0) {
    stderr.writeln('failed to run gitsumu, ret=${p.exitCode}');
    return 1;
  }

  return 0;
}

Future<int> runDrift() async {
  print('<make> running drift...');
  final p = await Process.run('dart', [
    'run',
    'drift_dev',
    'schema',
    'dump',
    'lib/shared/providers/storage_provider/models/database/database.dart',
    'lib/shared/providers/storage_provider/models/database/schema/migration/',
  ]);
  final ret = p.exitCode;
  stdout.write(p.stdout);
  stderr.write(p.stderr);
  if (ret != 0) {
    stderr.writeln('failed to dump drift schema, ret=$ret');
    return 1;
  }

  final p2 = await Process.run('dart', [
    'run',
    'drift_dev',
    'schema',
    'steps',
    'lib/shared/providers/storage_provider/models/database/schema/migration/',
    'lib/shared/providers/storage_provider/models/database/schema/schema_versions.dart',
  ]);
  final ret2 = p2.exitCode;
  if (ret2 != 0) {
    stderr.writeln('failed to step drift migration, ret=$ret2');
    return 1;
  }

  final p3 = await Process.run('dart', [
    'run',
    'drift_dev',
    'schema',
    'generate',
    'lib/shared/providers/storage_provider/models/database/schema/migration/',
    'test/data/generated_migrations/',
  ]);
  final ret3 = p3.exitCode;
  if (ret3 != 0) {
    stderr.writeln('failed to generate drift test data, ret=$ret3');
    return 1;
  }

  return 0;
}
