import 'dart:async';
import 'dart:io';

Future<int> main() async {
  final content = await File('./CHANGELOG.md').readAsString();
  stdout.write(content);
  await stdout.flush();
  return 0;
}
