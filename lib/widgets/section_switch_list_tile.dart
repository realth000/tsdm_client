import 'package:flutter/material.dart';
import 'package:tsdm_client/constants/layout.dart';

/// Const builder for state property when selected.
class WidgetStatePropertySelected<T> implements WidgetStateProperty<T?> {
  /// Constructor
  const WidgetStatePropertySelected(this.value);

  /// The value of the property that will be used for all states.
  final T? value;

  @override
  T? resolve(Set<WidgetState> states) =>
      states.contains(WidgetState.selected) ? value : null;

  @override
  String toString() => 'WidgetStatePropertySelected($value)';
}

/// [SwitchListTile] used in section.
class SectionSwitchListTile extends SwitchListTile {
  /// Constructor.
  const SectionSwitchListTile({
    required super.value,
    required super.onChanged,
    super.activeColor,
    super.activeTrackColor,
    super.inactiveThumbColor,
    super.inactiveTrackColor,
    super.activeThumbImage,
    super.onActiveThumbImageError,
    super.inactiveThumbImage,
    super.onInactiveThumbImageError,
    super.thumbColor,
    super.trackColor,
    super.trackOutlineColor,
    super.thumbIcon =
        const WidgetStatePropertySelected(Icon(Icons.check_outlined)),
    super.materialTapTargetSize,
    super.dragStartBehavior,
    super.mouseCursor,
    super.overlayColor,
    super.splashRadius,
    super.focusNode,
    super.onFocusChange,
    super.autofocus = false,
    super.tileColor,
    super.title,
    super.subtitle,
    super.isThreeLine = false,
    super.dense,
    super.contentPadding = edgeInsetsL16R16,
    super.secondary,
    super.selected = false,
    super.controlAffinity = ListTileControlAffinity.platform,
    super.shape,
    super.selectedTileColor,
    super.visualDensity,
    super.enableFeedback,
    super.hoverColor,
    super.key,
  });
}
