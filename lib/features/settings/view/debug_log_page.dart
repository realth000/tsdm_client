import 'package:flutter/material.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/utils/clipboard.dart';

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
    // return Scaffold(
    //   appBar: AppBar(
    //     title: Text('aaa'),
    //   ),
    //   body: Text(talker.history.map((e) => e.generateTextMessage()).join('\n')),
    // );

    return FutureBuilder(
      future: Future.value(
        talker.history.map((e) => e.generateTextMessage()).join('\n'),
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text(tr.title)),
            body: Center(child: Text(snapshot.error!.toString())),
          );
        }

        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: Text(tr.title)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final logData = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: Text(tr.title),
            actions: [
              IconButton(
                icon: const Icon(Icons.copy_outlined),
                onPressed: () async => copyToClipboard(context, logData),
              ),
            ],
          ),
          body: SingleChildScrollView(child: Text(logData)),
        );
      },
    );
  }
}
