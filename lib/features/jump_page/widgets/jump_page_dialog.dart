import 'package:flutter/material.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/widgets/custom_alert_dialog.dart';

/// A dialog to ask jump page info from user before jump page.
class JumpPageDialog extends StatelessWidget {
  /// Constructor.
  const JumpPageDialog({required this.current, required this.max, this.min = 0, super.key})
    : assert(max >= min, 'max index should be not less than min'),
      assert(current > 0, 'current page index should be large than 0'),
      assert(min <= current, 'current should larger than min'),
      assert(current <= max, 'current should no more than max');

  /// Current page number.
  final int current;

  /// Minimum page number.
  final int min;

  /// Maximum page number.
  final int max;

  @override
  Widget build(BuildContext context) {
    var v = current;
    final choicesList = List.generate(max - min + 1, (index) {
      return min + index;
    }).toList();
    return CustomAlertDialog.sync(
      title: Text(context.t.jumpDialog.title),
      // FIXME: Here should handle better when both large mount or small mount
      //  of choices.
      // Issue is that Column will junk is choices are too many and ListView
      // fills all height even there are only few choices.
      content: Column(
        children: choicesList
            .map(
              (e) => RadioListTile(
                title: Text('$e'),
                value: e,
                groupValue: v,
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  v = value;
                  Navigator.pop(context, v);
                },
              ),
            )
            .toList(),
      ),
    );
  }
}
