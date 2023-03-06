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

  static const _defaultAppBarTitle = '天使动漫';

  /// Scaffold AppBar title.
  final String? appBarTitle;

  /// Scaffold body.
  final Widget? body;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        appBar: AppBar(
          title: Text(appBarTitle ?? _defaultAppBarTitle),
        ),
        body: body,
      );
}
