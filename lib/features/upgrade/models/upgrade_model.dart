import 'package:equatable/equatable.dart';

class UpgradeModel extends Equatable {
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

  @override
  List<Object?> get props => [assetsMap, releaseUrl];
}
