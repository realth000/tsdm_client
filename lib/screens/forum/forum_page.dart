import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:html/dom.dart' as dom;
import 'package:tsdm_client/models/normal_thread.dart';
import 'package:tsdm_client/routes/app_routes.dart';
import 'package:tsdm_client/states/consumer_window_state.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:tsdm_client/widgets/network_list.dart';
import 'package:tsdm_client/widgets/thread_card.dart';

/// Forum page.
class ForumPage extends ConsumerStatefulWidget {
  /// Constructor.
  const ForumPage({
    required String fid,
    required this.routerState,
    super.key,
  }) : _fetchUrl = 'https://www.tsdm39.com/forum.php?mod=forumdisplay&fid=$fid';

  final String _fetchUrl;

  final GoRouterState routerState;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ForumPageState();
}

class _ForumPageState extends ConsumerWindowState<ForumPage> {
  @override
  Widget build(BuildContext context) => NetworkList<NormalThread>(
        widget._fetchUrl,
        listBuilder: (document) {
          final normalThreadData = <NormalThread>[];
          final threadList =
              document.getElementsByClassName('tsdm_normalthread');
          if (threadList.isEmpty) {
            final docTitle = document.getElementsByTagName('title');
            final docMessage = document.getElementById('messagetext');
            final docAccessRequire = docMessage?.nextElementSibling?.innerHtml;
            final docLogin = document.getElementById('messagelogin');
            debug(
                'failed to build forum page, thread is empty. Maybe need to login ${docTitle.first.text} ${docMessage?.text} ${docAccessRequire ?? ''} ${docLogin == null}');
            if (docLogin != null) {
              // TODO: 这里实际上是在build页面的过程中，直接push到另一个页面是否有问题
              context.pushReplacementNamed(
                ScreenPaths.login,
                extra: <String, dynamic>{
                  'redirectBackState': widget.routerState,
                },
              );
            }
            return normalThreadData;
          }

          for (final threadElement in threadList) {
            final thread =
                buildNormalThreadFromElement(threadElement as dom.Element);
            if (thread == null) {
              continue;
            }
            normalThreadData.add(thread);
          }
          return normalThreadData;
        },
        widgetBuilder: (context, thread) => ThreadCard(thread),
        canFetchMorePages: true,
      );
}
