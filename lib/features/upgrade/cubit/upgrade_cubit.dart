import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:fpdart/fpdart.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:tsdm_client/features/upgrade/models/models.dart';
import 'package:tsdm_client/features/upgrade/repository/models/models.dart';
import 'package:tsdm_client/features/upgrade/repository/upgrade_repository.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:tsdm_client/utils/platform.dart';
import 'package:universal_html/html.dart' as uh;

part 'upgrade_cubit.mapper.dart';
part 'upgrade_state.dart';

extension _FilterExt on Map<String, String> {
  // /// Filter on [Map] and return the first value with key end
  // /// with [condition].
  // String? filter(String condition) {
  //   for (final entry in entries) {
  //     if (entry.key.endsWith(condition)) {
  //       return entry.value;
  //     }
  //   }
  //   return null;
  // }

  /// Filter on [Map] and return the first pair end
  /// with [condition].
  (String, String)? filterPairs(String condition) {
    for (final entry in entries) {
      if (entry.key.endsWith(condition)) {
        return (entry.key, entry.value);
      }
    }
    return null;
  }
}

/// Cubit of upgrading the app.
class UpgradeCubit extends Cubit<UpgradeState> with LoggerMixin {
  /// Constructor.
  UpgradeCubit({required UpgradeRepository upgradeRepository})
      : _upgradeRepository = upgradeRepository,
        super(const UpgradeState()) {
    _subscription = _upgradeRepository.downloadStatus.listen((status) {
      emit(
        state.copyWith(
          status: status.finished ? UpgradeStatus.success : null,
          downloadStatus: status,
        ),
      );
    });
  }

  final UpgradeRepository _upgradeRepository;
  late final StreamSubscription<DownloadStatus> _subscription;

  /// Fetch the latest release info from github.
  Future<void> fetchLatestInfo() async {
    emit(state.copyWith(status: UpgradeStatus.fetching));
    await _upgradeRepository.fetchLatestInfo().mapLeft((e) {
      handle(e);
      error('failed to fetch latest release info: $e');
      emit(state.copyWith(status: UpgradeStatus.failed));
    }).map((v) async {
      switch (await _parseUpgradeModel(v).run()) {
        case None():
          error('failed to parse model');
          emit(state.copyWith(status: UpgradeStatus.failed));
        case Some(:final value):
          emit(
            state.copyWith(status: UpgradeStatus.ready, upgradeModel: value),
          );
      }
    }).run();
  }

  /// Download the latest version assets.
  Future<void> downloadLatestVersion() async {
    if (state.upgradeModel == null) {
      return;
    }
    final upgradeModel = state.upgradeModel;

    AndroidDeviceInfo? androidInfo;
    // Check permission first.
    if (isAndroid) {
      androidInfo = await DeviceInfoPlugin().androidInfo;
      // Check storage permission.
      if (androidInfo.version.sdkInt < 33 &&
          !await Permission.storage.isGranted &&
          !await Permission.storage.isLimited) {
        final status = await Permission.storage.request();
        if (status != PermissionStatus.granted &&
            status != PermissionStatus.limited) {
          emit(state.copyWith(status: UpgradeStatus.noPermission));
          return;
        }
      }
    }

    late final String downloadFileName;
    late final String downloadUrl;
    late final (String, String)? downloadPair;
    if (isAndroid) {
      if (androidInfo!.supported64BitAbis.isNotEmpty) {
        // 64 bit Android.
        downloadPair = upgradeModel!.assetsMap.filterPairs('arm64_v8a.apk');
      } else {
        // 32 bit Android.
        downloadPair = upgradeModel!.assetsMap.filterPairs('armeabi_v7a.apk');
      }
    } else if (isLinux) {
      downloadPair = upgradeModel!.assetsMap.filterPairs('linux.tar.gz');
    } else if (isWindows) {
      downloadPair = upgradeModel!.assetsMap.filterPairs('windows.zip');
    } else if (isMacOS) {
      downloadPair = upgradeModel!.assetsMap.filterPairs('.dmg');
    } else if (isIOS) {
      downloadPair = upgradeModel!.assetsMap.filterPairs('.ipa');
    }

    if (downloadPair == null) {
      emit(state.copyWith(status: UpgradeStatus.noVersionFound));
      return;
    }
    final sysDownloadPath = path.join(
      isAndroid
          ? '/storage/emulated/0/download'
          : (await getDownloadsDirectory())!.path,
      'tsdm_client',
    );
    downloadFileName = downloadPair.$1;
    downloadUrl = downloadPair.$2;
    final savePath = path.join(sysDownloadPath, downloadFileName);

    final saveDir = sysDownloadPath.replaceFirst('/storage/emulated/0/', '');
    final fileName = downloadFileName;
    emit(
      state.copyWith(
        status: UpgradeStatus.downloading,
        downloadDir: saveDir,
        fileName: fileName,
      ),
    );

    debug('upgrade: download latest version from $downloadUrl');
    debug('upgrade: save download file to $savePath');
    await _upgradeRepository
        .download(downloadUrl: downloadUrl, savePath: savePath)
        .mapLeft((e) {
          handle(e);
          emit(state.copyWith(status: UpgradeStatus.failed));
        })
        .map((_) => emit(state.copyWith(status: UpgradeStatus.success)))
        .run();
  }

  TaskOption<UpgradeModel> _parseUpgradeModel(uh.Document document) =>
      TaskOption(() async {
        final originalTitle =
            document.querySelector('h1.d-inline.mr-3')?.firstEndDeepText();
        final releaseVersion = originalTitle?.replaceFirst('v', '');
        final releaseNotes =
            document.querySelector('div.markdown-body.my-3')?.outerHtml;
        if (releaseVersion == null || releaseNotes == null) {
          return none();
        }

        // The assets info is not in the previous release page.
        final assetsDocument = await _upgradeRepository
            .fetchAssetsInfo(originalTitle!)
            .mapLeft((e) {
          handle(e);
          return null;
        }).run();

        switch (assetsDocument) {
          case Left():
            return none();
          case Right(:final value):
            final assetsEntries = value.querySelectorAll('a.Truncate').map((e) {
              final link = e.attributes['href']?.prepend('https://github.com');
              final name = e.querySelector('span')?.firstEndDeepText();
              if (link == null || name == null || name == 'Source code') {
                return null;
              }
              return MapEntry(name, link);
            }).whereType<MapEntry<String, String>>();
            final assetsMap = Map<String, String>.fromEntries(assetsEntries);
            return Some(
              UpgradeModel(
                releaseVersion: releaseVersion,
                releaseNotes: releaseNotes,
                assetsMap: assetsMap,
                releaseUrl: _upgradeRepository.releaseInfoUrl,
              ),
            );
        }
      });

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await super.close();
  }
}
