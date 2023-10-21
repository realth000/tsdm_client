import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/models/normal_thread.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:tsdm_client/widgets/network_list.dart';
import 'package:tsdm_client/widgets/thread_card.dart';

/// Forum page.
class ForumPage extends ConsumerStatefulWidget {
  /// Constructor.
  const ForumPage({
    required String fid,
    required this.routerState,
    this.title,
    super.key,
  }) : _fetchUrl = '$baseUrl/forum.php?mod=forumdisplay&fid=$fid';

  final String? title;

  final String _fetchUrl;

  final GoRouterState routerState;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ForumPageState();
}

class _ForumPageState extends ConsumerState<ForumPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(widget.title ?? context.t.appName)),
        body: NetworkList<NormalThread>(
          widget._fetchUrl,
          listBuilder: (document) {
            final normalThreadData = <NormalThread>[];
            final threadList =
                document.getElementsByClassName('tsdm_normalthread');
            if (threadList.isEmpty) {
              final docTitle = document.getElementsByTagName('title');
              final docMessage = document.getElementById('messagetext');
              final docAccessRequire =
                  docMessage?.nextElementSibling?.innerHtml;
              final docLogin = document.getElementById('messagelogin');
              debug(
                  'failed to build forum page, thread is empty. Maybe need to login ${docTitle.first.text} ${docMessage?.text} ${docAccessRequire ?? ''} ${docLogin == null}');
              if (docLogin != null) {
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
              final thread = NormalThread.fromTBody(threadElement);
              if (!thread.isValid()) {
                continue;
              }
              normalThreadData.add(thread);
            }
            return normalThreadData;
          },
          widgetBuilder: (context, thread) => ThreadCard(thread),
          canFetchMorePages: true,
        ),
      );
}
