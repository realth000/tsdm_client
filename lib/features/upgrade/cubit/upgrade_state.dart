part of 'upgrade_cubit.dart';

/// Status of upgrade action.
enum UpgradeStatus {
  /// Ready for response.
  ready,

  /// Fetching latest version info.
  fetching,

  /// Downloading the latest application.
  downloading,

  /// Failed to download due to permission denied.
  noPermission,

  /// No suitable version found for current environment.
  noVersionFound,

  /// Error occurred.
  failed,

  /// Download success.
  success,
}

/// State of upgrading.
@MappableClass()
class UpgradeState with UpgradeStateMappable {
  /// Constructor.
  const UpgradeState({
    this.status = UpgradeStatus.ready,
    this.upgradeModel,
    this.downloadDir = '',
    this.fileName = '',
    this.downloadStatus = const DownloadStatus(recv: 0, total: 0),
  });

  /// Status.
  final UpgradeStatus status;

  /// Model that contains upgrade info.
  final UpgradeModel? upgradeModel;

  /// Save path.
  final String downloadDir;

  /// Latest file version file name.
  final String fileName;

  /// Status of download assets.
  final DownloadStatus downloadStatus;
}
