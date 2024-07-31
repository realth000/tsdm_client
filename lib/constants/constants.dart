import 'package:tsdm_client/features/editor/widgets/toolbar.dart';
import 'package:tsdm_client/utils/git_info.dart';

/// App full version generated from the compile environment.
const appFullVersion = '$appVersion.$gitCommitRevisionShort ($gitCommitCount) '
    '($gitCommitTimeYear-$gitCommitTimeMonth-$gitCommitTimeDay)';

/// App logo asset path. Logo format: *.svg.
const assetsLogoSvgPath = './assets/images/tsdm_client.svg';

/// App logo asset path. Logo format: *.png.
const assetsLogoPngPath = './assets/images/tsdm_client.png';

/// App license content asset path. Used in license page.
const assetsLicensePath = './assets/text/LICENSE';

/// Dart logo
const assetDartLogoPath = './assets/images/dart.svg';

/// Example avatar.
const assetExampleIndexAvatar = './assets/images/index_avatar.png';

/// Changelog till publish.
final changelogContent = () {
  final lines = changelog.split('\n');
  var beforeContent = true;
  return lines.skipWhile((e) {
    if (beforeContent && (e.startsWith('## [0.') || e.startsWith('## [1.'))) {
      beforeContent = false;
    }
    return beforeContent;
  }).join('\n');
}();

/// All features disabled by default.
///
/// Used in normal usages, disable these features to make concise toolbar
/// layout.
const defaultEditorDisabledFeatures = {
  EditorFeatures.fontFamily,
  EditorFeatures.fontSize,
  EditorFeatures.bold,
  EditorFeatures.italic,
  EditorFeatures.underline,
  EditorFeatures.superscript,
  EditorFeatures.backgroundColor,
  EditorFeatures.clearFormat,
  EditorFeatures.userMention,
  EditorFeatures.undo,
  EditorFeatures.redo,
  EditorFeatures.alignLeft,
  EditorFeatures.alignCenter,
  EditorFeatures.alignRight,
  EditorFeatures.orderedList,
  EditorFeatures.bulletList,
  EditorFeatures.cut,
  EditorFeatures.copy,
  EditorFeatures.paste,
  EditorFeatures.codeBlock,
  EditorFeatures.quoteBlock,
};

/// All features disabled by default.
///
/// Used in normal usages, disable these features to remove noisy styles.
const defaultFullScreenDisabledEditorFeatures = {
  EditorFeatures.cut,
  EditorFeatures.copy,
  EditorFeatures.paste,
};
