import 'package:gitsumu/annotation.dart';

part '../generated/utils/git_info.g.dart';

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
  'Get-Content',
  '-Encoding',
  'utf8',
  './CHANGELOG.md',
];
