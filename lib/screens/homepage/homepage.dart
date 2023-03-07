import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../models/forum.dart';
import '../../widgets/forum_card.dart';
import '../../widgets/network_list.dart';

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

  @override
  Widget build(BuildContext context) => NetworkList<Forum>(
        widget.fetchUrl,
        listBuilder: <forum>(document) {
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
        widgetBuilder: <forum>(context, forum) => ForumCard(forum),
      );
}
