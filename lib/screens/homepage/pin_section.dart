import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:html/dom.dart' as dom;
import 'package:tsdm_client/providers/root_content_provider.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:tsdm_client/utils/html_element.dart';
import 'package:tsdm_client/utils/parse_route.dart';
import 'package:tsdm_client/widgets/single_line_text.dart';

class _ThreadAuthorPair {
  _ThreadAuthorPair({
    required this.threadUrl,
    required this.threadTitle,
    required this.authorUrl,
    required this.authorName,
  });

  final String threadUrl;
  final String threadTitle;
  final String authorUrl;
  final String authorName;
}

class PinSection extends ConsumerWidget {
  const PinSection({super.key});

  /// Build a list of [_ThreadAuthorPair] to a list of [ListTile] and
  /// wrap in a [Card].
  /// All [_ThreadAuthorPair] inside [threads] should guarantee not null.
  Widget _buildSectionThreads(
    BuildContext context,
    List<_ThreadAuthorPair?> threads,
  ) {
    final listTileList = threads
        .map(
          (e) => ListTile(
            title: SingleLineText(
              e!.threadTitle,
            ),
            trailing: SingleLineText(
              e.authorName,
            ),
            onTap: () {
              final target = e.threadUrl.parseUrlToRoute();
              if (target == null) {
                debug('invalid pinned thread url: ${e.threadUrl}');
                return;
              }
              context.pushNamed(target.$1, pathParameters: target.$2);
            },
          ),
        )
        .toList();

    return Column(children: listTileList);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final document = ref.read(rootContentProvider.notifier).doc;
    final navNameList = document
        .querySelector('td#Kahrpba_nav')
        ?.children
        .map((e) => e.firstEndDeepText())
        .toList();
    final navShowList = document
        .querySelector('td#Kahrpba_show')
        ?.children
        .where((e) => e.id.startsWith('Kahrpba_c'))
        .toList();
    if (navNameList == null ||
        navShowList == null ||
        navNameList.length != navShowList.length) {
      final errorText =
          'failed to build homepage pin section: navName length: ${navNameList?.length}, navShowList length: ${navShowList?.length}';
      debug(errorText);
      return Text(errorText);
    }

    final ret = <Widget>[];

    final count = navNameList.length;
    debug('nav thread section count: $count');

    for (var i = 0; i < count; i++) {
      final sectionName = navNameList[i];
      final sectionAllThreadPair = navShowList[i]
          .querySelectorAll('div.Kahrpba_threads')
          .map(_filterThreadAndAuthors)
          .toList();

      final threadWidgetList =
          _buildSectionThreads(context, sectionAllThreadPair);

      ret.add(Card(
        child: Column(
          children: [
            Text(
              sectionName ?? '',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(width: 10, height: 10),
            threadWidgetList,
          ],
        ),
      ));
    }

    return GridView(
      shrinkWrap: true,
      // TODO: Not hardcode these Extent sizes.
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 800,
        // Set to at least 550 to ensure not overflow when scaling window size down.
        mainAxisExtent: 550,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
      ),
      children: ret,
    );
  }
}

/// For the following structure, filter and combine thread and its author.
///
/// <div class="Kahrpba_threads">
///   <a href="thread_url">
///     thread_title
///   </a>
///   <a href="author_url">
///     <em>author_name</em>
///   </a>
///
/// Filter out thread_url, thread_title, author_url and author_name.
///
/// Where [element] is <div class="Kahrpba_threads"> node.
_ThreadAuthorPair? _filterThreadAndAuthors(dom.Element element) {
  final allNode = element.querySelectorAll('a').toList();
  // There should be two <a> in children.
  if (allNode.length != 2) {
    debug('skip build thread author pair: node count is ${allNode.length}');
    return null;
  }

  final threadUrl = allNode[0].attributes['href'];
  if (threadUrl == null) {
    debug('skip incomplete thread author pair: thread url not found');
    return null;
  }

  final threadTitle = allNode[0].firstEndDeepText();
  if (threadTitle == null) {
    debug('skip incomplete thread author pair: thread title not found');
    return null;
  }

  final authorUrl = allNode[1].attributes['href'];
  if (authorUrl == null) {
    debug('skip incomplete thread author pair: author url not found');
    return null;
  }

  final authorName = allNode[1].firstEndDeepText();
  if (authorName == null) {
    debug('skip incomplete thread author pair: author name not found');
    return null;
  }

  return _ThreadAuthorPair(
    threadUrl: threadUrl,
    threadTitle: threadTitle,
    authorUrl: authorUrl,
    authorName: authorName,
  );
}
