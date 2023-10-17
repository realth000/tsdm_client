import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

typedef FutureVoidCallback = Future<void> Function();

/// [TextButton] with debounce check.
///
/// The [shouldDebounce] represents the
/// work is still running (if true) or not (if false).
///
/// When the [shouldDebounce] is true, work in [onPressed] is currently
/// running, prevents other attempts to run the same work.
///
/// * Example:
///
/// ``` dart
/// final myProvider = StateProvider((ref) => false);
///
/// DebounceTextButton(
///   text: 'some text',
///   debounceProvider: myProvider,
///   onPressed: () async {
///     // Some heavy work here.
///   }
/// )
/// ```
///
/// Why using a standalone provider?
///
/// Because the **work** maybe a application wide work, it's "single instance"
/// state should be globally stored.
class DebounceTextButton extends ConsumerWidget {
  const DebounceTextButton({
    required this.text,
    required this.shouldDebounce,
    required this.onPressed,
    super.key,
  });

  final bool shouldDebounce;
  final String text;
  final FutureVoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextButton(
      child: shouldDebounce
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 3),
            )
          : Text(text),
      onPressed: shouldDebounce ? null : () async => onPressed(),
    );
  }
}

class DebounceElevatedButton extends ConsumerWidget {
  const DebounceElevatedButton({
    required this.child,
    required this.shouldDebounce,
    required this.onPressed,
    super.key,
  });

  final bool shouldDebounce;
  final Widget child;
  final FutureVoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      child: shouldDebounce
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 3),
            )
          : child,
      onPressed: shouldDebounce ? null : () async => onPressed(),
    );
  }
}

class DebounceIconButton extends ConsumerWidget {
  const DebounceIconButton({
    required this.icon,
    required this.shouldDebounce,
    required this.onPressed,
    super.key,
  });

  final bool shouldDebounce;
  final Widget icon;
  final FutureVoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: shouldDebounce
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 3),
            )
          : icon,
      onPressed: shouldDebounce ? null : () async => onPressed(),
    );
  }
}
