import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/widgets/app_navitaion_bar.dart';

/// App scaffold.
class TClientScaffold extends ConsumerWidget {
  /// Constructor.
  const TClientScaffold({
    required this.body,
    required this.buildNavigator,
    super.key,
    this.appBarTitle,
  });

  static const _defaultAppBarTitle = '天使动漫';

  /// Scaffold AppBar title.
  final String? appBarTitle;

  /// Scaffold body.
  final Widget? body;

  final bool buildNavigator;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        appBar: AppBar(
          title: Text(appBarTitle ?? _defaultAppBarTitle),
        ),
        body: body,
        bottomNavigationBar: buildNavigator ? const AppNavigationBar() : null,
      );
}
