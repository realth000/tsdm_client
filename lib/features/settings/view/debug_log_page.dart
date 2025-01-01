import 'package:flutter/material.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/instance.dart';

/// Debug page for show all caught log since this start.
class DebugLogPage extends StatefulWidget {
  /// Constructor.
  const DebugLogPage({super.key});

  @override
  State<DebugLogPage> createState() => _DebugLogPageState();
}

class _DebugLogPageState extends State<DebugLogPage> {
  @override
  Widget build(BuildContext context) {
    final tr = context.t.debugLogPage;
    return TalkerScreen(
      talker: talker,
      appBarTitle: tr.title,
      theme: TalkerScreenTheme(
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
    );
  }
}
