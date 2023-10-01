import 'package:card_swiper/card_swiper.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:html/dom.dart' as dom;
import 'package:tsdm_client/providers/root_content_provider.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:tsdm_client/utils/parse_route.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _scrollController = ScrollController();

  List<String?> buildKahrpbaPicUrlList(dom.Element? styleNode) {
    if (styleNode == null) {
      debug('failed to build kahrpba picture url list: node is null');
      return [];
    }

    return styleNode.innerHtml
        .split('\n')
        .where((e) => e.startsWith('.Kahrpba_pic_') && !e.contains('ctrlbtn'))
        .map((e) => e.split('(').lastOrNull?.split(')').firstOrNull)
        .toList();
  }

  List<String?> buildKahrpbaPicHrefList(dom.Element? scriptNode) {
    if (scriptNode == null) {
      debug('failed to build kahrpba picture href list: node is null');
      return [];
    }

    return scriptNode.innerHtml
        .split('\n')
        .where((e) => e.contains("window.location='"))
        .map((e) =>
            e.split("window.location='").lastOrNull?.split("'").firstOrNull)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final doc = ref.read(rootContentProvider.notifier).doc;
    final chartNode = doc.getElementById('chart');
    final welcomeHint =
        doc.getElementById('tsdmwelcome')?.children.firstOrNull?.text;
    final styleNode = chartNode?.querySelector('style');
    final scriptNode = chartNode?.querySelector('script');

    final picUrlList = buildKahrpbaPicUrlList(styleNode);
    final picHrefList = buildKahrpbaPicHrefList(scriptNode);
    if (picUrlList.length != picHrefList.length) {
      debug(
          'homepage kahrpba picture url count and href count not equal, ${picUrlList.length} != ${picHrefList.length}, skip building swiper');
    } else {
      debug('kahrpba picture count is ${picUrlList.length}');
    }

    return Swiper(
      itemBuilder: (context, index) {
        return InkWell(
          child: Image.network(picUrlList[index]!),
          onTap: () async {
            final parseResult = picHrefList[index]?.parseUrlToRoute();
            if (parseResult == null) {
              debug(
                  'failed to push to kahrpba href page, isNull: ${picHrefList[index] == null}');
              return;
            }
            await context.pushNamed(
              parseResult.$1,
              pathParameters: parseResult.$2,
            );
          },
        );
      },
      itemCount: picUrlList.length,
      pagination: const SwiperPagination(),
      control: const SwiperControl(),
    );
  }
}
