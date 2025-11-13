import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/widgets/custom_alert_dialog.dart';

/// Dialog for user select a duration for image cache considered outdated till last used time.
class AutoClearImageCacheDurationDialog extends StatefulWidget {
  /// Constructor.
  const AutoClearImageCacheDurationDialog(this.currentSeconds, {super.key});

  /// Current duration in seconds.
  final int currentSeconds;

  @override
  State<AutoClearImageCacheDurationDialog> createState() => _AutoClearImageCacheDurationDialogState();
}

class _AutoClearImageCacheDurationDialogState extends State<AutoClearImageCacheDurationDialog> {
  late double _choiceIndex;

  static const List<int> allTimes = [
    // 6 hours
    3600 * 6,

    // 12 hours
    3600 * 12,

    // 1 days
    3600 * 24 * 1,

    // 3 days
    3600 * 24 * 3,

    // 7 days
    3600 * 24 * 7,

    // 15 days
    3600 * 24 * 15,

    // 30 days
    3600 * 24 * 30,
  ];

  @override
  void initState() {
    super.initState();
    _choiceIndex = allTimes.contains(widget.currentSeconds)
        ? allTimes.indexOf(widget.currentSeconds).toDouble()
        : SettingsKeys.autoClearImageCacheDuration.defaultValue.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.t.settingsPage.storageSection.scheduledCleaning;

    final time = allTimes[_choiceIndex.toInt()];

    final currentTimeText = switch (time) {
      < 0 => context.t.general.never,
      >= 0 && < 3600 => context.t.general.minutes(value: time ~/ 60),
      >= 3600 && < 3600 * 24 => context.t.general.hours(value: time ~/ 3600),
      _ => context.t.general.days(value: time ~/ (3600 * 24)),
    };

    return CustomAlertDialog.sync(
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(tr.duration.title),
          sizedBoxW12H12,
          Text(
            tr.duration.detail,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.secondary),
          ),
        ],
      ),
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
            onChanged: (v) => setState(() => _choiceIndex = v),
          ),
        ],
      ),
      actions: [
        TextButton(child: Text(context.t.general.ok), onPressed: () => context.pop(allTimes[_choiceIndex.toInt()])),
      ],
    );
  }
}
