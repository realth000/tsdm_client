import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:html/parser.dart' as htmlParser;

import 'providers/dio_provider.dart';
import 'providers/settings_provider.dart';
import 'themes/app_themes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSettings();
  runApp(const TClientApp());
}

/// Main app.
class TClientApp extends StatelessWidget {
  /// Constructor.
  const TClientApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => ProviderScope(
        child: MaterialApp(
          title: 'TSDM Client',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          home: const MyHomePage(),
        ),
      );
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('TSDM Client'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'You have pushed the button this many times:',
              ),
              Text(
                '_counter',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            print('AAAA start');
            final resp = await ref.read(dioProvider).get(
                  'https://www.tsdm39.net/forum.php?mod=forumdisplay&fid=247',
                );
            final a = htmlParser.parse(resp.data);
            a.body!
                .getElementsByClassName('tsdm_normalthread')
                .forEach((thread) {
              if (thread.children.length != 1) {
                // This should not happen.
                return;
              }
              final child = thread.children[0];

              /// FIXME: Maybe is null.
              final iconNode = child.getElementsByClassName('icn').first;
              final titleNode = child.getElementsByClassName('new').first;
              final authorNode = child.getElementsByClassName('by').first;
              final replyCountNode = child.getElementsByClassName('num').first;
              final lastReplyNode = child.getElementsByClassName('by')[1];
            });
          },
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      );
}
