import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/widgets/custom_alert_dialog.dart';

/// A dialog to ask jump page info from user before jump page.
class JumpPageDialog extends StatefulWidget {
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
  State<JumpPageDialog> createState() => _JumpPageDialogState();
}

class _JumpPageDialogState extends State<JumpPageDialog> {
  late int currentPage;
  late final TextEditingController textController;

  @override
  void initState() {
    super.initState();
    currentPage = widget.current;
    textController = TextEditingController(text: '$currentPage');
  }

  @override
  void dispose() {
    super.dispose();
    textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog.sync(
      title: Text(context.t.jumpDialog.title),
      content: Column(
        children: [
          Slider(
            autofocus: true,
            // Since flutter 3.29
            // ignore: deprecated_member_use
            year2023: false,
            max: widget.max.toDouble(),
            min: widget.min.toDouble(),
            divisions: widget.max - 1,
            label: '$currentPage',
            value: currentPage.toDouble(),
            onChanged: (v) => setState(() {
              currentPage = v.round();
              textController.text = currentPage.toString();
            }),
          ),
          sizedBoxW12H12,
          TextField(
            controller: textController,
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              constraints: BoxConstraints(maxWidth: 100),
            ),
            textAlign: TextAlign.center,
            inputFormatters: [FilteringTextInputFormatter(RegExp(r'\d'), allow: true)],
            keyboardType: TextInputType.number,
            onChanged: (v) {
              final vv = int.tryParse(v);
              if (vv == null || vv < widget.min || vv > widget.max) {
                return;
              }
              setState(() => currentPage = vv);
            },
          ),
        ],
      ),
      actions: [
        TextButton(child: Text(context.t.general.cancel), onPressed: () => context.pop()),
        TextButton(
          child: Text(context.t.general.ok),
          onPressed: () {
            if (currentPage != widget.current) {
              // Page changed.
              context.pop(currentPage);
            } else {
              context.pop();
            }
          },
        ),
      ],
    );
  }
}
