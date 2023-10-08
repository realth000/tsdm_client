import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
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

  /// Scaffold AppBar title.
  final String? appBarTitle;

  /// Scaffold body.
  final Widget? body;

  final bool buildNavigator;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        appBar: AppBar(
          title: Text(appBarTitle ?? context.t.appName),
        ),
        body: body,
        bottomNavigationBar: buildNavigator ? const AppNavigationBar() : null,
      );
}
