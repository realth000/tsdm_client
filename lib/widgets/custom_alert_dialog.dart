import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tsdm_client/constants/layout.dart';

/// Alert dialog with more material style.
///
/// Wrapped [AlertDialog] with customization.
class CustomAlertDialog<F> extends StatefulWidget {
  /// Constructor.
  ///
  /// Use [CustomAlertDialog.future] is body content is provided by a future, like [FutureBuilder].
  const CustomAlertDialog._({
    required this.content,
    this.title,
    this.actions,
    this.clipBehavior,
    this.contentPadding,
    super.key,
  }) : future = null,
       loadingBuilder = null,
       errorBuilder = null,
       successBuilder = null;

  /// Constructor wrapping future, like [FutureBuilder].
  ///
  /// If the body widget is a [FutureBuilder], use this constructor.
  const CustomAlertDialog.future({
    required this.future,
    required this.successBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.title,
    this.actions,
    this.clipBehavior,
    this.contentPadding,
    super.key,
  }) : content = const SizedBox(width: 0);

  /// Make a sync dialog.
  ///
  /// Use [CustomAlertDialog.future] is body content is provided by a future, like [FutureBuilder].
  static CustomAlertDialog<void> sync({
    required Widget content,
    Widget? title,
    List<Widget>? actions,
    Clip? clipBehavior,
    EdgeInsets? contentPadding,
  }) => CustomAlertDialog._(
    content: content,
    title: title,
    actions: actions,
    clipBehavior: clipBehavior,
    contentPadding: contentPadding,
  );

  /// Wrapped [AlertDialog.title].
  final Widget? title;

  /// Wrapped [AlertDialog.content].
  final Widget content;

  /// Padding wrapping the [content].
  final EdgeInsets? contentPadding;

  /// Wrapped [AlertDialog.actions].
  final List<Widget>? actions;

  /// Wrapped [AlertDialog.clipBehavior].
  final Clip? clipBehavior;

  /// The future returned.
  ///
  /// Only use in `CustomAlertDialog.future`.
  final Future<F>? future;

  /// Widget builder when [future] returns data.
  final Widget Function(BuildContext context, F data)? successBuilder;

  /// Optional widget builder when [future] is loading data.
  final Widget Function(BuildContext context)? loadingBuilder;

  /// Widget builder when [future] returns error.
  final Widget Function(BuildContext context, AsyncSnapshot<F> snapshot)? errorBuilder;

  @override
  State<CustomAlertDialog<F>> createState() => _CustomAlertDialogState();
}

class _CustomAlertDialogState<F> extends State<CustomAlertDialog<F>> {
  late final Future<F>? future;

  @override
  void initState() {
    super.initState();
    future = widget.future;
  }

  @override
  Widget build(BuildContext context) {
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
        child: future != null
            ? FutureBuilder(
                future: future,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return widget.errorBuilder?.call(context, snapshot) ?? Text('${snapshot.error!}');
                  }

                  if (!snapshot.hasData) {
                    return widget.loadingBuilder?.call(context) ??
                        const SizedBox(width: 80, height: 80, child: Center(child: CircularProgressIndicator()));
                  }

                  return _DividedDialogBody(
                    // Well, the compiler doesn't agree nullability.
                    // ignore: null_check_on_nullable_type_parameter
                    content: widget.successBuilder!.call(context, snapshot.data!),
                    contentPadding: widget.contentPadding,
                  );
                },
              )
            : _DividedDialogBody(content: widget.content, contentPadding: widget.contentPadding),
      ),
      actions: widget.actions,
      clipBehavior: widget.clipBehavior,
    );
  }
}

/// Separated body widget.
///
/// Use this widget to make let [FutureBuilder] going outside of the body to avoid rebuild when calling `setState`.
class _DividedDialogBody extends StatefulWidget {
  const _DividedDialogBody({required this.content, required this.contentPadding});

  /// Wrapped [AlertDialog.content].
  final Widget content;

  /// Padding wrapping the [content].
  final EdgeInsets? contentPadding;

  @override
  State<_DividedDialogBody> createState() => _DividedDialogBodyState();
}

class _DividedDialogBodyState extends State<_DividedDialogBody> {
  late final ScrollController scrollController;

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
      if (scrollController.position.extentBefore == 0) {
        // At the top.
        if (showTopDivider) {
          setState(() => showTopDivider = false);
        }
      } else {
        if (!showTopDivider) {
          setState(() => showTopDivider = true);
        }
      }

      if (scrollController.position.extentAfter == 0) {
        // At the bottom.
        if (showBottomDivider) {
          setState(() => showBottomDivider = false);
        }
      } else {
        if (!showBottomDivider) {
          setState(() => showBottomDivider = true);
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);

    // Update the scroll state.
    // In fact this post frame callback only aims to provide a initial state, but it also fixes a
    // scrollable client re-attach issue which causes the body does not scroll on first drag.
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTopDivider) const Divider(height: 1, thickness: 1) else const SizedBox(height: 1),
        Flexible(
          child: Padding(
            padding: widget.contentPadding ?? edgeInsetsL24R24,
            child: Card(
              shape: const Border(),
              margin: EdgeInsets.zero,
              color: Colors.transparent,
              clipBehavior: Clip.hardEdge,
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: SingleChildScrollView(controller: scrollController, child: widget.content),
              ),
            ),
          ),
        ),
        if (showBottomDivider) const Divider(height: 1, thickness: 1) else const SizedBox(height: 1),
      ],
    );
  }
}
