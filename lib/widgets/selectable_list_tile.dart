import 'package:flutter/material.dart';
import 'package:tsdm_client/constants/layout.dart';

/// List tile with selectable state, closer to the Android native component style.
class SelectableListTile extends ListTile {
  /// Constructor.
  const SelectableListTile({
    super.key,
    super.leading,
    super.title,
    super.subtitle,
    super.trailing,
    super.isThreeLine = false,
    super.dense,
    super.visualDensity,
    super.shape,
    super.style,
    super.selectedColor,
    super.iconColor,
    super.textColor,
    super.titleTextStyle,
    super.subtitleTextStyle,
    super.leadingAndTrailingTextStyle,
    super.contentPadding,
    super.enabled = true,
    super.onTap,
    super.onLongPress,
    super.onFocusChange,
    super.mouseCursor,
    super.selected = false,
    super.focusColor,
    super.hoverColor,
    super.splashColor,
    super.focusNode,
    super.autofocus = false,
    super.tileColor,
    super.selectedTileColor,
    super.enableFeedback,
    super.horizontalTitleGap,
    super.minVerticalPadding,
    super.minLeadingWidth,
    super.minTileHeight,
    super.titleAlignment,
    super.internalAddSemanticForOnTap = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (selected)
          Positioned.fill(
            child: Padding(
              padding: edgeInsetsL8R8,
              child: ClipRRect(
                // The height of ListTile is default to 48, to get a smooth radius border, the height is 24.
                borderRadius: const BorderRadius.all(Radius.circular(24)),
                child: ColoredBox(color: selectedTileColor ?? Theme.of(context).colorScheme.secondaryContainer),
              ),
            ),
          ),

        ListTile(
          // Disable `selectedTileColor` where is used as full size background.
          // selectedTileColor: selectedTileColor,
          leading: selected ? leading ?? const Icon(Icons.check_outlined) : leading,
          title: title,
          subtitle: subtitle,
          trailing: trailing,
          isThreeLine: isThreeLine,
          dense: dense,
          visualDensity: visualDensity,
          shape: shape,
          style: style,
          selectedColor: selectedColor ?? Theme.of(context).colorScheme.onSecondaryContainer,
          iconColor: iconColor,
          textColor: textColor,
          titleTextStyle: titleTextStyle,
          subtitleTextStyle: subtitleTextStyle,
          leadingAndTrailingTextStyle: leadingAndTrailingTextStyle,
          // The height of ListTile is default to 48, and
          contentPadding: contentPadding ?? edgeInsetsL24R24,
          enabled: enabled,
          onTap: onTap,
          onLongPress: onLongPress,
          onFocusChange: onFocusChange,
          mouseCursor: mouseCursor,
          selected: selected,
          focusColor: focusColor,
          hoverColor: hoverColor,
          splashColor: splashColor,
          focusNode: focusNode,
          autofocus: autofocus,
          tileColor: tileColor,
          enableFeedback: enableFeedback,
          horizontalTitleGap: horizontalTitleGap,
          minVerticalPadding: minVerticalPadding,
          minLeadingWidth: minLeadingWidth,
          minTileHeight: minTileHeight,
          titleAlignment: titleAlignment,
          internalAddSemanticForOnTap: internalAddSemanticForOnTap,
        ),
      ],
    );
  }
}
