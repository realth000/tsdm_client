import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tsdm_client/constants/constants.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/features/settings/bloc/settings_bloc.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/widgets/card/thread_card/thread_card.dart';
import 'package:tsdm_client/widgets/section_switch_list_tile.dart';

/// Settings page for thread card appearance
class SettingsThreadCardAppearancePage extends StatefulWidget {
  /// Constructor.
  const SettingsThreadCardAppearancePage({super.key});

  @override
  State<SettingsThreadCardAppearancePage> createState() => _SettingsThreadCardAppearancePageState();
}

class _SettingsThreadCardAppearancePageState extends State<SettingsThreadCardAppearancePage> {
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
                  avatarUrl: assetExampleIndexAvatar,
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
      appBar: AppBar(title: Text(tr.title)),
      body: SafeArea(
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
                    onChanged:
                        (v) => context.read<SettingsBloc>().add(
                          SettingsValueChanged(SettingsKeys.threadCardInfoRowAlignCenter, v),
                        ),
                  ),
                  SectionSwitchListTile(
                    title: Text(tr.showLastReplyAuthor),
                    value: settings.threadCardShowLastReplyAuthor,
                    onChanged:
                        (v) => context.read<SettingsBloc>().add(
                          SettingsValueChanged(SettingsKeys.threadCardShowLastReplyAuthor, v),
                        ),
                  ),
                  SectionSwitchListTile(
                    title: Text(tr.highlightRecentThread),
                    value: settings.threadCardHighlightRecentThread,
                    onChanged:
                        (v) => context.read<SettingsBloc>().add(
                          SettingsValueChanged(SettingsKeys.threadCardHighlightRecentThread, v),
                        ),
                  ),
                  SectionSwitchListTile(
                    title: Text(tr.highlightAuthorName),
                    value: settings.threadCardHighlightAuthorName,
                    onChanged:
                        (v) => context.read<SettingsBloc>().add(
                          SettingsValueChanged(SettingsKeys.threadCardHighlightAuthorName, v),
                        ),
                  ),
                  SectionSwitchListTile(
                    title: Text(tr.highlightInfoRow),
                    value: settings.threadCardHighlightInfoRow,
                    onChanged:
                        (v) => context.read<SettingsBloc>().add(
                          SettingsValueChanged(SettingsKeys.threadCardHighlightInfoRow, v),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
