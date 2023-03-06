import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:html/parser.dart' as html_parser;

import '../../models/normal_thread.dart';
import '../../providers/dio_provider.dart';
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
  final _threadScrollController = ScrollController(keepScrollOffset: true);

  Widget _buildNormalThreadList(
    BuildContext context,
    WidgetRef ref,
    List<NormalThread> normalThreadData,
  ) =>
      ListView.builder(
        controller: _threadScrollController,
        itemCount: normalThreadData.length,
        itemBuilder: (context, index) => ThreadCard(normalThreadData[index]),
      );

  @override
  Widget build(BuildContext context) => FutureBuilder(
        future: ref.read(dioProvider).get(widget._fetchUrl),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            final pageData = html_parser.parse(snapshot.data!.data);
            final normalThreadData = <NormalThread>[];
            pageData
                .getElementsByClassName('tsdm_normalthread')
                .forEach((thread) {
              final model = buildNormalThreadFromElement(thread);
              if (model == null) {
                return;
              }
              normalThreadData.add(model);
            });
            return _buildNormalThreadList(context, ref, normalThreadData);
          }
        },
      );
}
