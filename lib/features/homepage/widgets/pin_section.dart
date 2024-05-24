part of 'widgets.dart';

/// All pinned thread in homepage.
///
/// Threads are separated into different groups.
class PinSection extends StatelessWidget {
  /// Constructor.
  const PinSection(this.pinnedThreadGroup, {super.key});

  /// All pinned thread gathered in groups.
  final List<PinnedThreadGroup> pinnedThreadGroup;

  Widget _sectionThreadBuilder(
    BuildContext context,
    PinnedThread pinnedThread, {
    bool isRank = false,
  }) {
    final String title;
    final String subtitle;
    if (isRank) {
      title = pinnedThread.threadTitle;
      subtitle = pinnedThread.authorName;
    } else {
      title = pinnedThread.authorName;
      subtitle = pinnedThread.threadTitle;
    }

    return ListTile(
      leading: GestureDetector(
        child: CircleAvatar(child: Text(title[0])),
        onTap: () async => context.pushNamed(
          ScreenPaths.profile,
          queryParameters: {'username': title},
        ),
      ),
      title: GestureDetector(
        child: Row(children: [SingleLineText(title)]),
        onTap: () async => context.pushNamed(
          ScreenPaths.profile,
          queryParameters: {'username': title},
        ),
      ),
      subtitle: isRank ? null : SingleLineText(subtitle),
      trailing: isRank ? SingleLineText(subtitle) : null,
      onTap: () {
        final target = pinnedThread.threadUrl.parseUrlToRoute();
        if (target == null) {
          debug('invalid pinned thread url: ${pinnedThread.threadUrl}');
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
        Padding(
          padding: edgeInsetsT10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sectionName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              sizedBoxW10H10,
              threadWidgetList,
            ],
          ),
        ),
      );
    }

    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: ret,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildSection(context);
  }
}
