import 'package:gitsumu/annotation.dart';

part 'git_info.g.dart';

/// Embedded changelog till now.
@CustomInfo(
  'changelog',
  platforms: {
    CustomInfoPlatforms.linux,
    CustomInfoPlatforms.macos,
  },
)
const readCurrentChangelog = ['cat', './CHANGELOG.md'];

/// Embedded changelog till now.
@CustomInfo(
  'changelog',
  platforms: {
    CustomInfoPlatforms.windows,
  },
)
const readCurrentChangelogWindows = [
  'dart',
  'scripts/read_changelog.dart',
];
