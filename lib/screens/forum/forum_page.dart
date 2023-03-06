import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../models/normal_thread.dart';
import '../../providers/dio_provider.dart';
import '../../widgets/network_widget.dart';
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

  late Future<Response<dynamic>> _data;

  void _loadData() {
    _data = ref.read(dioProvider).get(widget._fetchUrl);
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

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
  Widget build(BuildContext context) =>
      NetworkWidget(widget._fetchUrl, (document) {
        final normalThreadData = <NormalThread>[];
        document.getElementsByClassName('tsdm_normalthread').forEach((thread) {
          final model = buildNormalThreadFromElement(thread);
          if (model == null) {
            return;
          }
          normalThreadData.add(model);
        });
        return _buildNormalThreadList(context, ref, normalThreadData);
      });
}
