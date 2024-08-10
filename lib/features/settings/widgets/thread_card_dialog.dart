import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tsdm_client/constants/constants.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/features/settings/bloc/settings_bloc.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/widgets/card/thread_card/thread_card.dart';

/// Configuration of `ThreadCard`.
class ThreadCardDialog extends StatefulWidget {
  /// Constructor.
  const ThreadCardDialog({super.key});

  @override
  State<ThreadCardDialog> createState() => _ThreadCardDialogState();
}

class _ThreadCardDialogState extends State<ThreadCardDialog> {
  Widget _buildExampleRow(BuildContext context) {
    final tr = context.t.settingsPage.appearanceSection.threadCard.example;
    final someTime = DateTime.fromMillisecondsSinceEpoch(int.parse(tr.time));
    return Row(
      children: [
        Expanded(
          child: NormalThreadCard(
            NormalThread(
              title: tr.title,
              url: '', // Not used
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
              iconUrl: '', // Not used
              threadType: ThreadType(
                name: tr.threadType,
                url: '', // Not used
              ),
              viewCount: int.parse(tr.view),
              replyCount: int.parse(tr.reply),
              price: null,
              privilege: 0,
              css: null,
              stateSet: {
                ThreadStateModel.pinnedGlobally,
                ThreadStateModel.digested,
              },
            ),
            disableTap: true,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.t.settingsPage.appearanceSection.threadCard;
    final settings = context.watch<SettingsBloc>().state.settingsMap;
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              SwitchListTile(
                title: Text(tr.infoRowAlignCenter),
                value: settings.threadCardInfoRowAlignCenter,
                onChanged: (v) => context.read<SettingsBloc>().add(
                      SettingsValueChanged(
                        SettingsKeys.threadCardInfoRowAlignCenter,
                        v,
                      ),
                    ),
              ),
              SwitchListTile(
                title: Text(tr.showLastReplyAuthor),
                value: settings.threadCardShowLastReplyAuthor,
                onChanged: (v) => context.read<SettingsBloc>().add(
                      SettingsValueChanged(
                        SettingsKeys.threadCardShowLastReplyAuthor,
                        v,
                      ),
                    ),
              ),
            ],
          ),
        ),
        sizedBoxW24H24,
        _buildExampleRow(context),
      ],
    );
  }
}
