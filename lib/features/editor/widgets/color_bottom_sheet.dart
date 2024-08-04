import 'package:flutter/material.dart';
import 'package:flutter_bbcode_editor/flutter_bbcode_editor.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/utils/show_bottom_sheet.dart';

/// Show a bottom sheet provides all available foreground colors for user to
/// choose.
Future<PickColorResult?> showColorPickerBottomSheet(
  BuildContext context,
) async =>
    showCustomBottomSheet<PickColorResult>(
      title: context.t.bbcodeEditor.foregroundColor.title,
      context: context,
      builder: (context) => const _ColorBottomSheet(),
    );

class _ColorBottomSheet extends StatefulWidget {
  const _ColorBottomSheet();

  @override
  State<_ColorBottomSheet> createState() => _ColorBottomSheetState();
}

class _ColorBottomSheetState extends State<_ColorBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 50,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              mainAxisExtent: 50,
            ),
            itemCount: BBCodeEditorColor.values.length,
            itemBuilder: (context, index) {
              // Item for user to pick a color.
              final color = BBCodeEditorColor.values[index].color;
              return GestureDetector(
                onTap: () =>
                    Navigator.of(context).pop(PickColorResult.picked(color)),
                child: Hero(
                  tag: color.toString(),
                  child: CircleAvatar(
                    radius: 15,
                    backgroundColor: color,
                  ),
                ),
              );
            },
          ),
        ),
        sizedBoxW5H5,
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Clear color.
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(PickColorResult.clearColor()),
              child: Text(context.t.general.reset),
            ),
          ],
        ),
      ],
    );
  }
}
