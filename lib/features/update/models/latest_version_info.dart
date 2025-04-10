import 'package:dart_mappable/dart_mappable.dart';

part 'latest_version_info.mapper.dart';

/// The info about latest version fetched from server.
@MappableClass()
final class LatestVersionInfo with LatestVersionInfoMappable {
  /// Constructor.
  const LatestVersionInfo({required this.version, required this.versionCode, required this.changelog});

  /// Version name.
  final String version;

  /// Version code.
  final int versionCode;

  /// Changelog on the latest version.
  final String changelog;
}
