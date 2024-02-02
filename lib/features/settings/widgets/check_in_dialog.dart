import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/shared/providers/checkin_provider/models/check_in_feeling.dart';

/// Dialog to let user select a checkin feeling.
class CheckinFeelingDialog extends StatelessWidget {
  /// Constructor.
  const CheckinFeelingDialog(this.defaultFeeling, {super.key});

  /// Current using feeling.
  final String defaultFeeling;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: Text(context.t.settingsPage.checkinSection.feeling),
      content: SingleChildScrollView(
        child: Column(
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
    textController.text = widget.defaultMessage;
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: Text(context.t.settingsPage.checkinSection.anythingToSay),
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Form(
              key: formKey,
              child: TextFormField(
                autofocus: true,
                validator: (v) {
                  if (v == null) {
                    return null;
                  }
                  if (v.length <= 3) {
                    return context.t.checkinForm.shouldMoreThan3;
                  }
                  if (v.length > 50) {
                    return context.t.checkinForm.shouldNoMoreThan50;
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    textRestLength = _maxTextLength - value.length;
                  });
                },
                controller: textController,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(_maxTextLength),
                ],
              ),
            ),
          ),
          sizedBoxW20H20,
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
            if (formKey.currentState == null ||
                !(formKey.currentState!).validate()) {
              return;
            }
            Navigator.of(context).pop(textController.text);
          },
        ),
      ],
    );
  }
}
