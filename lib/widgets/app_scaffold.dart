import 'package:flutter/material.dart';

/// App scaffold.
class TClientScaffold extends StatelessWidget {
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
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(appBarTitle ?? _defaultAppBarTitle),
        ),
        body: body,
      );
}
