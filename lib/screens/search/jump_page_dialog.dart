import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';

class JumpPageDialog extends ConsumerWidget {
  const JumpPageDialog({
    required this.current,
    required this.max,
    this.min = 0,
    super.key,
  })  : assert(max >= min, 'max index should be not less than min'),
        assert(current > 0, 'current page index should be large than 0'),
        assert(min <= current, 'current should larger than min'),
        assert(current <= max, 'current should no more than max');

  final int current;
  final int min;
  final int max;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var v = min;
    return AlertDialog(
      scrollable: true,
      title: Text(context.t.jumpDialog.title),
      content: SingleChildScrollView(
        child: Column(
          children: List.generate(
            max - min + 1,
            (index) {
              return min + index;
            },
          )
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
      ),
    );
  }
}
