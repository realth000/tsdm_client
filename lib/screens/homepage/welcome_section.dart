import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:responsive_framework/responsive_breakpoints.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/providers/auth_provider.dart';
import 'package:tsdm_client/providers/root_content_provider.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:tsdm_client/widgets/cached_image_provider.dart';
import 'package:tsdm_client/widgets/check_in_button.dart';
import 'package:tsdm_client/widgets/single_line_text.dart';

class WelcomeSection extends ConsumerWidget {
  const WelcomeSection({super.key});

  static const double _kahrpbaPicWidth = 300;
  static const double _kahrpbaPicHeight = 218;

  Widget _buildKahrpbaSwiper(BuildContext context, List<String?> picUrlList,
      List<String?> picHrefList) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: _kahrpbaPicHeight),
        child: Swiper(
          itemBuilder: (context, index) {
            return Image.network(picUrlList[index]!);
          },
          itemCount: picUrlList.length,
          itemWidth: _kahrpbaPicWidth,
          itemHeight: _kahrpbaPicHeight,
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
    BuildContext context,
    List<(String, String)>? linkList,
  ) {
    if (linkList == null) {
      return [];
    }

    // TODO: Handle link page route.
    return linkList
        .map(
          (e) => ListTile(
            title: SingleLineText(e.$1),
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

  Widget _buildForumStatusRow(
      BuildContext context, List<String> memberInfoList) {
    if (memberInfoList.length >= 3) {
      return Expanded(
        child: Padding(
          padding: edgeInsetsL10T10R10,
          child: SingleLineText(
            '今日:${memberInfoList[0]} 昨日:${memberInfoList[1]} 帖子:${memberInfoList[2]}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return const Text('');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(rootContentProvider).when(
      data: (cache) {
        return _buildSection(context, ref, cache);
      },
      error: (error, stackTrace) {
        return Scaffold(
          body: Text('$error'),
        );
      },
      loading: () {
        return const Scaffold(body: CircularProgressIndicator());
      },
    );
  }

  Widget _buildSection(
      BuildContext context, WidgetRef ref, CachedRootContent cache) {
    final picUrlList = cache.picUrlList;
    final picHrefList = cache.picHrefList;

    final linkTileList = <Widget>[];

    // welcomeText is plain text inside welcomeNode div.
    // Only using [nodes] method can capture it.
    final welcomeText = cache.usernameText;
    // First use avatar url in homepage, null means current webpage layout does
    // not provide one.
    // Then use avatar url in profile page.
    // In fact we can use the one in  profile page directly.
    final avatarUrl = cache.avatarUrl ??
        ref.read(rootContentProvider.notifier).avatarUrl ??
        '';
    final welcomeNavigateHrefsPairs = cache.navigateHrefsPairs;

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

    final memberInfoList = cache.memberInfoList;

    if (memberInfoList == null) {
      debug('homepage forum info node not found, skip build');
    } else {
      linkTileList.add(_buildForumStatusRow(context, memberInfoList));
    }

    final needExpand = ResponsiveBreakpoints.of(context)
        .largerOrEqualTo('homepage_welcome_expand');

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: needExpand ? _kahrpbaPicHeight : _kahrpbaPicHeight * 2 + 20,
      ),
      child: Flex(
        direction: needExpand ? Axis.horizontal : Axis.vertical,
        children: [
          Expanded(
              child: _buildKahrpbaSwiper(context, picUrlList, picHrefList)),
          sizedBoxW20H20,
          Expanded(
            child: Card(
              margin: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: CachedImageProvider(
                        avatarUrl,
                        context,
                        ref,
                        fallbackImageUrl: noAvatarUrl,
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                    title: Row(
                      children: [
                        Text(
                          welcomeText,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Expanded(child: Container()),
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          onPressed: () async {
                            await context.pushNamed(ScreenPaths.notice);
                          },
                        ),
                        if (ref.read(authProvider) == AuthState.authorized)
                          const CheckInButton(),
                      ],
                    ),
                  ),
                  ...linkTileList,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
