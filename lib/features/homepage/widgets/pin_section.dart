part of 'widgets.dart';

/// All pinned thread in homepage.
///
/// Threads are separated into different groups.
class PinSection extends StatelessWidget with LoggerMixin {
  /// Constructor.
  const PinSection(this.pinnedThreadGroup, {super.key});

  /// All pinned thread gathered in groups.
  final List<PinnedThreadGroup> pinnedThreadGroup;

  Widget _sectionThreadBuilder(
    BuildContext context,
    PinnedThread pinnedThread, {
    bool isRank = false,
  }) {
    final String username;
    final String threadTitle;
    if (isRank) {
      username = pinnedThread.threadTitle;
      threadTitle = pinnedThread.authorName;
    } else {
      username = pinnedThread.authorName;
      threadTitle = pinnedThread.threadTitle;
    }

    return ListTile(
      // 72 is the height when thread title is not null.
      // Set this value to make every group of section has the same height.
      minTileHeight: 72,
      leading: GestureDetector(
        child: HeroUserAvatar(
          username: username,
          avatarUrl: null,
          disableHero: true,
        ),
        onTap: () async => context.pushNamed(
          ScreenPaths.profile,
          queryParameters: {'username': username},
        ),
      ),
      title: GestureDetector(
        child: Row(children: [SingleLineText(username)]),
        onTap: () async => context.pushNamed(
          ScreenPaths.profile,
          queryParameters: {'username': username},
        ),
      ),
      subtitle: isRank
          ? null
          : SingleLineText(
              threadTitle,
              overflow: TextOverflow.ellipsis,
            ),
      trailing: isRank ? SingleLineText(threadTitle) : null,
      onTap: () {
        final target = pinnedThread.threadUrl.parseUrlToRoute();
        if (target == null) {
          error('invalid pinned thread url: ${pinnedThread.threadUrl}');
          return;
        }
        context.pushNamed(
          target.screenPath,
          pathParameters: target.pathParameters,
          queryParameters: target.queryParameters
              .copyWith({'appBarTitle': pinnedThread.threadTitle}),
        );
      },
    );
  }

  /// Build a list of [PinnedThread] to a list of [ListTile] and
  /// wrap in a [Card].
  /// All [PinnedThread] inside [threads] should guarantee not null.
  Widget _buildSectionThreads(
    BuildContext context,
    List<PinnedThread?> threads, {
    bool reverseTitle = false,
  }) {
    final listTileList = threads
        .whereType<PinnedThread>()
        .map(
          (e) => _sectionThreadBuilder(
            context,
            e,
            isRank: reverseTitle,
          ),
        )
        .toList();

    return Column(children: listTileList);
  }

  Widget _buildSection(BuildContext context) {
    final ret = <Widget>[];

    final count = pinnedThreadGroup.length;

    for (var i = 0; i < count; i++) {
      final sectionName = pinnedThreadGroup[i].title;
      final threadWidgetList = _buildSectionThreads(
        context,
        pinnedThreadGroup[i].threadList,
        reverseTitle: i == 6,
      );
      ret.add(
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: edgeInsetsT8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    sizedBoxW12H12,
                    Text(
                      sectionName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                sizedBoxW12H12,
                threadWidgetList,
              ],
            ),
          ),
        ),
      );
    }

    return GridView(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 600,
        mainAxisExtent: 700,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      shrinkWrap: true,
      children: ret,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildSection(context);
  }
}
