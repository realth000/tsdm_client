import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/utils/clipboard.dart';

/// Widget allow user copy specified content, use icon changes to indicate the success of copy instead of showing
/// snack bar.
///
/// By default when the copy process finished a snack bar is shown to indicate the completion, but in some situations
/// we do not want it, like we are in a dialog which makes the snack bar underneath it, where this widget is recommended.
///
/// This button will automatically step into 'copied state' to indicate a copy process happened just now and go back to
/// normal state after [restoreDuration]. When in 'copied state', icon button is [copiedIcon] while normal state uses
/// [icon].
class CopyButton extends StatefulWidget {
  /// Constructor.
  const CopyButton({
    required this.data,
    this.icon,
    this.copiedIcon,
    this.copiedColor,
    this.canFocus = true,
    this.restoreDuration = const Duration(seconds: 2),
    this.iconAnimationDuration = const Duration(milliseconds: 100),
    super.key,
  });

  /// Icon of the button.
  final Icon? icon;

  /// Icon to show shortly after the copy action.
  final Icon? copiedIcon;

  /// Color of [copiedIcon], it's the color of button icon when in copied state.
  final Color? copiedColor;

  /// Text to copy.
  final String data;

  /// Flag indicating if this widget can request focus.
  ///
  /// Sometimes focusing on this widget should be prevented, like used as a suffix icon in [TextField], if so, set to
  /// false.
  final bool canFocus;

  /// Duration to restore state from copied state to normal state.
  final Duration restoreDuration;

  /// Duration of switch animation on button icon.
  ///
  /// The animation is ran when button switches among normal state and copied state.
  final Duration iconAnimationDuration;

  @override
  State<CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<CopyButton> {
  /// Flag indicating copied just now or not.
  bool copiedJustNow = false;

  Timer? timer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.t.copyButton;

    final Widget icon;

    if (copiedJustNow) {
      if (widget.copiedIcon != null) {
        icon = Container(key: const ValueKey('widgetCopiedIcon'), child: widget.copiedIcon);
      } else {
        icon = Icon(
          key: const ValueKey('defaultCopiedIcon'),
          Icons.check_outlined,
          color: widget.copiedColor ?? Theme.of(context).colorScheme.primary,
        );
      }
    } else {
      if (widget.icon != null) {
        icon = Container(key: const ValueKey('widgetIcon'), child: widget.icon);
      } else {
        icon = const Icon(key: ValueKey('defaultIcon'), Icons.copy_outlined);
      }
    }

    final body = IconButton(
      icon: AnimatedSwitcher(duration: widget.iconAnimationDuration, child: icon),
      tooltip: copiedJustNow ? tr.copied : tr.copyTip,
      onPressed: () async {
        setState(() => copiedJustNow = true);
        timer?.cancel();
        await copyToClipboard(context, widget.data, showSnackBar: false);
        timer = Timer(widget.restoreDuration, () => setState(() => copiedJustNow = false));
      },
    );

    if (widget.canFocus) {
      return Focus(canRequestFocus: false, descendantsAreFocusable: false, child: body);
    }

    return body;
  }
}
