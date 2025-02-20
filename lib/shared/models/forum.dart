part of 'models.dart';

/// Data model for subreddit.
@MappableClass()
final class Forum with ForumMappable {
  /// Constructor.
  const Forum({
    required this.forumID,
    required this.url,
    required this.name,
    required this.iconUrl,
    required this.threadCount,
    required this.replyCount,
    required this.latestThreadUrl,
    required this.latestThreadTime,
    required this.latestThreadTimeText,
    required this.threadTodayCount,

    /// Expanded layout only.
    this.subForumList,
    this.subThreadList,
    this.latestThreadTitle,
    this.latestThreadUserName,
    this.latestThreadUserUrl,
  });

  /// Forum id.
  final int forumID;

  /// Url of forum page.
  final String url;

  /// Forum name.
  final String name;

  /// Forum icon url.
  final String iconUrl;

  /// Total thread count.
  final int threadCount;

  /// Total reply count.
  final int replyCount;

  /// The url of latest thread in the forum.
  final String? latestThreadUrl;

  /// The publish time of the latest thread in forum.
  final DateTime? latestThreadTime;

  /// Text format of [latestThreadTime].
  final String? latestThreadTimeText;

  /// Count of thread published today.
  final int? threadTodayCount;

  /// Expanded layout only.

  /// Subreddit list.
  final List<(String subForumName, String url)>? subForumList;

  /// All sub-thread.
  final List<(String threadTitle, String url)>? subThreadList;

  /// Latest thread title.
  final String? latestThreadTitle;

  /// User name of the latest reply in latest thread.
  final String? latestThreadUserName;

  /// Url of the latest thread.
  final String? latestThreadUserUrl;

  /// Is current forum in expanded layout when parsing from server side
  /// html document.
  bool get isExpanded => latestThreadTitle != null && latestThreadUserName != null;

  /// Build a [Forum] model from <tr class="fl_row"> node.
  ///
  /// This function build from expanded style forums.
  static Forum? fromFlRowNode(uh.Element element) {
    /// Build from '<tr class="fl_row">' of '<tr>' (only the first row in table)
    /// node [element] inside table, with expanded layout.
    final titleNode =
        element.querySelector('td:nth-child(2) > h2 > a') ??
        // Theme 旅行者
        element.querySelector('td:nth-child(1) > h2 > a');
    final name = titleNode?.firstEndDeepText();
    final url = titleNode?.firstHref();
    final forumID = url?.split('fid=').lastOrNull?.parseToInt();
    if (name == null || forumID == null || url == null) {
      talker.error(
        'failed to build forum: name or fid or url not found: name=$name, '
        'fid=$forumID, url=$url',
      );
      return null;
    }

    // Allow empty.
    final iconUrl = element.querySelector('td > a > img')?.dataOriginalOrSrcImgUrl();

    final threadCount =
        (element.querySelector('td:nth-child(3) > span:nth-child(1)') ??
                // 旅行者 theme
                element.querySelector('td:nth-child(2) > span:nth-child(1)'))
            ?.firstEndDeepText()
            ?.parseToInt();
    final replyCount =
        (element.querySelector('td:nth-child(3) > span:nth-child(2)') ??
                // 旅行者 theme
                element.querySelector('td:nth-child(2) > span:nth-child(2)'))
            ?.firstEndDeepText()
            ?.split(' ')
            .lastOrNull
            ?.parseToInt();

    if (threadCount == null || replyCount == null) {
      talker.error(
        'failed to build forum: threadCount '
        'or replyCount not found',
      );
      return null;
    }

    final threadTodayCount =
        // Style 1: With avatar.
        (element.querySelector('td:nth-child(2) > h2 > em') ??
                // 旅行者 theme
                element.querySelector('td:nth-child(1) > h2 > em'))
            ?.firstEndDeepText()
            ?.split('(')
            .lastOrNull
            ?.split(')')
            .firstOrNull
            ?.parseToInt() ??
        // Style 2: With welcome text.
        (element.querySelector('td:nth-child(2) > h2 > em:nth-child(3)') ??
                // 旅行者 theme
                element.querySelector('td:nth-child(2) > h2 > em:nth-child(3)'))
            ?.firstEndDeepText()
            ?.parseToInt();

    final latestThreadNode =
        element.querySelector('td:nth-child(4) > div') ??
        // 旅行者 theme
        element.querySelector('td:nth-child(3) > div');
    final latestThreadTime = latestThreadNode?.querySelector('cite > span')?.attributes['title']?.parseToDateTimeUtc8();
    final latestThreadTimeText = latestThreadNode?.querySelector('cite > span')?.firstEndDeepText();
    final latestThreadUrl = latestThreadNode?.querySelector('a')?.firstHref();

    // Expanded layout only.
    final latestThreadTitle = latestThreadNode?.querySelector('a')?.firstEndDeepText();
    final latestThreadUserName = latestThreadNode?.querySelector('cite > a')?.firstEndDeepText();
    final latestThreadUserUrl = latestThreadNode?.querySelector('cite > a')?.firstHref();

    final subForumList =
        element
            .querySelectorAll('td > p')
            .firstWhereOrNull((e) => e.nodes.firstOrNull?.text?.contains('子版块') ?? false)
            ?.querySelectorAll('a')
            .map((e) => (e.firstEndDeepText()?.trim(), e.attributes['href']))
            .whereType<(String, String)>()
            .toList();

    final subThreadList =
        element
            .querySelectorAll('td > p a')
            .where((e) => e.attributes['href']?.contains('tid=') ?? false)
            .map((e) => (e.firstEndDeepText(), e.attributes['href']))
            .whereType<(String, String)>()
            .toList();

    return Forum(
      forumID: forumID,
      url: url,
      name: name,
      iconUrl: iconUrl ?? '',
      threadCount: threadCount,
      replyCount: replyCount,
      threadTodayCount: threadTodayCount,
      latestThreadTime: latestThreadTime,
      latestThreadTimeText: latestThreadTimeText,
      latestThreadUrl: latestThreadUrl,
      // Expanded layout only.
      latestThreadTitle: latestThreadTitle,
      latestThreadUserName: latestThreadUserName,
      latestThreadUserUrl: latestThreadUserUrl,
      subForumList: subForumList,
      subThreadList: subThreadList,
    );
  }
}
