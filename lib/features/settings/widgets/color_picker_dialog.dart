import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/features/theme/cubit/theme_cubit.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';

const _colorBoxSize = 50.0;

/// Dialog to let user select accent color.
final class ColorPickerDialog extends StatelessWidget {
  /// Constructor.
  const ColorPickerDialog({
    required this.currentColorValue,
    required this.blocContext,
    super.key,
  });

  /// Current accent color value.
  final int currentColorValue;

  /// Context passed from outside which has bloc.
  final BuildContext blocContext;

  Widget _buildBottomSheetContent(BuildContext context) {
    final tr = context.t.colorPickerDialog;
    const items = Colors.primaries;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr.title),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Padding(
        padding: edgeInsetsL15T15R15B15,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: _colorBoxSize,
                  mainAxisSpacing: 30,
                  crossAxisSpacing: 30,
                  mainAxisExtent: _colorBoxSize,
                ),
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () async =>
                      context.pop((Color(items[index].value), false)),
                  child: Badge(
                    isLabelVisible: items[index].value == currentColorValue,
                    label: const Icon(Icons.check, size: 10),
                    offset: Offset.zero,
                    child: SizedBox(
                      width: _colorBoxSize,
                      height: _colorBoxSize,
                      child: CircleAvatar(backgroundColor: items[index]),
                    ),
                  ),
                ),
                itemCount: items.length,
              ),
            ),
            TextButton(
              child: Text(context.t.general.reset),
              onPressed: () async {
                blocContext.read<ThemeCubit>().clearAccentColor();
                context.pop((null, true));
              },
            ),
            sizedBoxW20H20,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildBottomSheetContent(context);
  }
}
