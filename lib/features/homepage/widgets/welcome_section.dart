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
        constraints: const BoxConstraints(maxHeight: _kahrpbaPicHeight),
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
          children: swiperUrlList.map((e) => CachedImage(e.coverUrl)).toList(),
        ),
      ),
    );
  }

  // Widget _buildForumStatusRow(BuildContext context, ForumStatus forumStatus)
  // {
  //   return Padding(
  //     padding: edgeInsetsL12T12R12,
  //     child: SingleLineText(
  //       '今日:${forumStatus.todayCount} 昨日:${forumStatus.yesterdayCount} '
  //       '帖子:${forumStatus.threadCount}',
  //       style: TextStyle(
  //         color: Theme.of(context).colorScheme.secondary,
  //       ),
  //       textAlign: TextAlign.center,
  //     ),
  //   );
  // }

  Widget _buildSection(BuildContext context) {
    if (!context.mounted) {
      return sizedBoxEmpty;
    }

    return _buildKahrpbaSwiper(context, widget.swiperUrlList);
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
