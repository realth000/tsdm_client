import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/shared/repositories/settings_repository/settings_repository.dart';

class ColorPickerDialog extends StatefulWidget {
  const ColorPickerDialog({super.key});

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
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
            groupValue: RepositoryProvider.of<SettingsRepository>(context)
                .getAccentColorValue(),
            value: e.value,
            onChanged: (value) async {
              if (value == null) {
                return;
              }
              Navigator.of(context).pop((Color(value), false));
            },
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          child: Text(context.t.general.reset),
          onPressed: () async {
            Navigator.of(context).pop((null, true));
          },
        )
      ],
    );
  }
}
