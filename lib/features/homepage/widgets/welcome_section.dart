import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_breakpoints.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/features/authentication/repository/authentication_repository.dart';
import 'package:tsdm_client/features/home/cubit/home_cubit.dart';
import 'package:tsdm_client/features/homepage/models/models.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:tsdm_client/widgets/cached_image/cached_image_provider.dart';
import 'package:tsdm_client/widgets/checkin_button/checkin_button.dart';
import 'package:tsdm_client/widgets/single_line_text.dart';

class WelcomeSection extends StatelessWidget {
  const WelcomeSection({
    required this.forumStatus,
    required this.loggedUserInfo,
    required this.swiperUrlList,
    super.key,
  });

  final ForumStatus forumStatus;
  final LoggedUserInfo? loggedUserInfo;
  final List<SwiperUrl> swiperUrlList;

  static const double _kahrpbaPicWidth = 300;
  static const double _kahrpbaPicHeight = 218;

  Widget _buildKahrpbaSwiper(
      BuildContext context, List<SwiperUrl> swiperUrlList) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: _kahrpbaPicHeight),
        child: Swiper(
          itemBuilder: (context, index) {
            return Image.network(swiperUrlList[index].coverUrl);
          },
          itemCount: swiperUrlList.length,
          itemWidth: _kahrpbaPicWidth,
          itemHeight: _kahrpbaPicHeight,
          pagination: const SwiperPagination(
            margin: EdgeInsets.only(bottom: 2),
          ),
          layout: SwiperLayout.STACK,
          autoplay: true,
          onTap: (index) async {
            final parseResult = swiperUrlList[index].linkUrl.parseUrlToRoute();
            if (parseResult == null) {
              return;
            }
            await context.pushNamed(
              parseResult.screenPath,
              pathParameters: parseResult.pathParameters,
              queryParameters: parseResult.queryParameters,
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
              context.pushNamed(
                target.screenPath,
                pathParameters: target.pathParameters,
                queryParameters: target.queryParameters,
              );
            },
          ),
        )
        .toList();
  }

  Widget _buildForumStatusRow(BuildContext context, ForumStatus forumStatus) {
    return Expanded(
      child: Padding(
        padding: edgeInsetsL10T10R10,
        child: SingleLineText(
          '今日:${forumStatus.todayCount} 昨日:${forumStatus.yesterdayCount} 帖子:${forumStatus.threadCount}',
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildSection(context);
  }

  Widget _buildSection(BuildContext context) {
    final linkTileList = <Widget>[];

    // username is plain text inside welcomeNode div.
    // Only using [nodes] method can capture it.
    final username = loggedUserInfo?.username ?? '';
    // First use avatar url in homepage, null means current webpage layout does
    // not provide one.
    // Then use avatar url in profile page.
    // In fact we can use the one in  profile page directly.
    final avatarUrl = loggedUserInfo?.avatarUrl;

    linkTileList
      ..addAll(_buildKahrpbaLinkTileList(
          context, loggedUserInfo?.relatedLinkPairList))
      ..add(_buildForumStatusRow(context, forumStatus));

    final needExpand = ResponsiveBreakpoints.of(context)
        .largerOrEqualTo('homepage_welcome_expand');

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: needExpand ? _kahrpbaPicHeight : _kahrpbaPicHeight * 2 + 20,
      ),
      child: Flex(
        direction: needExpand ? Axis.horizontal : Axis.vertical,
        children: [
          Expanded(child: _buildKahrpbaSwiper(context, swiperUrlList)),
          sizedBoxW5H5,
          Expanded(
            child: Card(
              margin: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: GestureDetector(
                      onTap: () async {
                        context.read<HomeCubit>().setTab(HomeTab.profile);
                        context.goNamed(ScreenPaths.loggedUserProfile);
                      },
                      child: CircleAvatar(
                        backgroundImage: avatarUrl == null
                            ? null
                            : CachedImageProvider(
                                avatarUrl,
                                context,
                                fallbackImageUrl: noAvatarUrl,
                              ),
                        child: avatarUrl == null && username.isNotEmpty
                            ? Text(username[0])
                            : null,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                    title: Row(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            context.read<HomeCubit>().setTab(HomeTab.profile);
                            context.goNamed(ScreenPaths.loggedUserProfile);
                          },
                          child: Text(
                            username,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        Expanded(child: Container()),
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          onPressed: () async {
                            await context.pushNamed(ScreenPaths.notice);
                          },
                        ),
                        if (context
                                .read<AuthenticationRepository>()
                                .currentUser !=
                            null)
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
