import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AutoRedirectDialog extends ConsumerStatefulWidget {
  const AutoRedirectDialog({
    required this.duration,
    required this.child,
    required this.callback,
    super.key,
  });

  final Duration duration;
  final Widget child;
  final Function() callback;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AutoRedirectDialogState();
}

class _AutoRedirectDialogState extends ConsumerState<AutoRedirectDialog> {
  /// Use timer to control redirect.
  ///
  /// Do not use future because it can not be canceled.
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(widget.duration, (_) {
      widget.callback();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
