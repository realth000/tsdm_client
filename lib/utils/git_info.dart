import 'package:gitsumu/annotation.dart';

part '../generated/utils/git_info.g.dart';

/// Embedded changelog till now.
@CustomInfo('changelog')
const readCurrentChangelog = ['cat', './CHANGELOG.md'];
