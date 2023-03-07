import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../models/normal_thread.dart';
import '../../widgets/network_list.dart';
import '../../widgets/thread_card.dart';

/// Forum page.
class ForumPage extends ConsumerStatefulWidget {
  /// Constructor.
  const ForumPage({
    required String fid,
    super.key,
  }) : _fetchUrl = 'https://www.tsdm39.net/forum.php?mod=forumdisplay&fid=$fid';

  final String _fetchUrl;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ForumPageState();
}

class _ForumPageState extends ConsumerState<ForumPage> {
  @override
  Widget build(BuildContext context) => NetworkList<NormalThread>(
        widget._fetchUrl,
        listBuilder: <thread>(document) {
          final normalThreadData = <NormalThread>[];
          document
              .getElementsByClassName('tsdm_normalthread')
              .forEach((threadElement) {
            final thread = buildNormalThreadFromElement(threadElement);
            if (thread == null) {
              return;
            }
            normalThreadData.add(thread);
          });
          return normalThreadData;
        },
        widgetBuilder: <thread>(context, thread) => ThreadCard(thread),
      );
}
