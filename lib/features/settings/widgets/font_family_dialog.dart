import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/i18n/strings.g.dart';

/// Dialog for choosing font family.
class FontFamilyDialog extends StatefulWidget {
  /// Constructor.
  const FontFamilyDialog(this.initialFont, {super.key});

  /// Initial font family
  final String initialFont;

  @override
  State<FontFamilyDialog> createState() => _FontFamilyDialogState();
}

class _FontFamilyDialogState extends State<FontFamilyDialog> {
  late TextEditingController _fontController;

  @override
  void initState() {
    super.initState();
    _fontController = TextEditingController(text: widget.initialFont);
  }

  @override
  void dispose() {
    _fontController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.t.settingsPage.appearanceSection.fontFamily;
    return AlertDialog(
      title: Text(tr.dialogTitle),
      scrollable: true,
      content: TextField(controller: _fontController, autofocus: true),
      actions: [
        TextButton(
          child: Text(context.t.general.reset),
          onPressed: () => context.pop(''),
        ),
        TextButton(
          child: Text(context.t.general.ok),
          onPressed: () => context.pop(_fontController.text),
        ),
      ],
    );
  }
}
