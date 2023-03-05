import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:html/parser.dart' as html_parser;

import '../../models/forum.dart';
import '../../providers/dio_provider.dart';
import '../../widgets/forum_card.dart';

/// App homepage.
///
/// "https://www.tsdm39.net/forum.php"
class TCHomePage extends ConsumerStatefulWidget {
  /// Constructor.
  const TCHomePage({required this.fetchUrl, super.key});

  /// Url to fetch data.
  final String fetchUrl;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TCHomePageState();
}

/// State of homepage.
class _TCHomePageState extends ConsumerState<TCHomePage> {
  /// Constructor.
  _TCHomePageState();

  final _forumListScrollController = ScrollController(keepScrollOffset: true);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _forumListScrollController.dispose();
    super.dispose();
  }

  Widget _buildForumList(
    BuildContext context,
    WidgetRef ref,
    List<Forum> forumData,
  ) =>
      ListView.builder(
        controller: _forumListScrollController,
        itemCount: forumData.length,
        itemBuilder: (context, index) => ForumCard(forum: forumData[index]),
      );

  @override
  Widget build(BuildContext context) => FutureBuilder(
        future: ref.read(dioProvider).get(widget.fetchUrl),
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
            final forumData = <Forum>[];
            pageData.getElementsByClassName('fl_g').forEach((forumElement) {
              final data = buildForumFromElement(forumElement);
              if (data == null) {
                return;
              }
              forumData.add(data);
            });
            return _buildForumList(context, ref, forumData);
          }
        },
      );
}
