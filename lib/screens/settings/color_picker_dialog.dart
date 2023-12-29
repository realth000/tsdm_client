import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/providers/color_scheme_provider.dart';

class ColorPickerDialog extends ConsumerStatefulWidget {
  const ColorPickerDialog({super.key});

  @override
  ConsumerState<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends ConsumerState<ColorPickerDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      clipBehavior: Clip.antiAlias,
      scrollable: true,
      title: Text(context.t.colorPickerDialog.title),
      content: Column(
        children: Colors.primaries.map((e) {
          return RadioListTile(
            title: CircleAvatar(radius: 15, backgroundColor: e),
            groupValue: ref.watch(appColorSchemeProvider),
            value: e,
            onChanged: (value) async {
              if (value == null) {
                return;
              }
              await ref
                  .read(appColorSchemeProvider.notifier)
                  .setAccentColor(value);
              if (!context.mounted) {
                return;
              }
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          child: Text(context.t.general.reset),
          onPressed: () async {
            await ref.read(appColorSchemeProvider.notifier).clearAccentColor();
            if (!context.mounted) {
              return;
            }
            Navigator.pop(context);
          },
        )
      ],
    );
  }
}
