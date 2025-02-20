import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/extensions/duration.dart';
import 'package:tsdm_client/i18n/strings.g.dart';

/// Dialog for user selecting a duration on auto sync notice feature.
class AutoSyncNoticeDialog extends StatelessWidget {
  /// Constructor.
  const AutoSyncNoticeDialog(this.currentSeconds, {super.key});

  /// Initial seconds when open dialog.
  final int currentSeconds;

  @override
  Widget build(BuildContext context) {
    final tr = context.t.settingsPage.behaviorSection.autoSyncNotice;
    return AlertDialog(
      scrollable: true,
      title: Text(tr.title),
      content: SingleChildScrollView(
        child: Column(
          children: [
            ...[60, 300, 600, 1800, 3600].map(
              (e) => RadioListTile(
                title: Text(Duration(seconds: e).readable(context)),
                value: e,
                groupValue: currentSeconds,
                onChanged: (v) {
                  if (v != null) {
                    context.pop(v);
                  }
                },
              ),
            ),
            RadioListTile(
              title: Text(context.t.general.never),
              value: -1,
              groupValue: currentSeconds,
              onChanged: (v) {
                if (v != null) {
                  context.pop(v);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
