import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:tsdm_client/providers/auth_provider.dart';
import 'package:tsdm_client/providers/html_parser_provider.dart';
import 'package:tsdm_client/providers/net_client_provider.dart';
import 'package:tsdm_client/providers/settings_provider.dart';
import 'package:tsdm_client/providers/small_providers.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:universal_html/html.dart';

part '../generated/providers/root_content_provider.g.dart';

class ThreadAuthorPair {
  ThreadAuthorPair({
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
ThreadAuthorPair? _filterThreadAndAuthors(Element element) {
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

  return ThreadAuthorPair(
    threadUrl: threadUrl,
    threadTitle: threadTitle,
    authorUrl: authorUrl,
    authorName: authorName,
  );
}

/// Provider to prepare root page content from homepage "https://www.tsdm39.com/forum.php"
///
/// Also cache profile page data of current logged user.
///
// TODO: Make this a not persist provider.
@Riverpod(keepAlive: true, dependencies: [Auth, NetClient, AppSettings])
class RootContent extends _$RootContent {
  static const String _rootPage = homePage;
  static const String _profilePage = uidProfilePage;

  @override
  Future<CachedRootContent> build() async {
    return fetch();
  }

  Future<void> _fetchHomepage() async {
    debug('fetching homepage');
    _cache = CachedRootContent();
    var i = 0;
    while (i < 3) {
      final resp = await ref.read(netClientProvider()).get(_rootPage);
      if (resp.statusCode == HttpStatus.ok) {
        _doc = ref.read(htmlParserProvider.notifier).parseResp(resp);
        await ref.read(authProvider.notifier).loginFromDocument(_doc);
        final username = ref.read(authProvider.notifier).loggedUsername;
        await _cache.analyze(_doc, username);
        // Reset topics tab current tab index if reload content.
        ref.read(topicsTabBarIndexProvider.notifier).state = 0;
        break;
      }
      await Future.wait(
          [Future.delayed(const Duration(milliseconds: 400), () {})]);
      i++;
    }
  }

  Future<void> _fetchProfile() async {
    debug('fetching profile page');
    var i = 0;
    while (i < 3) {
      final uid = ref.read(appSettingsProvider).loginUid;
      // Load current user profile page.
      final profileResp =
          await ref.read(netClientProvider()).get('$_profilePage$uid');
      if (profileResp.statusCode == HttpStatus.ok) {
        _profileDoc =
            ref.read(htmlParserProvider.notifier).parseResp(profileResp);
        _avatarUrl = _profileDoc!
            .querySelector('div#wp.wp div#ct.ct2 div.sd div.hm > p > a > img')
            ?.attributes['src'];
        break;
      }
      await Future.wait(
          [Future.delayed(const Duration(milliseconds: 400), () {})]);
      i++;
    }
  }

  /// Fetch data from homepage.
  ///
  /// This will take a long time so use cached data as possible.
  Future<CachedRootContent> fetch() async {
    await Future.wait([_fetchHomepage(), _fetchProfile()]);
    return _cache;
  }

  Document get doc => _doc;

  Document? get profileDoc => _profileDoc;

  String? get avatarUrl => _avatarUrl;

  late Document _doc;

  Document? _profileDoc;

  String? _avatarUrl;

  CachedRootContent get cache => _cache;

  late CachedRootContent _cache;
}

class CachedRootContent {
  CachedRootContent();

  String usernameText = '';

  /// Avatar url may be null because webpage layout not has that.
  String? avatarUrl;
  List<String?> picUrlList = [];
  List<String?> picHrefList = [];
  List<String>? memberInfoList = [];

  List<(String, String)>? navigateHrefsPairs = [];

  List<String?>? navNameList = [];
  final sectionAllThreadPairList = <List<ThreadAuthorPair?>>[];

  List<String?> _buildKahrpbaPicUrlList(Element? styleNode) {
    if (styleNode == null) {
      debug('failed to build kahrpba picture url list: node is null');
      return [];
    }

    return styleNode
        .innerHtmlEx()
        .split('\n')
        .where((e) => e.startsWith('.Kahrpba_pic_') && !e.contains('ctrlbtn'))
        .map((e) => e.split('(').lastOrNull?.split(')').firstOrNull)
        .toList();
  }

  List<String?> _buildKahrpbaPicHrefList(Element? scriptNode) {
    if (scriptNode == null) {
      debug('failed to build kahrpba picture href list: node is null');
      return [];
    }

    return scriptNode
        .innerHtmlEx()
        .split('\n')
        .where((e) => e.contains("window.location='"))
        .map((e) => e
            .split("window.location='")
            .lastOrNull
            ?.split("'")
            .firstOrNull
            ?.replaceFirst('&amp;', '&'))
        .toList();
  }

  Future<void> analyze(Document document, String? username) async {
    final chartZNode = document.querySelector('p.chart.z');
    final styleNode =
        // Style 1: Without welcome text.
        document.querySelector('div.mn > style') ??
            // Style 2: With welcome text.
            document.querySelector('div#chart > style');
    final scriptNode =
        // Style 1: Without welcome text.
        document.querySelector('div.mn > script') ??
            // Style 2: With welcome text
            document.querySelector('div#chart > script');
    picUrlList = _buildKahrpbaPicUrlList(styleNode);
    picHrefList = _buildKahrpbaPicHrefList(scriptNode);
    if (picUrlList.isEmpty && picHrefList.isEmpty) {
      debug('root content pinned pic not found: maybe not login');

      // There's no pinned recent threads when not login, just return
      return;
    }
    final chartZInfoList = chartZNode?.querySelectorAll('em').toList();
    memberInfoList = chartZInfoList
            ?.map((e) => e.text)
            .whereType<String>()
            .toList(growable: false) ??
        [];

    final welcomeNode = document
        .querySelector('div#wp.wp div#ct.wp.cl div#chart.bm.bw0.cl div.y');
    usernameText = username ?? '';
    avatarUrl = document
        .querySelector('div#hd div.wp div.hdc.cl div#um div.avt.y a img')
        ?.attributes['src'];
    navigateHrefsPairs = welcomeNode
        ?.querySelectorAll('a')
        .where((e) => e.attributes.containsKey('href'))
        .map((e) => (e.firstEndDeepText() ?? 'unknown', e.attributes['href']!))
        .toList();

    navNameList = document
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
        navNameList?.length != navShowList.length) {
      debug(
          'failed to parse homepage pin section: navName length: ${navNameList?.length}, navShowList length: ${navShowList?.length}');
      return;
    }

    final count = navNameList!.length;
    for (var i = 0; i < count; i++) {
      sectionAllThreadPairList.add(navShowList[i]
          .querySelectorAll('div.Kahrpba_threads')
          .map(_filterThreadAndAuthors)
          .toList());
    }

    // The sort on server side is not as displayed, fix the sort to keep the same
    // with website appearance.
    if (sectionAllThreadPairList.length >= 7) {
      sectionAllThreadPairList
        ..swap(4, 5)
        ..swap(5, 6);
    }
  }
}
