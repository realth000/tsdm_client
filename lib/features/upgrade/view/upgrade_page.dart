import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/extensions/list.dart';
import 'package:tsdm_client/features/upgrade/cubit/upgrade_cubit.dart';
import 'package:tsdm_client/features/upgrade/repository/upgrade_repository.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/utils/git_info.dart';
import 'package:tsdm_client/utils/html/html_muncher.dart';
import 'package:tsdm_client/utils/show_toast.dart';
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
  /// Flag indicating loading full changelog or not.
  bool loadingChangelog = false;

  Widget buildReleaseNotesCard(BuildContext context, UpgradeState state) {
    return Card(
      child: Padding(
        padding: edgeInsetsL16T16R16B16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.t.upgradePage.releaseNotes,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            sizedBoxW4H4,
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
      padding: edgeInsetsL16T16R16B16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            context.t.upgradePage.description,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          sizedBoxW12H12,
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
          sizedBoxW12H12,
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
        ].insertBetween(sizedBoxW4H4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.t.upgradePage;
    return BlocProvider(
      create: (context) => UpgradeCubit(
        upgradeRepository: RepositoryProvider.of<UpgradeRepository>(context),
      ),
      child: BlocListener<UpgradeCubit, UpgradeState>(
        listener: (context, state) async {
          if (state.status == UpgradeStatus.noPermission) {
            showSnackBar(
              context: context,
              message: tr.storagePermissionNotGranted,
            );
          } else if (state.status == UpgradeStatus.noVersionFound) {
            showSnackBar(
              context: context,
              message: tr.failedToDownloadDialog.description,
            );
          }
        },
        child: BlocBuilder<UpgradeCubit, UpgradeState>(
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                title: Text(tr.title),
                actions: [
                  // Changelog
                  IconButton(
                    icon: loadingChangelog
                        ? sizedCircularProgressIndicator
                        : const Icon(Icons.update_outlined),
                    onPressed: () async {
                      // FIXME: Do NOT use repository directly.
                      // Here use UpgradeRepository directly to avoid updating
                      // state as user may trigger show dialog when upgrade
                      // is processing.
                      final repo =
                          RepositoryProvider.of<UpgradeRepository>(context);
                      setState(() {
                        loadingChangelog = true;
                      });
                      final changelogData = await repo.fetchChangelog();
                      if (!context.mounted) {
                        return;
                      }
                      if (changelogData == null) {
                        showFailedToLoadSnackBar(context);
                        setState(() {
                          loadingChangelog = false;
                        });
                        return;
                      }
                      await showDialog<void>(
                        context: context,
                        builder: (context) {
                          final size = MediaQuery.of(context).size;
                          return AlertDialog(
                            scrollable: true,
                            title: Text(
                              tr.fullChangelogDialog.title,
                            ),
                            content: SizedBox(
                              width: size.width * 0.7,
                              height: size.height * 0.7,
                              child: ScrollConfiguration(
                                behavior: ScrollConfiguration.of(context)
                                    .copyWith(scrollbars: false),
                                child: Markdown(
                                  data: changelogData,
                                ),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(context.t.general.ok),
                              ),
                            ],
                          );
                        },
                      );
                      setState(() {
                        loadingChangelog = false;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.launch_outlined),
                    onPressed: () async {
                      await launchUrl(
                        Uri.parse(upgradeGithubReleaseUrl),
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
                    padding: edgeInsetsL12T4R12B24,
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
