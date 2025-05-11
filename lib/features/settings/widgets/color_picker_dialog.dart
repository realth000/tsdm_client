import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/extensions/color.dart';
import 'package:tsdm_client/widgets/color_palette.dart';

const _colorBoxSize = 55.0;

/// Dialog to let user select accent color.
final class ColorPickerDialog extends StatelessWidget {
  /// Constructor.
  const ColorPickerDialog({required this.currentColorValue, required this.blocContext, super.key});

  /// Current accent color value.
  final int currentColorValue;

  /// Context passed from outside which has bloc.
  final BuildContext blocContext;

  Widget _buildBottomSheetContent(BuildContext context) {
    const items = Colors.primaries;

    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: _colorBoxSize,
        mainAxisSpacing: 20,
        crossAxisSpacing: 10,
        mainAxisExtent: _colorBoxSize,
      ),
      itemBuilder:
          (context, index) => GestureDetector(
            onTap: () async => context.pop((Color(items[index].valueA), false)),
            child: ColorPalette(color: items[index], selected: items[index].valueA == currentColorValue),
          ),
      itemCount: items.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(constraints: const BoxConstraints(maxHeight: 400), child: _buildBottomSheetContent(context));
  }
}
