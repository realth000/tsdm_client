import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/models/forum_group.dart';
import 'package:tsdm_client/providers/root_content_provider.dart';
import 'package:tsdm_client/providers/small_providers.dart';
import 'package:tsdm_client/widgets/forum_card.dart';

/// App topic page.
///
/// Contains most sub-forums in homepeage.
///
class TopicPage extends ConsumerStatefulWidget {
  /// Constructor.
  const TopicPage({required this.fetchUrl, super.key});

  /// Url to fetch data.
  final String fetchUrl;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TCHomePageState();
}

/// State of homepage.
class _TCHomePageState extends ConsumerState<TopicPage>
    with SingleTickerProviderStateMixin {
  /// Constructor.
  _TCHomePageState();

  TabController? tabController;

  void _updateIndex() {
    if (tabController == null) {
      return;
    }
    ref.read(topicsTabBarIndexProvider.notifier).state = tabController!.index;
  }

  @override
  void dispose() {
    if (tabController != null) {
      tabController!
        ..removeListener(_updateIndex)
        ..dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final document = ref.read(rootContentProvider.notifier).doc;

    final forumGroupNodeList = [
      // Style 1: With user avatar
      ...document.querySelectorAll(
        'div.bfff > div#wp > div#ct > div.mn > div.fl.bm > div.bm.bmw.cl',
      ),
      // Style 2: Without user avatar and with welcome text.
      ...document.querySelectorAll(
        'div.mn.miku > div.forumlist > div.forumbox',
      ),
    ];
    final groupList = forumGroupNodeList.map(ForumGroup.fromBMNode).toList();

    tabController ??= TabController(
      initialIndex: ref.read(topicsTabBarIndexProvider),
      length: groupList.length,
      vsync: this,
    )..addListener(_updateIndex);

    final groupTabList = groupList.map((e) => Tab(text: e.name)).toList();
    final groupTabBodyList = groupList
        .map(
          (e) => ListView.separated(
            padding: const EdgeInsets.only(
              left: 15,
              right: 15,
              top: 5,
              bottom: 20,
            ),
            itemCount: e.forumList.length,
            itemBuilder: (context, index) => ForumCard(
              e.forumList[index],
            ),
            separatorBuilder: (context, index) {
              return const SizedBox(width: 10, height: 10);
            },
          ),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.navigation.topics),
        bottom: TabBar(
          controller: tabController,
          tabs: groupTabList,
          isScrollable: true,
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: groupTabBodyList,
      ),
    );
  }
}
