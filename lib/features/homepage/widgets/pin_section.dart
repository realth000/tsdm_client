import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/map.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/features/homepage/models/models.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:tsdm_client/widgets/single_line_text.dart';

/// All pinned thread in homepage.
///
/// Threads are separated into different groups.
class PinSection extends StatelessWidget {
  const PinSection(this.pinnedThreadGroup, {super.key});

  final List<PinnedThreadGroup> pinnedThreadGroup;

  Widget _sectionThreadBuilder(
      BuildContext context, PinnedThread pinnedThread) {
    return ListTile(
      title: SingleLineText(
        pinnedThread.threadTitle,
      ),
      trailing: SingleLineText(
        pinnedThread.authorName,
      ),
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
    List<PinnedThread?> threads,
  ) {
    final listTileList = threads
        .whereType<PinnedThread>()
        .map((e) => _sectionThreadBuilder(context, e))
        .toList();

    return Column(children: listTileList);
  }

  Widget _buildSection(BuildContext context) {
    final ret = <Widget>[];

    final count = pinnedThreadGroup.length;

    for (var i = 0; i < count; i++) {
      final sectionName = pinnedThreadGroup[i].title;
      final threadWidgetList =
          _buildSectionThreads(context, pinnedThreadGroup[i].threadList);
      ret.add(Card(
        clipBehavior: Clip.hardEdge,
        margin: EdgeInsets.zero,
        child: Padding(
          padding: edgeInsetsT10,
          child: Column(
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
      ));
    }

    return GridView(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      // TODO: Not hardcode these Extent sizes.
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 800,
        // Set to at least 552 to ensure not overflow when scaling window size down.
        mainAxisSpacing: 5,
        mainAxisExtent: 552,
        crossAxisSpacing: 5,
      ),
      children: ret,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildSection(context);
  }
}
