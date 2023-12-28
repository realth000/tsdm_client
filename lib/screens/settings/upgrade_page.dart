import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/list.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/packages/html_muncher/lib/html_muncher.dart';
import 'package:tsdm_client/providers/net_client_provider.dart';
import 'package:tsdm_client/providers/upgrade_provider.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:tsdm_client/utils/git_info.dart';
import 'package:tsdm_client/utils/platform.dart';
import 'package:tsdm_client/utils/show_dialog.dart';
import 'package:universal_html/parsing.dart';
import 'package:url_launcher/url_launcher.dart';

extension _FilterExt on Map<String, String> {
  String? filter(String condition) {
    for (final entry in entries) {
      if (entry.key.endsWith(condition)) {
        return entry.value;
      }
    }
    return null;
  }

  (String, String)? filterPairs(String condition) {
    for (final entry in entries) {
      if (entry.key.endsWith(condition)) {
        return (entry.key, entry.value);
      }
    }
    return null;
  }
}

class UpgradePage extends ConsumerStatefulWidget {
  const UpgradePage({super.key});

  @override
  ConsumerState<UpgradePage> createState() => _UpgradePageState();
}

class _UpgradePageState extends ConsumerState<UpgradePage> {
  /// Fetched info about latest version;
  UpgradeModel? upgradeModel;

  /// Debounce fetch info or download assets button.
  bool isBusy = false;

  /// Path to save the downloaded file.
  String? saveDir;

  /// File name to download.
  String? fileName;

  /// Download progress percent.
  String? downloadProgress;

  Future<void> fetchData() async {
    await ref.read(upgradeProvider.notifier).fetchLatestInfo();
  }

  Future<void> downloadAssets(BuildContext context) async {
    if (upgradeModel == null) {
      return;
    }
    // Check permission first.
    if (isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      // Check storage permission.
      if (androidInfo.version.sdkInt < 33 &&
          !await Permission.storage.isGranted &&
          !await Permission.storage.isLimited) {
        final status = await Permission.storage.request();
        if (!mounted) {
          return;
        }
        if (status != PermissionStatus.granted &&
            status != PermissionStatus.limited) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(context.t.upgradePage.storagePermissionNotGranted),
          ));
          return;
        }
      }
    }

    late final String downloadFileName;
    late final String downloadUrl;
    late final (String, String)? downloadPair;
    if (isAndroid) {
      if ((await DeviceInfoPlugin().androidInfo).supported64BitAbis.isEmpty) {
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
    }

    if (!mounted) {
      return;
    }

    if (downloadPair == null) {
      await showMessageSingleButtonDialog(
        context: context,
        title: context.t.upgradePage.failedToDownloadDialog.title,
        message: context.t.upgradePage.failedToDownloadDialog.description,
      );
      return;
    }
    final sysDownloadPath = path.join(
        isAndroid
            ? '/storage/emulated/0/download'
            : (await getDownloadsDirectory())!.path,
        'tsdm_client');
    downloadFileName = downloadPair.$1;
    downloadUrl = downloadPair.$2;
    final savePath = path.join(sysDownloadPath, downloadFileName);

    setState(() {
      saveDir = sysDownloadPath.replaceFirst('/storage/emulated/0/', '');
      fileName = downloadFileName;
    });

    debug('upgrade: download latest version from $downloadUrl');
    debug('upgrade: save download file to $savePath');
    await ref.read(NetClientProvider(disableCookie: true)).download(
      downloadUrl,
      savePath,
      onReceiveProgress: (recv, total) {
        setState(() {
          downloadProgress = ((recv / total) * 100).toStringAsFixed(0);
        });
      },
      deleteOnError: true,
    );
  }

  Widget buildReleaseNotesCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: edgeInsetsL15T15R15B15,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  context.t.upgradePage.releaseNotes,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Expanded(child: Container()),
                IconButton(
                  icon: const Icon(Icons.launch_outlined),
                  onPressed: () async {
                    await launchUrl(
                      Uri.parse(upgradeModel!.releaseUrl),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                )
              ],
            ),
            sizedBoxW5H5,
            munchElement(
              context,
              parseHtmlDocument(upgradeModel!.releaseNotes).body!,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildActionButton(BuildContext context) {
    return IconButton.filled(
      icon: upgradeModel == null
          ? const Icon(Icons.refresh_outlined)
          : const Icon(Icons.download_outlined),
      onPressed: isBusy
          ? null
          : () async {
              setState(() {
                isBusy = true;
              });
              if (upgradeModel == null) {
                await fetchData();
              } else {
                await downloadAssets(context);
              }
              setState(() {
                isBusy = false;
              });
            },
    );
  }

  Widget buildContent(BuildContext context, String latestVersion) {
    final dp = double.tryParse(downloadProgress ?? '0');
    return Card(
      elevation: 2,
      child: Padding(
        padding: edgeInsetsL15T15R15B15,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              context.t.upgradePage.description,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            sizedBoxW10H10,
            Text(
              context.t.upgradePage
                  .currentVersion(currentVersion: appVersion)
                  .split('+')
                  .first,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              context.t.upgradePage.latestVersion(latestVersion: latestVersion),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (upgradeModel != null)
              Row(children: [Expanded(child: buildReleaseNotesCard(context))]),
            if (fileName != null)
              Card(
                child: Padding(
                  padding: edgeInsetsL15T15R15B15,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.t.upgradePage.saveTo(path: saveDir ?? '')),
                      Row(
                        children: [
                          Text(fileName!),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: dp == null ? null : dp / 100.0,
                            ),
                          ),
                          Text('$downloadProgress%'),
                        ].insertBetween(sizedBoxW5H5),
                      ),
                    ].insertBetween(sizedBoxW10H10),
                  ),
                ),
              ),
            sizedBoxW10H10,
            Row(
              children: [
                Expanded(
                  child: isBusy
                      ? const Center(child: sizedCircularProgressIndicator)
                      : buildActionButton(context),
                )
              ],
            ),
          ].insertBetween(sizedBoxW5H5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final upgradeState = ref.watch(upgradeProvider);
    final upgradeInfo = ref.read(upgradeProvider.notifier).latestVersion();
    if (upgradeInfo != null) {
      upgradeModel = upgradeInfo;
    }

    late final String latestVersion;
    if (upgradeState == UpgradeState.fetching) {
      latestVersion = context.t.upgradePage.fetchingData;
    } else if (upgradeModel != null) {
      latestVersion = upgradeModel!.releaseVersion;
    } else {
      latestVersion = '';
    }

    return Scaffold(
      appBar: AppBar(title: Text(context.t.upgradePage.title)),
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: SingleChildScrollView(
          child: Padding(
            padding: edgeInsetsL10T5R10B20,
            child: Row(
              children: [
                Expanded(
                  child: buildContent(context, latestVersion),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
