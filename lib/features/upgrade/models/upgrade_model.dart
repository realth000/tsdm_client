import 'package:equatable/equatable.dart';

/// Model describes the info about available upgrade.
class UpgradeModel extends Equatable {
  /// Constructor.
  const UpgradeModel({
    required this.releaseVersion,
    required this.releaseNotes,
    required this.assetsMap,
    required this.releaseUrl,
  });

  /// Lated releae version.
  ///
  /// This version has a "v" prefix.
  final String releaseVersion;

  /// Release notes of the latest version.
  final String releaseNotes;

  /// Assets available.
  final Map<String, String> assetsMap;

  /// Url to fetch release download info.
  final String releaseUrl;

  @override
  List<Object?> get props => [assetsMap, releaseUrl];
}
