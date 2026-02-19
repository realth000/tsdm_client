import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/widgets/custom_alert_dialog.dart';

/// Dialog to show available text scale options as a chooser.
class TextScaleDialog extends StatefulWidget {
  /// Constructor.
  const TextScaleDialog(this.initialScale, {super.key});

  /// Text scale factor when enter this widget.
  final double initialScale;

  @override
  State<TextScaleDialog> createState() => _TextScaleDialogState();
}

class _TextScaleDialogState extends State<TextScaleDialog> {
  late double _currentScale;

  @override
  void initState() {
    super.initState();
    _currentScale = widget.initialScale;
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.t.settingsPage.appearanceSection.textScaleFactor;

    return CustomAlertDialog.sync(
      title: Text(tr.dialogTitle),
      content: Column(
        spacing: 12,
        children: [
          Text(_currentScale.toString()),
          Slider(
            autofocus: true,
            // Since flutter 3.29
            // ignore: deprecated_member_use
            year2023: false,
            min: 0.7,
            max: 1.5,
            divisions: 8,
            value: _currentScale,
            onChanged: (v) => setState(() => _currentScale = double.parse(v.toStringAsFixed(2))),
          ),
        ],
      ),
      actions: [TextButton(onPressed: () => context.pop(_currentScale), child: Text(context.t.general.ok))],
    );
  }
}
