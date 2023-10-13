import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/providers/small_providers.dart';

typedef FutureVoidCallback = Future<void> Function();

/// [TextButton] with debounce check.
///
/// The [debounceProvider] maintains a bool type value, which representing the
/// work is still running (if true) or not (if false).
///
/// When the state of [debounceProvider] is true, work in [onPressed] is currently
/// running, prevents other attempts to run the same work.
///
/// When the work in [onPressed] finishes, set state in [debounceProvider] to
/// false, which permits following attempts.
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
    required this.debounceProvider,
    required this.onPressed,
    super.key,
  });

  final StateProvider<bool> debounceProvider;
  final String text;
  final FutureVoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(debounceProvider);
    return TextButton(
      child: ref.watch(debounceProvider)
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 3),
            )
          : Text(text),
      onPressed: ref.watch(isCheckingInProvider)
          ? null
          : () async {
              if (ref.read(debounceProvider)) {
                return;
              }
              ref.read(debounceProvider.notifier).state = true;
              await onPressed();
              ref.read(debounceProvider.notifier).state = false;
            },
    );
  }
}
