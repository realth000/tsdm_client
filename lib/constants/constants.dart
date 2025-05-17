import 'dart:convert';
import 'dart:ui';

import 'package:tsdm_client/features/editor/widgets/toolbar.dart';
import 'package:tsdm_client/utils/git_info.dart';

/// App full version generated from the compile environment.
const appFullVersion =
    '$appVersion.$gitCommitRevisionShort '
    '($gitCommitCountCurrentBranch) '
    '($gitCommitTimeYear-$gitCommitTimeMonth-$gitCommitTimeDay)';

/// App logo asset path. Logo format: *.svg.
const assetsLogoSvgPath = './assets/images/tsdm_client.svg';

/// App logo asset path. Logo format: *.png.
const assetsLogoPngPath = './assets/images/tsdm_client.png';

/// App license content asset path. Used in license page.
const assetsLicensePath = './assets/text/LICENSE';

/// Dart logo
const assetDartLogoPath = './assets/images/dart.svg';

/// F-Droid logo
///
/// ref: https://gitlab.com/fdroid/artwork/-/blob/master/fdroid-logo-2015/fdroid-logo.svg
const assetsFDroidLogoPath = './assets/images/fdroid-logo.svg';

/// Example avatar.
const assetExampleIndexAvatar = './assets/images/index_avatar.png';

/// Fallback avatar image.
const assetNoAvatarImagePath = './assets/images/noavatar_middle.jpg';

/// Path of all emoji related asset.
const assetEmojiDir = './assets/images/emoji/';

/// Bundled emoji.
const assetEmojiInfoPath = './assets/images/emoji/emoji.json';

/// Tiny placeholder image.
///
/// As part of workaround for the image data.
const assetPlaceholderImagePath = './assets/images/placeholder.png';

/// Changelog till publish.
///
/// Add argument to make `compute` happy.
///
// ignore: avoid_unused_parameters
Future<String> readChangelogContent(String _) async {
  // Changelog is encoded in base64 due to encoding issue on github CI Windows
  // platform, see 'scripts/read_changelog.dart' for details.
  final changelog = utf8.decode(base64Decode(encodedChangelog));
  final lines = changelog.split('\n');
  var beforeContent = true;
  return lines
      .skipWhile((e) {
        if (beforeContent && (e.startsWith('## [0.') || e.startsWith('## [1.'))) {
          beforeContent = false;
        }
        return beforeContent;
      })
      .join('\n');
}

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
  EditorFeatures.fontFamily,
  EditorFeatures.cut,
  EditorFeatures.copy,
  EditorFeatures.paste,
};

/// Medal image size fixed to 34 x 55
const medalImageSize = Size(34, 55);

/// Badge image size fixed to 184 x 100
const badgeImageSize = Size(184, 100);

/// Primary pokemon image size, height is less 100 and not fixed.
const pokemonPrimaryImageSize = Size(90, 90);

/// Not primary size fixed to 32 x 32.
const pokemonNotPrimaryImageSize = Size(32, 32);

/// Feeling image size fixed to 60 x 60.
const feelingImageSize = Size(60, 60);

/// The maximum width of html content.
///
/// Server side render it with this boundary in browser.
const htmlContentMaxWidth = 712.0;

/// Prefix of all cookie.
const cookiePrefix = 's_gkr8_682f';

/// The maximum count of recent used custom colors in editor.
const editorRecentUsedCustomColorsMaxCount = 8;
