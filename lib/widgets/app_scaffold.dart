import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// App scaffold.
class TClientScaffold extends ConsumerWidget {
  /// Constructor.
  const TClientScaffold({
    required this.body,
    super.key,
    this.appBarTitle,
  });

  static const _defaultAppBarTitle = 'TSDM Client';

  /// Scaffold AppBar title.
  final String? appBarTitle;

  /// Scaffold body.
  final Widget? body;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        appBar: AppBar(
          title: Text(appBarTitle ?? _defaultAppBarTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {},
            ),
          ],
        ),
        body: body,
      );
}
