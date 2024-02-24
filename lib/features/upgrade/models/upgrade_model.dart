part of 'models.dart';

/// Model describes the info about available upgrade.
@MappableClass()
class UpgradeModel with UpgradeModelMappable {
  /// Constructor.
  const UpgradeModel({
    required this.releaseVersion,
    required this.releaseNotes,
    required this.assetsMap,
    required this.releaseUrl,
  });

  /// Latest release version.
  ///
  /// This version has a "v" prefix.
  final String releaseVersion;

  /// Release notes of the latest version.
  final String releaseNotes;

  /// Assets available.
  final Map<String, String> assetsMap;

  /// Url to fetch release download info.
  final String releaseUrl;
}
