import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/models/forum.dart';
import 'package:tsdm_client/states/consumer_window_state.dart'
    show ConsumerWindowState;
import 'package:tsdm_client/widgets/forum_card.dart';
import 'package:tsdm_client/widgets/network_list.dart';

/// App homepage.
///
/// "https://www.tsdm39.com/forum.php"
class TCHomePage extends ConsumerStatefulWidget {
  /// Constructor.
  const TCHomePage({required this.fetchUrl, super.key});

  /// Url to fetch data.
  final String fetchUrl;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TCHomePageState();
}

/// State of homepage.
class _TCHomePageState extends ConsumerWindowState<TCHomePage> {
  /// Constructor.
  _TCHomePageState();

  @override
  Widget build(BuildContext context) => NetworkList<Forum>(
        widget.fetchUrl,
        listBuilder: (document) {
          final forumData = <Forum>[];
          document.getElementsByClassName('fl_g').forEach((forumElement) {
            final forum = buildForumFromElement(forumElement);
            if (forum == null) {
              return;
            }
            forumData.add(forum);
          });
          return forumData;
        },
        widgetBuilder: (context, forum) => ForumCard(forum),
      );
}
