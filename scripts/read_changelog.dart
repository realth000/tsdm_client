import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// This file is a workaround for the encoding issue on github CI platforms
/// where on Windows the changelog got messy when both read and write through
/// stdout because of the non-ASCII characters in changelog.
///
/// Here the changelog is read and encoded to base64 so that when every time
/// intend to use the changelog text, a decoding process is required.
Future<int> main() async {
  final content = await File('./CHANGELOG.md').readAsBytes();
  final encodedContent = base64Encode(content);
  stdout.write(encodedContent);
  await stdout.flush();
  return 0;
}
