import 'package:flutter/material.dart';
import 'package:tsdm_client/constants/layout.dart';

/// Function returns Future of void.
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
  /// Constructor.
  const DebounceTextButton({required this.text, required this.shouldDebounce, required this.onPressed, super.key});

  /// Should in debounce state.
  final bool shouldDebounce;

  /// Text body.
  final String text;

  /// Callback when pressed the button.
  final FutureVoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: shouldDebounce ? null : () async => onPressed(),
      child: shouldDebounce ? sizedCircularProgressIndicator : Text(text),
    );
  }
}

/// Debounce button in [ElevatedButton] style.
class DebounceFilledButton extends StatelessWidget {
  /// Constructor.
  const DebounceFilledButton({required this.child, required this.shouldDebounce, required this.onPressed, super.key});

  /// Should in debounce state.
  final bool shouldDebounce;

  /// Child body.
  final Widget child;

  /// Callback when pressed the button.
  final FutureVoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: shouldDebounce ? null : () async => onPressed(),
      child: shouldDebounce ? sizedCircularProgressIndicator : child,
    );
  }
}

/// Debounce button in [IconButton] style.
class DebounceIconButton extends StatelessWidget {
  /// Constructor.
  const DebounceIconButton({required this.icon, required this.shouldDebounce, required this.onPressed, super.key});

  /// Should in debounce state.
  final bool shouldDebounce;

  /// Icon.
  final Widget icon;

  /// Callback when pressed the button.
  final FutureVoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: shouldDebounce ? sizedCircularProgressIndicator : icon,
      onPressed: shouldDebounce ? null : () async => onPressed(),
    );
  }
}
