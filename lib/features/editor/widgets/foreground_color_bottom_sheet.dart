import 'package:flutter/material.dart';
import 'package:flutter_bbcode_editor/flutter_bbcode_editor.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';

/// Show a bottom sheet provides all available foreground colors for user to
/// choose.
Future<void> showForegroundColorBottomSheet(
  BuildContext context,
  BBCodeEditorController controller,
) async {
  await showModalBottomSheet<void>(
    context: context,
    builder: (context) => _ForegroundColorBottomSheet(controller),
  );
}

class _ForegroundColorBottomSheet extends StatefulWidget {
  const _ForegroundColorBottomSheet(
    this.controller,
  );

  final BBCodeEditorController controller;

  @override
  State<_ForegroundColorBottomSheet> createState() =>
      _ForegroundColorBottomSheetState();
}

class _ForegroundColorBottomSheetState
    extends State<_ForegroundColorBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: edgeInsetsL15T15R15B15,
        child: Column(
          children: [
            SizedBox(
              height: 50,
              child: Center(
                child: Text(context.t.bbcodeEditor.foregroundColor.title),
              ),
            ),
            sizedBoxW10H10,
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 50,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                mainAxisExtent: 50,
              ),
              itemCount: ForegroundColor.values.length,
              itemBuilder: (context, index) {
                final color = ForegroundColor.values[index].color;
                return GestureDetector(
                  onTap: () async {
                    Navigator.of(context).pop();
                    await widget.controller.setForegroundColor(color);
                  },
                  child: CircleAvatar(
                    radius: 15,
                    backgroundColor: color,
                  ),
                );
              },
            ),
            sizedBoxW5H5,
            Row(
              children: [
                const Spacer(),
                TextButton(
                  child: Text(context.t.general.reset),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await widget.controller.clearForegroundColor();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
