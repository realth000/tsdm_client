import 'package:dart_bbcode_web_colors/dart_bbcode_web_colors.dart';
import 'package:flex_color_picker/flex_color_picker.dart' hide FlexPickerNoNullStringExtensions;
import 'package:flutter/material.dart';
import 'package:flutter_bbcode_editor/flutter_bbcode_editor.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/utils/show_bottom_sheet.dart';

/// Show a bottom sheet provides all available foreground colors for user to
/// choose.
Future<PickColorResult?> showColorPicker(BuildContext context, Color? initialColor) async =>
    showCustomBottomSheet<PickColorResult>(
      title: context.t.bbcodeEditor.foregroundColor.title,
      context: context,
      builder: (context) => _ColorBottomSheet(initialColor),
    );

class _ColorBottomSheet extends StatefulWidget {
  const _ColorBottomSheet(this.initialColor);

  /// The initial color when bottom sheet opened.
  final Color? initialColor;

  @override
  State<_ColorBottomSheet> createState() => _ColorBottomSheetState();
}

class _ColorBottomSheetState extends State<_ColorBottomSheet> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final TextEditingController _customColorValueController;

  String? _customTabErrorText;

  Color _advancedTabColor = Colors.transparent;

  Color _customTabColor = Colors.transparent;

  Widget _buildNormalTab() {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 40,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
        mainAxisExtent: 40,
      ),
      itemCount: BBCodeEditorColor.values.length,
      itemBuilder: (context, index) {
        // Item for user to pick a color.
        final color = BBCodeEditorColor.values[index].color;
        return Tooltip(
          message: '${BBCodeEditorColor.values[index].name}(${color.hex})',
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(PickColorResult.picked(color)),
            child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: color)),
          ),
        );
      },
    );
  }

  Widget _buildAdvancedTab() {
    final tr = context.t.colorPickerDialog.tabs.advanced;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: ColorPicker(
              padding: EdgeInsets.zero,
              // Use the dialogPickerColor as start and active color.
              color: _advancedTabColor,
              // Update the dialogPickerColor using the callback.
              onColorChanged: (Color color) => setState(() => _advancedTabColor = color),
              borderRadius: 15,
              spacing: 5,
              runSpacing: 5,
              wheelDiameter: 155,
              heading: Text(tr.selectColor, style: Theme.of(context).textTheme.titleSmall),
              subheading: Text(tr.selectColorShade, style: Theme.of(context).textTheme.titleSmall),
              showMaterialName: true,
              showColorName: true,
              showColorCode: true,
              copyPasteBehavior: const ColorPickerCopyPasteBehavior(longPressMenu: true),
              materialNameTextStyle: Theme.of(context).textTheme.bodySmall,
              colorNameTextStyle: Theme.of(context).textTheme.bodySmall,
              colorCodeTextStyle: Theme.of(context).textTheme.bodySmall,
              pickersEnabled: const <ColorPickerType, bool>{
                ColorPickerType.both: true,
                ColorPickerType.primary: false,
                ColorPickerType.accent: false,
                ColorPickerType.bw: false,
                ColorPickerType.custom: false,
                ColorPickerType.customSecondary: false,
                ColorPickerType.wheel: false,
              },
              showEditIconButton: true,
              // customColorSwatchesAndNames: colorsNameMap,
            ),
          ),
        ),
        sizedBoxW4H4,
        FilledButton(
          onPressed:
              _advancedTabColor != Colors.transparent
                  ? () => Navigator.of(context).pop(PickColorResult.picked(_advancedTabColor))
                  : null,
          child: Text(context.t.general.ok),
        ),
      ],
    );
  }

  Widget _buildCustomTab() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                    color: _customTabColor,
                  ),
                ),
                sizedBoxW8H8,
                TextField(
                  controller: _customColorValueController,
                  decoration: InputDecoration(errorText: _customTabErrorText),
                  onChanged: (v) {
                    final colorValue = v.toColor();
                    if (colorValue == null) {
                      setState(() {
                        _customTabErrorText = context.t.colorPickerDialog.tabs.custom.invalidColor;
                      });
                      return;
                    }
                    setState(() {
                      _customTabErrorText = null;
                      _customTabColor = Color(colorValue);
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        sizedBoxW4H4,
        FilledButton(
          child: Text(context.t.general.ok),
          onPressed:
              () =>
                  _customTabColor != Colors.transparent && _customTabErrorText == null
                      ? Navigator.of(context).pop(PickColorResult.picked(_customTabColor))
                      : null,
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _customColorValueController = TextEditingController();
    if (widget.initialColor != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _advancedTabColor = widget.initialColor!;
          _customTabColor = widget.initialColor!;
        });
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _customColorValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.t.colorPickerDialog;

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: [Tab(text: tr.tabs.normal.title), Tab(text: tr.tabs.advanced.title), Tab(text: tr.tabs.custom.title)],
        ),
        sizedBoxW4H4,
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_buildNormalTab(), _buildAdvancedTab(), _buildCustomTab()],
          ),
        ),
        sizedBoxW4H4,
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(PickColorResult.clearColor()),
            child: Text(context.t.general.reset),
          ),
        ),
      ],
    );
  }
}
