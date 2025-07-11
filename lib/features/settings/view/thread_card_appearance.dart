import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/features/root/view/root_page.dart';
import 'package:tsdm_client/features/settings/bloc/settings_bloc.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/widgets/card/thread_card/thread_card.dart';
import 'package:tsdm_client/widgets/custom_alert_dialog.dart';
import 'package:tsdm_client/widgets/section_switch_list_tile.dart';

/// Settings page for thread card appearance
class SettingsThreadCardAppearancePage extends StatefulWidget {
  /// Constructor.
  const SettingsThreadCardAppearancePage({super.key});

  @override
  State<SettingsThreadCardAppearancePage> createState() => _SettingsThreadCardAppearancePageState();
}

class _SettingsThreadCardAppearancePageState extends State<SettingsThreadCardAppearancePage> {
  Future<void> showHelpDialog(BuildContext context) async {
    final tr = context.t.settingsPage.appearanceSection.threadCard.attrs;

    final contents = <Widget>[];

    for (final threadState in ThreadStateModel.values) {
      switch (threadState) {
        case ThreadStateModel.closed:
          contents.add(
            ListTile(leading: Icon(threadState.icon), title: Text(tr.closed.title), subtitle: Text(tr.closed.detail)),
          );
        case ThreadStateModel.upVoted:
          contents.add(
            ListTile(leading: Icon(threadState.icon), title: Text(tr.upVoted.title), subtitle: Text(tr.upVoted.detail)),
          );
        case ThreadStateModel.pictureAttached:
          contents.add(
            ListTile(
              leading: Icon(threadState.icon),
              title: Text(tr.pictureAttached.title),
              subtitle: Text(tr.pictureAttached.detail),
            ),
          );
        case ThreadStateModel.digested:
          contents.add(
            ListTile(
              leading: Icon(threadState.icon),
              title: Text(tr.digested.title),
              subtitle: Text(tr.digested.detail),
            ),
          );
        case ThreadStateModel.pinnedGlobally:
          contents.add(
            ListTile(
              leading: Icon(threadState.icon),
              title: Text(tr.pinnedGlobally.title),
              subtitle: Text(tr.pinnedGlobally.detail),
            ),
          );
        case ThreadStateModel.pinnedInType:
          contents.add(
            ListTile(
              leading: Icon(threadState.icon),
              title: Text(tr.pinnedInType.title),
              subtitle: Text(tr.pinnedInType.detail),
            ),
          );
        case ThreadStateModel.pinnedInSubreddit:
          contents.add(
            ListTile(
              leading: Icon(threadState.icon),
              title: Text(tr.pinnedInSubreddit.title),
              subtitle: Text(tr.pinnedInSubreddit.detail),
            ),
          );
        case ThreadStateModel.poll:
          contents.add(
            ListTile(leading: Icon(threadState.icon), title: Text(tr.vote.title), subtitle: Text(tr.vote.detail)),
          );
        case ThreadStateModel.rewarded:
          contents.add(
            ListTile(
              leading: Icon(threadState.icon),
              title: Text(tr.rewarded.title),
              subtitle: Text(tr.rewarded.detail),
            ),
          );
        case ThreadStateModel.draft:
          contents.add(
            ListTile(leading: Icon(threadState.icon), title: Text(tr.draft.title), subtitle: Text(tr.draft.detail)),
          );
      }
    }

    await showDialog<void>(
      context: context,
      builder: (_) => RootPage(
        DialogPaths.threadCardHelp,
        CustomAlertDialog.sync(
          title: Text(tr.help),
          content: Column(children: contents),
        ),
      ),
    );
  }

  Widget _buildExampleRow(BuildContext context) {
    final tr = context.t.settingsPage.appearanceSection.threadCard.example;
    final someTime = DateTime.fromMillisecondsSinceEpoch(int.parse(tr.time));
    return Padding(
      padding: edgeInsetsL12T4R12,
      child: Row(
        children: [
          Expanded(
            child: NormalThreadCard(
              NormalThread(
                title: tr.title,
                url: '',
                // Not used
                threadID: '114514',
                author: User(
                  name: tr.author,
                  url: '', // Not used
                ),
                publishDate: someTime,
                latestReplyAuthor: User(
                  name: tr.lastReplyAuthor,
                  url: '', // Not used
                ),
                latestReplyTime: DateTime.now().add(const Duration(minutes: -1)),
                iconUrl: '',
                // Not used
                threadType: ThreadType(
                  name: tr.threadType,
                  url: '', // Not used
                ),
                viewCount: int.parse(tr.view),
                replyCount: int.parse(tr.reply),
                price: null,
                privilege: 0,
                css: null,
                stateSet: {ThreadStateModel.pinnedGlobally, ThreadStateModel.digested},
                isRecentThread: true,
              ),
              disableTap: true,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.t.settingsPage.appearanceSection.threadCard;
    final settings = context.watch<SettingsBloc>().state.settingsMap;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: tr.showHelpTip,
            onPressed: () async => showHelpDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildExampleRow(context),
            sizedBoxW12H12,
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: [
                  SectionSwitchListTile(
                    title: Text(tr.infoRowAlignCenter),
                    value: settings.threadCardInfoRowAlignCenter,
                    onChanged: (v) => context.read<SettingsBloc>().add(
                      SettingsValueChanged(SettingsKeys.threadCardInfoRowAlignCenter, v),
                    ),
                  ),
                  SectionSwitchListTile(
                    title: Text(tr.showLastReplyAuthor),
                    value: settings.threadCardShowLastReplyAuthor,
                    onChanged: (v) => context.read<SettingsBloc>().add(
                      SettingsValueChanged(SettingsKeys.threadCardShowLastReplyAuthor, v),
                    ),
                  ),
                  SectionSwitchListTile(
                    title: Text(tr.highlightRecentThread),
                    value: settings.threadCardHighlightRecentThread,
                    onChanged: (v) => context.read<SettingsBloc>().add(
                      SettingsValueChanged(SettingsKeys.threadCardHighlightRecentThread, v),
                    ),
                  ),
                  SectionSwitchListTile(
                    title: Text(tr.highlightAuthorName),
                    value: settings.threadCardHighlightAuthorName,
                    onChanged: (v) => context.read<SettingsBloc>().add(
                      SettingsValueChanged(SettingsKeys.threadCardHighlightAuthorName, v),
                    ),
                  ),
                  SectionSwitchListTile(
                    title: Text(tr.highlightInfoRow),
                    value: settings.threadCardHighlightInfoRow,
                    onChanged: (v) => context.read<SettingsBloc>().add(
                      SettingsValueChanged(SettingsKeys.threadCardHighlightInfoRow, v),
                    ),
                  ),
                ],
              ),
            ),
            Padding(padding: context.safePadding()),
          ],
        ),
      ),
    );
  }
}
