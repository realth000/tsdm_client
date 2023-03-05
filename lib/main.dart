import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:html/parser.dart' as html_parser;

import 'models/forum.dart';
import 'models/normal_thread.dart';
import 'providers/dio_provider.dart';
import 'providers/settings_provider.dart';
import 'routes/app_routes.dart';
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
        child: MaterialApp.router(
          title: 'TSDM Client',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          routeInformationProvider: tClientRouter.routeInformationProvider,
          routeInformationParser: tClientRouter.routeInformationParser,
          routerDelegate: tClientRouter.routerDelegate,
          // TODO: Actually we are using the [TClientScaffold] inside every page.
          // Maybe can do something to this duplicate scaffold.
          builder: (context, child) => Scaffold(body: child),
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
            final rootResp = await ref
                .read(dioProvider)
                .get('https://www.tsdm39.net/forum.php');
            final rootData = html_parser.parse(rootResp.data);
            rootData.getElementsByClassName('fl_g').forEach((forum) {
              final model = buildForumFromElement(forum);
              print(model);
            });
            return;
            final resp = await ref.read(dioProvider).get(
                  'https://www.tsdm39.net/forum.php?mod=forumdisplay&fid=247',
                );
            final a = html_parser.parse(resp.data);
            a.body!
                .getElementsByClassName('tsdm_normalthread')
                .forEach((thread) {
              final model = buildNormalThreadFromElement(thread);
            });
          },
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      );
}
