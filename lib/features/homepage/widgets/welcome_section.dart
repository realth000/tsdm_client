part of 'widgets.dart';

const double _kahrpbaPicWidth = 300;
const double _kahrpbaPicHeight = 218;

/// A section of homepage, contains swiper and user info.
class WelcomeSection extends StatefulWidget {
  /// Constructor.
  const WelcomeSection({
    required this.forumStatus,
    required this.loggedUserInfo,
    required this.swiperUrlList,
    super.key,
  });

  /// Forum status.
  final ForumStatus forumStatus;

  /// Current logged user info.
  ///
  /// Null if no one logged.
  final LoggedUserInfo? loggedUserInfo;

  /// All urls used in swiper.
  final List<SwiperUrl> swiperUrlList;

  @override
  State<WelcomeSection> createState() => _WelcomeSectionState();
}

class _WelcomeSectionState extends State<WelcomeSection> {
  final _swiperController = InfiniteScrollController();
  Timer? _swiperTimer;

  Widget _buildKahrpbaSwiper(
    BuildContext context,
    List<SwiperUrl> swiperUrlList,
  ) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: _kahrpbaPicHeight + 20),
        child: InfiniteCarousel.builder(
          itemCount: swiperUrlList.length,
          itemExtent: _kahrpbaPicWidth,
          onIndexChanged: (index) {},
          controller: _swiperController,
          scrollBehavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
            },
          ),
          itemBuilder: (context, itemIndex, realIndex) {
            return Padding(
              padding: edgeInsetsL10T10R10B10,
              child: GestureDetector(
                child: CachedImage(swiperUrlList[itemIndex].coverUrl),
                onTap: () async {
                  final parseResult =
                      swiperUrlList[itemIndex].linkUrl.parseUrlToRoute();
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
          '今日:${forumStatus.todayCount} 昨日:${forumStatus.yesterdayCount} '
          '帖子:${forumStatus.threadCount}',
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context) {
    final linkTileList = <Widget>[];

    // username is plain text inside welcomeNode div.
    // Only using [nodes] method can capture it.
    final username = widget.loggedUserInfo?.username ?? '';
    // First use avatar url in homepage, null means current webpage layout does
    // not provide one.
    // Then use avatar url in profile page.
    // In fact we can use the one in  profile page directly.
    final avatarUrl = widget.loggedUserInfo?.avatarUrl;

    linkTileList
      ..addAll(
        _buildKahrpbaLinkTileList(
          context,
          widget.loggedUserInfo?.relatedLinkPairList,
        ),
      )
      ..add(_buildForumStatusRow(context, widget.forumStatus));

    final needExpand = ResponsiveBreakpoints.of(context)
        .largerOrEqualTo('homepage_welcome_expand');

    final homePageState = context.read<HomepageBloc>().state;
    final unreadNoticeCount = homePageState.unreadNoticeCount;
    final hasUnreadMessage = homePageState.hasUnreadMessage;

    late final Widget noticeIcon;
    if (RepositoryProvider.of<SettingsRepository>(context)
        .getShowUnreadInfoHint()) {
      if (unreadNoticeCount > 0) {
        noticeIcon = Badge(
          label: Text('$unreadNoticeCount'),
          child: const Icon(Icons.notifications_outlined),
        );
      } else if (unreadNoticeCount <= 0 && hasUnreadMessage) {
        noticeIcon = const Badge(child: Icon(Icons.notifications_outlined));
      } else {
        noticeIcon = const Icon(Icons.notifications_outlined);
      }
    } else {
      noticeIcon = const Icon(Icons.notifications_outlined);
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: needExpand ? _kahrpbaPicHeight : _kahrpbaPicHeight * 2 + 20,
      ),
      child: Flex(
        direction: needExpand ? Axis.horizontal : Axis.vertical,
        children: [
          Expanded(child: _buildKahrpbaSwiper(context, widget.swiperUrlList)),
          sizedBoxW5H5,
          Expanded(
            child: Card(
              margin: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: GestureDetector(
                      onTap: () async => context.pushNamed(
                        ScreenPaths.loggedUserProfile,
                        queryParameters: {'hero': username},
                      ),
                      child: HeroUserAvatar(
                        username: username,
                        avatarUrl: avatarUrl,
                        heroTag: username,
                      ),
                    ),
                    title: Row(
                      children: [
                        GestureDetector(
                          onTap: () async => context.pushNamed(
                            ScreenPaths.loggedUserProfile,
                            queryParameters: {'hero': username},
                          ),
                          child: Text(
                            username,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        Expanded(child: Container()),
                        IconButton(
                          icon: noticeIcon,
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

  void setupSwiperTimer() {
    _swiperTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      _swiperController.nextItem();
    });
  }

  @override
  void initState() {
    super.initState();
    setupSwiperTimer();
  }

  @override
  void dispose() {
    _swiperTimer?.cancel();
    _swiperController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomepageBloc, HomepageState>(
      listenWhen: (prev, curr) => prev.scrollSwiper != curr.scrollSwiper,
      listener: (context, state) {
        // Resume or pause the scroll of welcome swiper according to whether we
        // are in the home tab.
        //
        // The info about in home tab or not is passed from shell route builder.
        if (state.scrollSwiper) {
          setupSwiperTimer();
        } else {
          _swiperTimer?.cancel();
        }
      },
      child: _buildSection(context),
    );
  }
}
