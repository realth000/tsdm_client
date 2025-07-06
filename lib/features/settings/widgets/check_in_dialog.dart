import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/features/checkin/models/models.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/widgets/custom_alert_dialog.dart';

/// Dialog to let user select a checkin feeling.
class CheckinFeelingDialog extends StatelessWidget {
  /// Constructor.
  const CheckinFeelingDialog(this.defaultFeeling, {super.key});

  /// Current using feeling.
  final String defaultFeeling;

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog.sync(
      title: Text(context.t.settingsPage.checkinSection.feeling),
      content: Column(
        children: CheckinFeeling.values
            .map(
              (e) => RadioListTile(
                title: Text(e.translate(context)),
                onChanged: (value) async {
                  if (value == null) {
                    return;
                  }
                  Navigator.of(context).pop(value);
                },
                value: e.toString(),
                groupValue: defaultFeeling,
              ),
            )
            .toList(),
      ),
    );
  }
}

/// Dialog to let user change the checkin message.
class CheckinMessageDialog extends StatefulWidget {
  /// Constructor.
  const CheckinMessageDialog(this.defaultMessage, {super.key});

  /// Current using mesage content.
  final String defaultMessage;

  @override
  State<CheckinMessageDialog> createState() => _CheckinMessageDialogState();
}

class _CheckinMessageDialogState extends State<CheckinMessageDialog> {
  final formKey = GlobalKey<FormState>();
  final textController = TextEditingController();

  static const _maxTextLength = 50;

  int textRestLength = _maxTextLength;

  @override
  void initState() {
    super.initState();
    textRestLength = _maxTextLength - widget.defaultMessage.parseUtf8Length;
    textController.text = widget.defaultMessage;
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog.sync(
      title: Text(context.t.settingsPage.checkinSection.anythingToSay),
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Form(
              key: formKey,
              child: TextFormField(
                autofocus: true,
                validator: (_) {
                  if (textRestLength >= 47) {
                    return context.t.checkinForm.shouldMoreThan3;
                  }
                  if (textRestLength < 0) {
                    return context.t.checkinForm.shouldNoMoreThan50;
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    textRestLength = _maxTextLength - value.parseUtf8Length;
                  });
                },
                controller: textController,
                inputFormatters: [LengthLimitingTextInputFormatter(_maxTextLength)],
              ),
            ),
          ),
          sizedBoxW24H24,
          Text('$textRestLength'),
        ],
      ),
      actions: [
        TextButton(
          child: Text(context.t.general.cancel),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text(context.t.general.ok),
          onPressed: () async {
            // Validate
            if (formKey.currentState == null || !(formKey.currentState!).validate()) {
              return;
            }
            Navigator.of(context).pop(textController.text);
          },
        ),
      ],
    );
  }
}
