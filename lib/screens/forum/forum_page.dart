import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/models/forum.dart';
import 'package:tsdm_client/models/normal_thread.dart';
import 'package:tsdm_client/packages/html_muncher/lib/src/html_muncher.dart';
import 'package:tsdm_client/providers/net_client_provider.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:tsdm_client/utils/easy_refresh.dart';
import 'package:tsdm_client/widgets/forum_card.dart';
import 'package:tsdm_client/widgets/list_sliver_app_bar.dart';
import 'package:tsdm_client/widgets/thread_card.dart';
import 'package:universal_html/html.dart' as uh;
import 'package:universal_html/parsing.dart';
import 'package:url_launcher/url_launcher.dart';

/// Forum page.
class ForumPage extends ConsumerStatefulWidget {
  /// Constructor.
  const ForumPage({
    required this.fid,
    required this.routerState,
    this.title,
    super.key,
  }) : _fetchUrl = '$baseUrl/forum.php?mod=forumdisplay&fid=$fid';

  final String fid;

  final String? title;

  final String _fetchUrl;

  final GoRouterState routerState;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ForumPageState();
}

class _ForumPageState extends ConsumerState<ForumPage>
    with SingleTickerProviderStateMixin {
  /// All thread in this forum.
  final _allThreadData = <NormalThread>[];

  /// All subreddit.
  var _allSubredditData = <Forum>[];

  /// Controller of thread tab.
  final _listScrollController = ScrollController();

  /// Controller of the [EasyRefresh] in thread tab.
  final _refreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  /// Current page number.
  int _pageNumber = 1;

  /// Whether we are in the last page.
  bool _inLastPage = false;

  /// Controller of current tab: thread, subreddit.
  TabController? tabController;

  /// Indicate whether there are threads in this forum.
  /// This can only set to true after parsing web page and no thread found.
  /// Use to distinguish "parsed and no thread found" and "no thread data in list
  /// currently, maybe before parsing".
  bool _haveNoThread = false;

  /// A widget to show when a logged user have no permission to this forum.
  Widget? _noPermissionFallbackDialog;

  /// Build thread tab.
  List<NormalThread> _buildThreadList(uh.Document document) {
    final normalThreadData = <NormalThread>[];
    final threadList = document.querySelectorAll('tbody.tsdm_normalthread');
    if (threadList.isEmpty) {
      return normalThreadData;
    }

    for (final threadElement in threadList) {
      final thread = NormalThread.fromTBody(threadElement);
      if (!thread.isValid()) {
        continue;
      }
      normalThreadData.add(thread);
    }
    return normalThreadData;
  }

  List<Forum> _buildForumList(uh.Document document) {
    final subredditRootNode =
        document.querySelector('div#subforum_${widget.fid}');
    if (subredditRootNode == null) {
      return [];
    }

    return subredditRootNode
        .querySelectorAll('table > tbody > tr')
        .map(Forum.fromFlRowNode)
        .where((e) => e.isValid())
        .toList();
  }

  void _clearData() {
    _pageNumber = 1;
    _allThreadData.clear();
  }

  /// Check whether in the last page in a web page (consists a series of pages).
  ///
  /// When already in the last page, current page mark (the <strong> node) is
  /// the last child of pagination indicator node.
  ///
  /// <div class="pgt">
  ///   <div class="pg">
  ///     <a class="url_to_page1"></a>
  ///     <a class="url_to_page2"></a>
  ///     <a class="url_to_page3"></a>
  ///     <strong>4</strong>           <-  Here we are in the last page
  ///   </div>
  /// </div>
  ///
  /// Typically when the web page only have one page, there is no pg node:
  ///
  /// <div class="pgt">
  ///   <span>...</span>
  /// </div>
  ///
  /// Indicating can not load more.
  bool canLoadMore(uh.Document document) {
    final barNode = document.getElementById('pgt');

    if (barNode == null) {
      debug('failed to check can load more: node not found');
      return false;
    }

    final paginationNode = barNode.querySelector('div.pg');
    if (paginationNode == null) {
      // Only one page, can not load more.
      return false;
    }

    final lastNode = paginationNode.children.lastOrNull;
    if (lastNode == null) {
      debug('failed to check can load more: empty pagination list');
      return false;
    }

    // If we are in the last page, the last node should be a "strong" type node.
    if (lastNode.nodeType != uh.Node.ELEMENT_NODE) {
      return false;
    }
    return lastNode.localName != 'strong';
  }

  Future<void> _loadData() async {
    if (mounted) {
      setState(() {
        // Before refresh, set this flag to false because we try to load thread
        // again and before loading finish we can't tell we have threads in forum
        // or not.
        _haveNoThread = false;
      });
    }

    late final uh.Document document;
    final d1 = await ref.read(netClientProvider()).get<dynamic>(
          '${widget._fetchUrl}&page=$_pageNumber',
        );
    document = parseHtmlDocument(d1.data as String);

    // Subreddit.
    _allSubredditData = _buildForumList(document);
    // Build subreddit first, so when thread list is empty, we can know whether
    // it is a web request error or permission denied or just need to go into
    // subreddit.
    final data = _buildThreadList(document);

    if (!mounted) {
      return;
    }

    // Check if we have permission to visit this forum
    if (_allThreadData.isEmpty) {
      // First check if we have subreddit.
      if (_allSubredditData.isNotEmpty) {
        // We have subreddit, this forum is only a "redirect" to other forums.
        // Redirect to subreddit page.
        tabController?.animateTo(1,
            duration: const Duration(milliseconds: 500));
        return;
      }

      // Here both thread list and subreddit is empty.

      // Check need to login or not.
      final docTitle = document.getElementsByTagName('title');
      final docMessage = document.getElementById('messagetext');
      final docAccessRequire = docMessage?.nextElementSibling?.innerHtml;
      final docLogin = document.getElementById('messagelogin');
      if (docLogin != null) {
        debug(
            'failed to build forum page, thread is empty. Maybe need to login ${docTitle.first.text} ${docMessage?.text} ${docAccessRequire ?? ''} ${docLogin == null}');
        context.pushReplacementNamed(
          ScreenPaths.login,
          extra: <String, dynamic>{
            'redirectBackState': widget.routerState,
          },
        );
        return;
      }

      // Already login, check permission.
      if (docMessage == null) {
        // Can not find message. treat as unknown result.
        debug('failed to visit fid=${widget.fid}, unknown result');
        return;
      }

      // Munch html document at node [docMessage] to flutter widget as fallback
      // widget, take place of tab bar view.
      setState(() {
        _noPermissionFallbackDialog =
            Center(child: munchElement(context, docMessage));
      });
    }

    setState(() {
      _allThreadData.addAll(data);
      _haveNoThread = _allThreadData.isEmpty;
    });
    _pageNumber++;

    // Update whether we are in the last page.
    _inLastPage = !canLoadMore(document);
  }

  Widget _buildThreadListTab(BuildContext context, WidgetRef ref) {
    return EasyRefresh(
      scrollBehaviorBuilder: buildScrollBehavior,
      header: header,
      footer: footer,
      controller: _refreshController,
      scrollController: _listScrollController,
      onRefresh: () async {
        if (!mounted) {
          return;
        }
        _clearData();
        await _loadData();
        _refreshController
          ..finishRefresh()
          ..resetFooter();
      },
      onLoad: () async {
        if (!mounted) {
          return;
        }
        if (_inLastPage) {
          debug('already in last page');
          _refreshController.finishLoad(IndicatorResult.noMore);
          return;
        }

        await _loadData();
        _refreshController.finishLoad();
      },
      child: CustomScrollView(
        controller: _listScrollController,
        slivers: [
          const HeaderLocator.sliver(),
          if (_allThreadData.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 20),
              sliver: SliverList.separated(
                itemCount: _allThreadData.length,
                itemBuilder: (context, index) =>
                    ThreadCard(_allThreadData[index]),
                separatorBuilder: (context, index) => const SizedBox(
                  width: 2,
                  height: 2,
                ),
              ),
            ),
          // Use _haveNoThread to ensure we parsed the web page and there really
          // no thread in the forum.
          if (_haveNoThread)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Center(
                  child: Text(
                    context.t.forumPage.threadTab.noThread,
                    style: Theme.of(context).inputDecorationTheme.hintStyle,
                  ),
                ),
              ),
            ),
          const FooterLocator.sliver(),
        ],
      ),
    );
  }

  Widget _buildSubredditTab(BuildContext context, WidgetRef ref) {
    if (_allSubredditData.isEmpty) {
      return Center(child: Text(context.t.forumPage.subredditTab.noSubreddit));
    }

    return ListView.separated(
      padding: const EdgeInsets.only(
        left: 15,
        right: 15,
        top: 5,
        bottom: 20,
      ),
      itemCount: _allSubredditData.length,
      itemBuilder: (context, index) => ForumCard(_allSubredditData[index]),
      separatorBuilder: (context, index) {
        return const SizedBox(width: 10, height: 10);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // Call refresh here instead of setting [EasyRefresh]'s refreshOnStart to true.
    // Load data when page built and avoid loading data when switching between
    // tabs every time.
    //
    // Seems without [Future.delayed()] the loading header is not visible.
    if (_allThreadData.isEmpty) {
      Future.delayed(const Duration(milliseconds: 10), () async {
        await _refreshController.callRefresh();
      });
    }
  }

  @override
  void dispose() {
    _listScrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    tabController ??= TabController(
      length: 2,
      vsync: this,
    );

    return Scaffold(
      appBar: ListSliverAppBar(
        title: widget.title,
        bottom: _noPermissionFallbackDialog == null
            ? TabBar(
                controller: tabController,
                tabs: [
                  Tab(child: Text(context.t.forumPage.threadTab.title)),
                  Tab(child: Text(context.t.forumPage.subredditTab.title)),
                ],
              )
            : null,
        onSelected: (value) async {
          switch (value) {
            case MenuActions.refresh:
              await _refreshController.callRefresh();
            case MenuActions.copyUrl:
              await Clipboard.setData(
                ClipboardData(text: widget._fetchUrl),
              );
              if (!context.mounted) {
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                  context.t.aboutPage.copiedToClipboard,
                ),
              ));
            case MenuActions.openInBrowser:
              await launchUrl(
                Uri.parse(widget._fetchUrl),
                mode: LaunchMode.externalApplication,
              );
            case MenuActions.backToTop:
              await _listScrollController.animateTo(
                0,
                curve: Curves.ease,
                duration: const Duration(milliseconds: 500),
              );
          }
        },
      ),
      body: _noPermissionFallbackDialog ??
          TabBarView(
            controller: tabController,
            children: [
              _buildThreadListTab(context, ref),
              _buildSubredditTab(context, ref),
            ],
          ),
    );
  }
}
