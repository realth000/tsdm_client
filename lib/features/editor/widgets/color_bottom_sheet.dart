import 'package:dart_bbcode_web_colors/dart_bbcode_web_colors.dart';
import 'package:flex_color_picker/flex_color_picker.dart' hide FlexPickerNoNullStringExtensions;
import 'package:flutter/material.dart';
import 'package:flutter_bbcode_editor/flutter_bbcode_editor.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tsdm_client/constants/constants.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/color.dart';
import 'package:tsdm_client/features/root/view/root_page.dart';
import 'package:tsdm_client/features/settings/bloc/settings_bloc.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/utils/show_bottom_sheet.dart';
import 'package:tsdm_client/widgets/tips.dart';

/// Show a bottom sheet provides all available foreground colors for user to
/// choose.
Future<PickColorResult?> showColorPicker(BuildContext context, Color? initialColor) async {
  // Load recent used colors.
  final recentColors = context
      .read<SettingsBloc>()
      .state
      .settingsMap
      .editorRecentUsedCustomColors;

  return showCustomBottomSheet<PickColorResult>(
    title: context.t.bbcodeEditor.foregroundColor.title,
    context: context,
    builder: (context) => RootPage(DialogPaths.colorPicker, _ColorBottomSheet(initialColor, recentColors)),
  );
}

class _ColorBottomSheet extends StatefulWidget {
  const _ColorBottomSheet(this.initialColor, this.recentColors);

  /// The initial color when bottom sheet opened.
  final Color? initialColor;

  /// Recently used color values.
  final List<int> recentColors;

  @override
  State<_ColorBottomSheet> createState() => _ColorBottomSheetState();
}

class _ColorBottomSheetState extends State<_ColorBottomSheet> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final TextEditingController _customColorValueController;

  String? _customTabErrorText;

  Color _advancedTabColor = Colors.transparent;

  Color _customTabColor = Colors.transparent;

  List<Color> _recentCustomColors = [];

  void _updateCustomColorPreview(String? v) {
    final tr = context.t.colorPickerDialog.tabs.custom;

    final colorValue = v.toColor();
    if (colorValue == null) {
      setState(() {
        _customTabErrorText = tr.invalidColor;
      });
      return;
    }
    setState(() {
      _customTabErrorText = null;
      _customTabColor = Color(colorValue);
    });
  }

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
            child: Container(
              decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(15)), color: color),
            ),
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
              heading: Text(tr.selectColor, style: Theme
                  .of(context)
                  .textTheme
                  .titleSmall),
              subheading: Text(tr.selectColorShade, style: Theme
                  .of(context)
                  .textTheme
                  .titleSmall),
              showMaterialName: true,
              showColorName: true,
              showColorCode: true,
              copyPasteBehavior: const ColorPickerCopyPasteBehavior(longPressMenu: true),
              materialNameTextStyle: Theme
                  .of(context)
                  .textTheme
                  .bodySmall,
              colorNameTextStyle: Theme
                  .of(context)
                  .textTheme
                  .bodySmall,
              colorCodeTextStyle: Theme
                  .of(context)
                  .textTheme
                  .bodySmall,
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

  Widget _buildCustomTab(BuildContext context) {
    final tr = context.t.colorPickerDialog.tabs.custom;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                sizedBoxW8H8,
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _customColorValueController,
                        decoration: InputDecoration(errorText: _customTabErrorText, labelText: tr.colorValue),
                        onChanged: _updateCustomColorPreview,
                      ),
                    ),
                    sizedBoxW12H12,
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(15)),
                        color: _customTabColor,
                      ),
                    ),
                  ],
                ),
                sizedBoxW4H4,
                Tips(tr.formatTip, enablePadding: false),
                sizedBoxW4H4,
                Text(tr.recentColor, style: Theme
                    .of(context)
                    .textTheme
                    .titleSmall),
                sizedBoxW4H4,
                Wrap(
                  spacing: 4,
                  children:
                  _recentCustomColors
                      .map(
                        (e) =>
                        GestureDetector(
                          onTap:
                              () =>
                              setState(() {
                                final value = e.hex.toLowerCase();
                                _updateCustomColorPreview(value);
                                _customColorValueController.text = value;
                              }),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(Radius.circular(15)),
                              color: e,
                            ),
                          ),
                        ),
                  )
                      .toList(),
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
              ? () {
            // Update recent colors.
            final latestRecentColors =
            _updateRecentColors(_recentCustomColors, _customTabColor).map((e) => e.valueA).toList();
            context.read<SettingsBloc>().add(
              SettingsValueChanged(SettingsKeys.editorRecentUsedCustomColors, latestRecentColors),
            );
            Navigator.of(context).pop(PickColorResult.picked(_customTabColor));
          }()
              : null,
        ),
      ],
    );
  }

  /// Update [recentColors] as the [color] is the most recently used color.
  ///
  /// Record [color] in list and return the result list.
  ///
  /// * Prepend [color] if list is not full.
  /// * Remove tail colors and prepend [color] if list is full.
  /// * Move [color] to the head of list if list already holding [color].
  List<Color> _updateRecentColors(List<Color> recentColors, Color color) {
    final colors = recentColors;
    final idx = colors.indexOf(color);
    if (idx >= 0) {
      // Sort only.
      colors
        ..removeAt(idx)
        ..insert(0, color);
      return colors;
    }

    // Add.
    if (colors.length >= editorRecentUsedCustomColorsMaxCount) {
      colors.removeRange(editorRecentUsedCustomColorsMaxCount - 1, colors.length);
    }
    colors.insert(0, color);
    return colors;
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
    if (widget.recentColors.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback(
            (_) => setState(() => _recentCustomColors = widget.recentColors.map(Color.new).toList()),
      );
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

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 700),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TabBar(
            controller: _tabController,
            tabs: [Tab(text: tr.tabs.normal.title), Tab(text: tr.tabs.advanced.title), Tab(text: tr.tabs.custom.title)],
          ),
          sizedBoxW4H4,
          Expanded(
            child: Padding(
              padding: edgeInsetsL12R12,
              child: TabBarView(
                controller: _tabController,
                children: [_buildNormalTab(), _buildAdvancedTab(), _buildCustomTab(context)],
              ),
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
      ),
    );
  }
}
