import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tsdm_client/constants/layout.dart';

/// Alert dialog with more material style.
///
/// Wrapped [AlertDialog] with customization.
class CustomAlertDialog extends StatefulWidget {
  /// Constructor.
  const CustomAlertDialog({
    required this.content,
    this.title,
    this.actions,
    this.clipBehavior,
    this.scrollable = false,
    super.key,
  });

  /// Wrapped [AlertDialog.title].
  final Widget? title;

  /// Wrapped [AlertDialog.content].
  final Widget content;

  /// Wrapped [AlertDialog.actions].
  final List<Widget>? actions;

  /// Wrapped [AlertDialog.clipBehavior].
  final Clip? clipBehavior;

  /// Wrapped [AlertDialog.scrollable].
  final bool scrollable;

  @override
  State<CustomAlertDialog> createState() => _CustomAlertDialogState();
}

class _CustomAlertDialogState extends State<CustomAlertDialog> {
  late final ScrollController scrollController;

  late final bool scrollable;

  // Flag indicating content position is on th top.
  bool showTopDivider = false;

  // Flag indicating content position is at the bottom.
  bool showBottomDivider = false;

  void _onScroll() {
    if (!scrollController.hasClients) {
      return;
    }

    if (!scrollController.position.atEdge) {
      // In the middle.
      if (!showTopDivider) {
        setState(() => showTopDivider = true);
      }
      if (!showBottomDivider) {
        setState(() => showBottomDivider = true);
      }
    } else {
      // On the top or bottom edge.
      if (scrollController.offset == 0) {
        // At the top.
        if (showTopDivider) {
          setState(() => showTopDivider = false);
        }
        if (!showBottomDivider) {
          setState(() => showBottomDivider = true);
        }
      } else {
        // At the bottom.
        if (showBottomDivider) {
          setState(() => showBottomDivider = false);
        }
        if (!showTopDivider) {
          setState(() => showTopDivider = true);
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    scrollable = widget.scrollable;
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final outlineColor = Theme.of(context).colorScheme.outline;
    final size = MediaQuery.sizeOf(context);

    return AlertDialog(
      title: widget.title,
      // This value copied from the default value in AlterDialog and removed horizontal padding.
      contentPadding: const EdgeInsets.only(
        // left: 24.0,
        top: 16,
        // right: 24.0,
        bottom: 24,
      ),
      // contentPadding: const EdgeInsets.only(top: 16, bottom: 24),
      content: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: math.min(size.width * 0.7, 400), maxHeight: size.height * 0.6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showTopDivider) Divider(height: 1, thickness: 1, color: outlineColor) else const SizedBox(height: 5),
            Flexible(
              child: Scrollbar(
                controller: scrollController,
                child: Padding(
                  padding: edgeInsetsL24R24,
                  child: Card(
                    shape: const Border(),
                    margin: EdgeInsets.zero,
                    color: Colors.transparent,
                    clipBehavior: Clip.hardEdge,
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                      child: scrollable
                          ? SingleChildScrollView(controller: scrollController, child: widget.content)
                          : widget.content,
                    ),
                  ),
                ),
              ),
            ),
            if (showBottomDivider) Divider(height: 1, thickness: 1, color: outlineColor) else const SizedBox(height: 5),
          ],
        ),
      ),
      actions: widget.actions,
      clipBehavior: widget.clipBehavior,
    );
  }
}
