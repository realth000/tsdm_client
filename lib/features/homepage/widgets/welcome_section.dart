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

class _WelcomeSectionState extends State<WelcomeSection> with LoggerMixin {
  late final CarouselController _swiperController;
  Timer? _swiperTimer;
  bool _reverseSwiper = false;

  Widget _buildKahrpbaSwiper(
    BuildContext context,
    List<SwiperUrl> swiperUrlList,
  ) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: _kahrpbaPicHeight + 20),
        child: CarouselView(
          reverse: _reverseSwiper,
          controller: _swiperController,
          itemSnapping: true,
          itemExtent: _kahrpbaPicWidth,
          shrinkExtent: _kahrpbaPicWidth,
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
          children: swiperUrlList
              .mapIndexed(
                (index, e) => CachedImage(swiperUrlList[index].coverUrl),
              )
              .toList(),
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

    final tr = context.t.homepage.welcome;

    return [
      ListTile(
        leading: const Icon(Icons.history_outlined),
        title: Text(tr.history),
        onTap: () async => context.pushNamed(ScreenPaths.threadVisitHistory),
      ),
      ListTile(
        leading: const NoticeButton(useIcon: true),
        title: Text(tr.notice),
        onTap: () async => context.pushNamed(ScreenPaths.notice),
      ),
      BlocBuilder<CheckinBloc, CheckinState>(
        builder: (context, state) {
          final onTap = switch (state) {
            CheckinStateLoading() || CheckinStateNeedLogin() => null,
            CheckinStateInitial() ||
            CheckinStateFailed() ||
            CheckinStateSuccess() =>
              () async =>
                  context.read<CheckinBloc>().add(const CheckinRequested()),
          };

          return ListTile(
            leading: const CheckinButton(
              enableSnackBar: true,
              useIcon: true,
            ),
            title: Text(tr.checkin),
            onTap: onTap,
          );
        },
      ),
      ListTile(
        leading: const Icon(Icons.article_outlined),
        title: Text(tr.myThread),
        onTap: () async => context.pushNamed(ScreenPaths.myThread),
      ),
      ListTile(
        leading: const Icon(Icons.newspaper_outlined),
        title: Text(tr.latestThread),
        onTap: () async => context.pushNamed(ScreenPaths.latestThread),
      ),
    ];
  }

  Widget _buildForumStatusRow(BuildContext context, ForumStatus forumStatus) {
    return Padding(
      padding: edgeInsetsL12T12R12,
      child: SingleLineText(
        '今日:${forumStatus.todayCount} 昨日:${forumStatus.yesterdayCount} '
        '帖子:${forumStatus.threadCount}',
        style: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSection(BuildContext context) {
    // username is plain text inside welcomeNode div.
    // Only using [nodes] method can capture it.
    final username = widget.loggedUserInfo?.username ?? '';
    // First use avatar url in homepage, null means current webpage layout does
    // not provide one.
    // Then use avatar url in profile page.
    // In fact we can use the one in  profile page directly.
    final avatarUrl = widget.loggedUserInfo?.avatarUrl;

    if (!context.mounted) {
      return sizedBoxEmpty;
    }

    return Column(
      children: [
        _buildKahrpbaSwiper(context, widget.swiperUrlList),
        sizedBoxW4H4,
        Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.hardEdge,
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
                    disableHero: true,
                  ),
                ),
                title: GestureDetector(
                  onTap: () async => context.pushNamed(
                    ScreenPaths.loggedUserProfile,
                    queryParameters: {'hero': username},
                  ),
                  child: Text(
                    username,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              ..._buildKahrpbaLinkTileList(
                context,
                widget.loggedUserInfo?.relatedLinkPairList,
              ),
              _buildForumStatusRow(context, widget.forumStatus),
              sizedBoxW8H8,
            ],
          ),
        ),
      ],
    );
  }

  void setupSwiperTimer(int itemCount) {
    _swiperTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      double? target;
      if (_reverseSwiper) {
        if (_swiperController.offset <= 100) {
          setState(() {
            _reverseSwiper = false;
          });
        } else {
          target = _swiperController.offset - _kahrpbaPicWidth;
        }
      } else {
        if (_swiperController.offset >= (itemCount - 3) * _kahrpbaPicWidth) {
          setState(() {
            _reverseSwiper = true;
          });
        } else {
          target = _swiperController.offset + _kahrpbaPicWidth;
        }
      }
      if (target != null) {
        _swiperController.animateTo(
          target,
          duration: duration200,
          curve: Curves.ease,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _swiperController = CarouselController();
    setupSwiperTimer(widget.swiperUrlList.length);
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
          setupSwiperTimer(widget.swiperUrlList.length);
        } else {
          _swiperTimer?.cancel();
        }
      },
      child: _buildSection(context),
    );
  }
}
