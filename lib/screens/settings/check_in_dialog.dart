import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/models/check_in_feeling.dart';
import 'package:tsdm_client/providers/settings_provider.dart';

class CheckInFeelingDialog extends ConsumerWidget {
  const CheckInFeelingDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      scrollable: true,
      title: Text(context.t.settingsPage.checkInSection.feeling),
      content: SingleChildScrollView(
        child: Column(
          children: CheckInFeeling.values
              .map(
                (e) => RadioListTile(
                  title: Text(e.translate(context)),
                  onChanged: (value) async {
                    if (value == null) {
                      return;
                    }
                    await ref
                        .read(appSettingsProvider.notifier)
                        .setCheckInFeeling(value);
                    if (!context.mounted) {
                      return;
                    }
                    Navigator.pop(context);
                  },
                  value: e.toString(),
                  groupValue: ref.watch(appSettingsProvider).checkInFeeling,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class CheckInMessageDialog extends ConsumerStatefulWidget {
  const CheckInMessageDialog({super.key});

  @override
  ConsumerState<CheckInMessageDialog> createState() =>
      _CheckInMessageDialogState();
}

class _CheckInMessageDialogState extends ConsumerState<CheckInMessageDialog> {
  final textController = TextEditingController();

  static const _maxTextLength = 50;

  int textRestLength = _maxTextLength;

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: Text(context.t.settingsPage.checkInSection.anythingToSay),
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: TextField(
              autofocus: true,
              onChanged: (value) {
                setState(() {
                  textRestLength = _maxTextLength - value.length;
                });
              },
              controller: textController,
              inputFormatters: [
                LengthLimitingTextInputFormatter(_maxTextLength)
              ],
            ),
          ),
          const SizedBox(width: 20, height: 20),
          Text('$textRestLength'),
        ],
      ),
      actions: [
        TextButton(
          child: Text(context.t.general.cancel),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: Text(context.t.general.ok),
          onPressed: () async {
            await ref
                .read(appSettingsProvider.notifier)
                .setCheckInMessage(textController.text);
            if (!context.mounted) {
              return;
            }
            Navigator.pop(context);
          },
        )
      ],
    );
  }
}
