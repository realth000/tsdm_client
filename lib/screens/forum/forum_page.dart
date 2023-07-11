import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:html/dom.dart' as dom;
import 'package:tsdm_client/models/normal_thread.dart';
import 'package:tsdm_client/states/consumer_window_state.dart';
import 'package:tsdm_client/widgets/network_list.dart';
import 'package:tsdm_client/widgets/thread_card.dart';

/// Forum page.
class ForumPage extends ConsumerStatefulWidget {
  /// Constructor.
  const ForumPage({
    required String fid,
    super.key,
  }) : _fetchUrl = 'https://www.tsdm39.com/forum.php?mod=forumdisplay&fid=$fid';

  final String _fetchUrl;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ForumPageState();
}

class _ForumPageState extends ConsumerWindowState<ForumPage> {
  @override
  Widget build(BuildContext context) => NetworkList<NormalThread>(
        widget._fetchUrl,
        listBuilder: (document) {
          final normalThreadData = <NormalThread>[];
          document
              .getElementsByClassName('tsdm_normalthread')
              .forEach((threadElement) {
            final thread =
                buildNormalThreadFromElement(threadElement as dom.Element);
            if (thread == null) {
              return;
            }
            normalThreadData.add(thread);
          });
          return normalThreadData;
        },
        widgetBuilder: (context, thread) => ThreadCard(thread),
        canFetchMorePages: true,
      );
}
