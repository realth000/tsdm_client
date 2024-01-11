class UpgradeModel {
  const UpgradeModel({
    required this.releaseVersion,
    required this.releaseNotes,
    required this.assetsMap,
    required this.releaseUrl,
  });

  final String releaseVersion;
  final String releaseNotes;
  final Map<String, String> assetsMap;
  final String releaseUrl;
}
