import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/list.dart';
import 'package:tsdm_client/features/upgrade/cubit/upgrade_cubit.dart';
import 'package:tsdm_client/features/upgrade/repository/upgrade_repository.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/packages/html_muncher/lib/html_muncher.dart';
import 'package:tsdm_client/utils/git_info.dart';
import 'package:tsdm_client/utils/show_dialog.dart';
import 'package:universal_html/parsing.dart';
import 'package:url_launcher/url_launcher.dart';

/// Page of upgrade of the app.
class UpgradePage extends StatefulWidget {
  /// Constructor.
  const UpgradePage({super.key});

  @override
  State<UpgradePage> createState() => _UpgradePageState();
}

class _UpgradePageState extends State<UpgradePage> {
  Widget buildReleaseNotesCard(BuildContext context, UpgradeState state) {
    return Card(
      child: Padding(
        padding: edgeInsetsL15T15R15B15,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.t.upgradePage.releaseNotes,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            sizedBoxW5H5,
            munchElement(
              context,
              parseHtmlDocument(state.upgradeModel!.releaseNotes).body!,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildActionButton(BuildContext context, UpgradeState state) {
    final upgradeModel = state.upgradeModel;
    final isBusy = state.status == UpgradeStatus.downloading ||
        state.status == UpgradeStatus.fetching;
    return IconButton.filled(
      icon: upgradeModel == null
          ? const Icon(Icons.refresh_outlined)
          : const Icon(Icons.download_outlined),
      onPressed: isBusy
          ? null
          : () async {
              if (upgradeModel == null) {
                await context.read<UpgradeCubit>().fetchLatestInfo();
              } else {
                await context.read<UpgradeCubit>().downloadLatestVersion();
              }
            },
    );
  }

  Widget buildContent(BuildContext context, UpgradeState state) {
    var dp = 0.0;
    if (state.downloadStatus.total > 0) {
      dp = double.tryParse(
            (state.downloadStatus.recv / state.downloadStatus.total * 100)
                .toStringAsFixed(1),
          ) ??
          0;
    }
    return Padding(
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
            context.t.upgradePage.latestVersion(
              latestVersion: state.upgradeModel?.releaseVersion ?? '',
            ),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (state.upgradeModel != null)
            Row(
              children: [
                Expanded(child: buildReleaseNotesCard(context, state)),
              ],
            ),
          if (state.fileName.isNotEmpty)
            Text(context.t.upgradePage.saveTo(path: state.downloadDir)),
          if (state.fileName.isNotEmpty && state.upgradeModel != null)
            ListTile(
              title: Text(state.fileName),
              subtitle: LinearProgressIndicator(value: dp / 100.0),
              trailing: Text('$dp%'),
            ),
          sizedBoxW10H10,
          Row(
            children: [
              Expanded(
                child: state.status == UpgradeStatus.downloading ||
                        state.status == UpgradeStatus.fetching
                    ? const Center(child: sizedCircularProgressIndicator)
                    : buildActionButton(context, state),
              ),
            ],
          ),
        ].insertBetween(sizedBoxW5H5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UpgradeCubit(
        upgradeRepository: RepositoryProvider.of<UpgradeRepository>(context),
      ),
      child: BlocListener<UpgradeCubit, UpgradeState>(
        listener: (context, state) async {
          if (state.status == UpgradeStatus.noPermission) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text(context.t.upgradePage.storagePermissionNotGranted),
              ),
            );
          } else if (state.status == UpgradeStatus.noVersionFound) {
            await showMessageSingleButtonDialog(
              context: context,
              title: context.t.upgradePage.failedToDownloadDialog.title,
              message: context.t.upgradePage.failedToDownloadDialog.description,
            );
          }
        },
        child: BlocBuilder<UpgradeCubit, UpgradeState>(
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                title: Text(context.t.upgradePage.title),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.launch_outlined),
                    onPressed: () async {
                      await launchUrl(
                        Uri.parse(state.upgradeModel!.releaseUrl),
                        mode: LaunchMode.externalApplication,
                      );
                    },
                  ),
                ],
              ),
              body: ScrollConfiguration(
                behavior:
                    ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: edgeInsetsL10T5R10B20,
                    child: Row(
                      children: [
                        Expanded(
                          child: buildContent(context, state),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
