import 'package:flutter/material.dart';
import 'package:tsdm_client/constants/layout.dart';

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
class DebounceTextButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: shouldDebounce ? null : () async => onPressed(),
      child: shouldDebounce ? sizedCircularProgressIndicator : Text(text),
    );
  }
}

class DebounceElevatedButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: shouldDebounce ? null : () async => onPressed(),
      child: shouldDebounce ? sizedCircularProgressIndicator : child,
    );
  }
}

class DebounceIconButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return IconButton(
      icon: shouldDebounce ? sizedCircularProgressIndicator : icon,
      onPressed: shouldDebounce ? null : () async => onPressed(),
    );
  }
}
