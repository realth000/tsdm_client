// Printing as output.
// ignore_for_file: avoid_print

import 'dart:io';

void report(String filePath, int lineNumber) {
  print('[lint]: missing tooltip at $filePath:$lineNumber');
}

Future<int> main(List<String> args) async {
  if (args.isEmpty) {
    print('invalid args');
    return 1;
  }

  final rootDir = args.first;

  for (final entry in Directory(rootDir).listSync(recursive: true)) {
    if (entry.statSync().type != FileSystemEntityType.file) {
      continue;
    }
    final entryPath = entry.path;
    if (!entryPath.endsWith('.dart') || ['.g.dart', '.mapper.dart', '.freezed.dart'].any(entryPath.endsWith)) {
      continue;
    }

    final dartLines = await File(entryPath).readAsLines();
    int? targetLine;
    // Assume the start end end of `IconButton` lines have the same indent.
    int? indent;
    bool? hasTooltip;
    for (final (lineNumber, line) in dartLines.indexed) {
      if (line.contains('IconButton(')) {
        // Single line.
        if (line.endsWith(',') || line.endsWith(';')) {
          if (!line.contains('tooltip:')) {
            report(entryPath, lineNumber + 1);
            targetLine = null;
            indent = null;
            hasTooltip = false;
          }
          continue;
        }

        // Prepare for check.
        targetLine = lineNumber + 1;
        indent = line.indexOf('IconButton(');
        hasTooltip = false;
      }

      // Multi line.

      if (targetLine == null) {
        continue;
      }

      if (line.trim().startsWith('tooltip:')) {
        hasTooltip = true;
        continue;
      }

      if (line.startsWith('${''.padLeft(indent!)})')) {
        // Leave scope of IconButton.
        if (hasTooltip == false) {
          report(entryPath, targetLine);
        }

        targetLine = null;
        indent = null;
        hasTooltip = false;
      }
    }
  }

  return 0;
}
