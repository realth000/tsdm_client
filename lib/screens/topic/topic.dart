import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/models/forum.dart';
import 'package:tsdm_client/providers/root_content_provider.dart';
import 'package:tsdm_client/states/consumer_window_state.dart'
    show ConsumerWindowState;
import 'package:tsdm_client/widgets/forum_card.dart';
import 'package:tsdm_client/widgets/network_list.dart';

/// App topic page.
///
/// Contains most sub-forums in homepeage.
///
/// "https://www.tsdm39.com/forum.php"
class TopicPage extends ConsumerStatefulWidget {
  /// Constructor.
  const TopicPage({required this.fetchUrl, super.key});

  /// Url to fetch data.
  final String fetchUrl;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TCHomePageState();
}

/// State of homepage.
class _TCHomePageState extends ConsumerWindowState<TopicPage> {
  /// Constructor.
  _TCHomePageState();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(context.t.navigation.topics)),
        body: NetworkList<Forum>(
          widget.fetchUrl,
          listBuilder: (document) {
            final forumData = <Forum>[];
            document.getElementsByClassName('fl_g').forEach((forumElement) {
              final forum = Forum.fromFlGNode(forumElement);
              if (!forum.isValid()) {
                return;
              }
              forumData.add(forum);
            });
            return forumData;
          },
          widgetBuilder: (context, forum) => ForumCard(forum),
          initialData: ref.read(rootContentProvider.notifier).doc,
        ),
      );
}
