import 'package:flutter/material.dart';
import 'package:flutter_bbcode_editor/flutter_bbcode_editor.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';

/// All color bottom sheet types.
enum ColorBottomSheetType {
  /// For foreground color.
  foreground,

  /// For background color.
  background,
}

/// Show a bottom sheet provides all available foreground colors for user to
/// choose.
Future<void> showForegroundColorBottomSheet(
  BuildContext context,
  BBCodeEditorController controller,
) async {
  await showModalBottomSheet<void>(
    context: context,
    builder: (context) => _ColorBottomSheet(
      controller,
      ColorBottomSheetType.foreground,
    ),
  );
}

/// Show a bottom sheet provides all available background colors for user to
/// choose.
Future<void> showBackgroundColorBottomSheet(
  BuildContext context,
  BBCodeEditorController controller,
) async {
  await showModalBottomSheet<void>(
    context: context,
    builder: (context) => _ColorBottomSheet(
      controller,
      ColorBottomSheetType.background,
    ),
  );
}

class _ColorBottomSheet extends StatefulWidget {
  const _ColorBottomSheet(
    this.controller,
    this.sheetType,
  );

  final ColorBottomSheetType sheetType;

  final BBCodeEditorController controller;

  @override
  State<_ColorBottomSheet> createState() => _ColorBottomSheetState();
}

class _ColorBottomSheetState extends State<_ColorBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final tr = context.t.bbcodeEditor;
    final title = switch (widget.sheetType) {
      ColorBottomSheetType.foreground => tr.foregroundColor.title,
      ColorBottomSheetType.background => tr.backgroundColor.title,
    };
    return Scaffold(
      body: Padding(
        padding: edgeInsetsL15T15R15B15,
        child: Column(
          children: [
            SizedBox(height: 50, child: Center(child: Text(title))),
            sizedBoxW10H10,
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 50,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                mainAxisExtent: 50,
              ),
              itemCount: BBCodeEditorColor.values.length,
              itemBuilder: (context, index) {
                final color = BBCodeEditorColor.values[index].color;
                return GestureDetector(
                  onTap: () async {
                    Navigator.of(context).pop();
                    switch (widget.sheetType) {
                      case ColorBottomSheetType.foreground:
                        await widget.controller.setForegroundColor(color);
                      case ColorBottomSheetType.background:
                        await widget.controller.setBackgroundColor(color);
                    }
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
                    switch (widget.sheetType) {
                      case ColorBottomSheetType.foreground:
                        await widget.controller.clearForegroundColor();
                      case ColorBottomSheetType.background:
                        await widget.controller.clearBackgroundColor();
                    }
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
