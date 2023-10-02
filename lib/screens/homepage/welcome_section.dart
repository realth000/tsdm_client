import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:html/dom.dart' as dom;
import 'package:tsdm_client/providers/root_content_provider.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:tsdm_client/utils/html_element.dart';
import 'package:tsdm_client/utils/parse_route.dart';
import 'package:tsdm_client/widgets/single_line_text.dart';

class WelcomeSection extends ConsumerWidget {
  const WelcomeSection({super.key});

  static const double _kahrpbaPicWidth = 300;
  static const double _kahrpbaPicHeight = 218;

  List<String?> _buildKahrpbaPicUrlList(dom.Element? styleNode) {
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

  List<String?> _buildKahrpbaPicHrefList(dom.Element? scriptNode) {
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

  Widget _buildKahrpbaSwiper(BuildContext context, List<String?> picUrlList,
      List<String?> picHrefList) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: _kahrpbaPicWidth,
        maxHeight: _kahrpbaPicHeight,
      ),
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: Swiper(
          itemBuilder: (context, index) {
            return Image.network(picUrlList[index]!);
          },
          itemCount: picUrlList.length,
          itemWidth: _kahrpbaPicWidth,
          itemHeight: _kahrpbaPicHeight,
          // TODO: Add tap control on desktop platforms.
          // control: const SwiperControl(
          //   iconPrevious: Icons.navigate_before,
          //   iconNext: Icons.navigate_next,
          //   size: 40,
          //   padding: EdgeInsets.zero,
          // ),
          pagination: const SwiperPagination(
            margin: EdgeInsets.only(bottom: 2),
          ),
          layout: SwiperLayout.STACK,
          autoplay: true,
          onTap: (index) async {
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
        ),
      ),
    );
  }

  List<Widget> _buildKahrpbaLinkTileList(
      BuildContext context, List<(String, String)>? linkList) {
    if (linkList == null) {
      return [];
    }

    // TODO: Handle link page route.
    return linkList
        .map(
          (e) => ListTile(
            title: SingleLineText(
              e.$1
            ),
            trailing: const Icon(Icons.navigate_next),
            shape: const BorderDirectional(),
            onTap: () {
              final target = e.$2.parseUrlToRoute();
              if (target == null) {
                debug('invalid kahrpba link: ${e.$2}');
                return;
              }
              context.pushNamed(target.$1, pathParameters: target.$2);
            },
          ),
        )
        .toList();
  }

  Widget _buildForumStatusRow(BuildContext context, dom.Element chartZElement) {
    final memberInfoList = chartZElement.querySelectorAll('em').toList();
    if (memberInfoList.length == 4) {
      return SingleLineText(
        '今日:${memberInfoList[0].text} 昨日:${memberInfoList[1].text} 会员:${memberInfoList[2].text} 新会员:${memberInfoList[3].firstEndDeepText()}',
        style: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
        ),
      );
    }
    return const Text('');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final document = ref.read(rootContentProvider.notifier).doc;

    final chartNode = document.getElementById('chart');
    final chartZNode = document.querySelector('p.chart.z');
    final styleNode = chartNode?.querySelector('style');
    final scriptNode = chartNode?.querySelector('script');
    final picUrlList = _buildKahrpbaPicUrlList(styleNode);
    final picHrefList = _buildKahrpbaPicHrefList(scriptNode);

    final linkTileList = <Widget>[];

    final welcomeNode = document.getElementById('tsdmwelcome');
    // welcomeText is plain text inside welcomeNode div.
    // Only using [nodes] method can capture it.
    final welcomeTextList = welcomeNode?.nodes.firstOrNull?.text
        ?.split('，')
        .map((e) => e.trim())
        .toList();
    final welcomeText = welcomeTextList?[0] ?? 'Hello';
    final welcomeLastLoginText = welcomeTextList?[1] ?? '';
    final welcomeNavigateHrefsPairs = welcomeNode
        ?.querySelectorAll('a')
        .where((e) => e.attributes.containsKey('href'))
        .map((e) => (e.firstEndDeepText() ?? 'unknown', e.attributes['href']!))
        .toList();

    if (picUrlList.length != picHrefList.length) {
      debug(
          'homepage kahrpba picture url count and href count not equal, ${picUrlList.length} != ${picHrefList.length}, skip building swiper');
    } else {
      debug('kahrpba picture count is ${picUrlList.length}');

      linkTileList.addAll(
        _buildKahrpbaLinkTileList(
          context,
          welcomeNavigateHrefsPairs,
        ),
      );
    }

    if (chartZNode == null) {
      debug('homepage forum info node not found, skip build');
    } else {
      linkTileList..add(const SizedBox(height: 10,))
      ..add(_buildForumStatusRow(context, chartZNode));
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: _kahrpbaPicHeight,
      ),
      child: Row(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildKahrpbaSwiper(context, picUrlList, picHrefList),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleLineText(
                      welcomeText,
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.left,
                    ),
                    SingleLineText(
                      welcomeLastLoginText,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.left,
                    ),
                    ...linkTileList,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
