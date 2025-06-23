import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/widgets/custom_alert_dialog.dart';

/// Dialog for user selecting a duration on auto sync notice feature.
class AutoSyncNoticeDialog extends StatefulWidget {
  /// Constructor.
  const AutoSyncNoticeDialog(this.currentSeconds, {super.key});

  /// Initial seconds when open dialog.
  final int currentSeconds;

  @override
  State<AutoSyncNoticeDialog> createState() => _AutoSyncNoticeDialogState();
}

class _AutoSyncNoticeDialogState extends State<AutoSyncNoticeDialog> {
  late double _choiceIndex;

  static const allTimes = [
    // 1 min
    60,

    // 2 min
    120,

    // 3 min
    180,

    // 5 min
    300,

    // 10 min
    //
    // The default one.
    600,

    // 20 min
    1200,

    // 30 min
    1800,

    // 40 min
    2400,

    // 1 hour
    3600,

    // Never
    -1,
  ];

  @override
  void initState() {
    super.initState();
    _choiceIndex = allTimes.contains(widget.currentSeconds)
        ? allTimes.indexOf(widget.currentSeconds).toDouble()
        : 600.0;
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.t.settingsPage.behaviorSection.autoSyncNotice;

    final time = allTimes[_choiceIndex.toInt()];

    final currentTimeText = switch (time) {
      < 0 => context.t.general.never,
      >= 0 && < 3600 => context.t.general.minutes(value: (time / 60).toInt()),
      _ => context.t.general.hours(value: (time / 3600).toInt()),
    };

    return CustomAlertDialog(
      scrollable: true,
      title: Text(tr.title),
      content: Column(
        children: [
          Text(
            currentTimeText,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
          ),
          sizedBoxW12H12,
          Slider(
            autofocus: true,
            // Since flutter 3.29
            // ignore: deprecated_member_use
            year2023: false,
            max: allTimes.length.toDouble() - 1,
            value: _choiceIndex,
            divisions: allTimes.length - 1,
            onChanged: (v) {
              setState(() {
                _choiceIndex = v;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(child: Text(context.t.general.ok), onPressed: () => context.pop(allTimes[_choiceIndex.toInt()])),
      ],
    );
  }
}
