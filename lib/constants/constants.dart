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
