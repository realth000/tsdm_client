import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:tsdm_client/extensions/fp.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/shared/repositories/forum_home_repository/forum_home_repository.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:universal_html/html.dart' as uh;

part 'topics_bloc.mapper.dart';
part 'topics_event.dart';
part 'topics_state.dart';

/// Bloc of topic.
class TopicsBloc extends Bloc<TopicsEvent, TopicsState> with LoggerMixin {
  /// Constructor.
  TopicsBloc({required ForumHomeRepository forumHomeRepository})
    : _forumHomeRepository = forumHomeRepository,
      super(const TopicsState()) {
    on<TopicsLoadRequested>(_onTopicsLoadRequested);
    on<TopicsRefreshRequested>(_onTopicsRefreshRequested);
    on<TopicsTabSelected>(_onTopicsTabSelected);
  }

  final ForumHomeRepository _forumHomeRepository;

  Future<void> _onTopicsLoadRequested(TopicsLoadRequested event, Emitter<TopicsState> emit) async {
    emit(state.copyWith(status: TopicsStatus.loading));
    final documentEither = await _forumHomeRepository.fetchTopicPage().run();
    if (documentEither.isLeft()) {
      handle(documentEither.unwrapErr());
      emit(state.copyWith(status: TopicsStatus.failed));
      return;
    }
    final document = documentEither.unwrap();
    final forumGroupList = _buildGroupListFromDocument(document);
    emit(state.copyWith(status: TopicsStatus.success, forumGroupList: forumGroupList));
  }

  Future<void> _onTopicsRefreshRequested(TopicsRefreshRequested event, Emitter<TopicsState> emit) async {
    emit(state.copyWith(status: TopicsStatus.loading));

    final documentEither = await _forumHomeRepository.fetchTopicPage(force: true).run();
    if (documentEither.isLeft()) {
      handle(documentEither.unwrapErr());
      emit(state.copyWith(status: TopicsStatus.failed));
      return;
    }
    final document = documentEither.unwrap();
    final forumGroupList = _buildGroupListFromDocument(document);
    emit(state.copyWith(status: TopicsStatus.success, forumGroupList: forumGroupList));
  }

  void _onTopicsTabSelected(TopicsTabSelected event, Emitter<TopicsState> emit) {
    emit(state.copyWith(topicsTab: event.tabIndex));
  }

  List<ForumGroup> _buildGroupListFromDocument(uh.Document document) {
    final forumGroupNodeList = [
      // Style 1: With user avatar
      ...document.querySelectorAll('div#ct > div.mn > div.fl.bm > div.bm.bmw.cl'),
      // Style 2: Without user avatar and with welcome text.
      ...document.querySelectorAll('div.mn.miku > div.forumlist > div.forumbox'),
    ];
    final forumGroupList = forumGroupNodeList.map(_buildFromBMNode).toList();
    return forumGroupList;
  }

  /// Build from <div class="bm bmw flg cl"> or <div class="forumbox"> [element]
  static ForumGroup _buildFromBMNode(uh.Element element) {
    final titleNode =
        element.querySelector('div:nth-child(1) > h2') ??
        // Style 5
        element.querySelector('div.title_r > h2 > a');
    final name = titleNode?.firstEndDeepText();
    final url = titleNode?.attributes['href'];

    final subForumNodeList = element.querySelectorAll('div:nth-child(2) > table > tbody > tr').toList();

    final forumList = <Forum>[];
    for (final subForumNode in subForumNodeList) {
      // If children is empty, these are invisible elements in web page, skip.
      if (subForumNode.children.isEmpty) {
        continue;
      }

      // Here we can not tell whether the sub forums are in expanded layout or
      // not by checking element attributes.
      // The only way to check this is looking at the image node in sub forums.

      // Expanded layout forum layout.
      if (subForumNode.querySelector('h2') != null) {
        final forum = _buildExpandedForum(subForumNode);
        forumList.add(forum);
        continue;
      }

      // Normal layout forum has attribute class=fl_g
      final forumFlGNodeList = subForumNode.querySelectorAll('td.fl_g').toList();
      if (forumFlGNodeList.isEmpty) {
        continue;
      }
      forumList.addAll(forumFlGNodeList.map(_buildCollapsedForum));
    }

    return ForumGroup(name: name ?? '', url: url ?? '', forumList: forumList);
  }

  static Forum _buildCollapsedForum(uh.Element element) {
    final titleNode =
        element.querySelector('div.tsdm_fl_inf > dl > dt > a') ??
        // Style 5
        element.querySelector('dl > dt > a');
    final name = titleNode?.firstEndDeepText();
    final url = titleNode?.firstHref();
    final forumID = url?.split('fid=').lastOrNull?.parseToInt();

    final iconUrl = element.querySelector('div.fl_icn_g > a > img')?.dataOriginalOrSrcImgUrl();

    final threadCount =
        // Style 1
        element
            .querySelector(
              'div.tsdm_fl_inf > dl > dd > em:nth-child(1) > '
              'span:nth-child(2)',
            )
            ?.firstEndDeepText()
            ?.parseToInt() ??
        // Style 2
        //
        // <em>主题: 47857</em>, <em>帖数: 169905</em>
        //
        element
            .querySelector('div.tsdm_fl_inf > dl > dd > em:nth-child(1)')
            ?.firstEndDeepText()
            ?.split(' ')
            .elementAtOrNull(1)
            ?.parseToInt() ??
        // Style 3: With welcome text and without avatar.
        //
        // <em> <font>主题</font> <font>12345</font> </em>
        //
        element
            .querySelector(
              'div.tsdm_fl_inf > dl > dd > em:nth-child(1) > '
              'font:nth-child(2)',
            )
            ?.firstEndDeepText()
            ?.parseToInt() ??
        // Style 5
        element.querySelector('dl > dd > em:nth-child(1)')?.firstEndDeepText()?.split(' ').lastOrNull?.parseToInt();
    final replyCount =
        // Style 1
        element
            .querySelector(
              'div.tsdm_fl_inf > dl > dd > em:nth-child(2) > '
              'span:nth-child(2)',
            )
            ?.firstEndDeepText()
            ?.parseToInt() ??
        // Style 2
        //
        // <em>主题: 47857</em>, <em>帖数: 169905</em>
        //
        element
            .querySelector('div.tsdm_fl_inf > dl > dd > em:nth-child(2)')
            ?.firstEndDeepText()
            ?.split(' ')
            .elementAtOrNull(1)
            ?.parseToInt() ??
        // Style 3: With welcome text and without avatar.
        //
        // <em> <font>主题</font> <font>12345</font> </em>
        //
        element
            .querySelector(
              'div.tsdm_fl_inf > dl > dd > em:nth-child(2) > '
              'font:nth-child(2)',
            )
            ?.firstEndDeepText()
            ?.parseToInt() ??
        // Style 5
        element.querySelector('dl > dd > em:nth-child(2)')?.firstEndDeepText()?.split(' ').lastOrNull?.parseToInt();
    final threadTodayCount =
        element
            .querySelector('div.tsdm_fl_inf > dl > dd > em:nth-child(3)')
            ?.firstEndDeepText()
            ?.replaceFirst(' (', '')
            .replaceFirst(')', '')
            .parseToInt() ??
        element
            .querySelector('div.tsdm_fl_inf > dl > dt > em')
            ?.firstEndDeepText()
            ?.replaceFirst(' (', '')
            .replaceFirst(')', '')
            .parseToInt() ??
        // Style 3: With welcome text and without avatar.
        //
        // <em> <font>主题</font> <font>12345</font> </em>
        //
        element
            .querySelector('div.tsdm_fl_inf > dl > dd > em:nth-child(3) > font:nth-child(2)')
            ?.firstEndDeepText()
            ?.parseToInt() ??
        // Style 5
        element
            .querySelector('dl > dt > em')
            ?.firstEndDeepText()
            ?.split('(')
            .lastOrNull
            ?.split(')')
            .firstOrNull
            ?.parseToInt();

    final latestThreadNode = element.querySelector('div.tsdm_fl_inf > dl > dd:nth-child(3) > a');
    var latestThreadTime = latestThreadNode?.querySelector('span')?.attributes['title']?.parseToDateTimeUtc8();
    final latestThreadTimeText = latestThreadNode?.innerText;
    if (latestThreadTime == null && (latestThreadTimeText?.contains('最后发表: ') ?? false)) {
      latestThreadTime = latestThreadTimeText!.replaceFirst('最后发表: ', '').parseToDateTimeUtc8();
    }
    final latestThreadUrl = latestThreadNode?.firstHref();

    return Forum(
      forumID: forumID ?? -1,
      url: url ?? '',
      name: name ?? '',
      iconUrl: iconUrl ?? '',
      threadCount: threadCount ?? -1,
      replyCount: replyCount ?? -1,
      threadTodayCount: threadTodayCount,
      latestThreadTime: latestThreadTime,
      latestThreadTimeText: latestThreadTimeText,
      latestThreadUrl: latestThreadUrl,
    );
  }

  /// Build from '<tr class="fl_row">' of '<tr>' (only the first row in table)
  /// node [element] inside table, with expanded layout.
  static Forum _buildExpandedForum(uh.Element element) {
    final titleNode =
        element.querySelector('td:nth-child(2) > h2 > a') ??
        // Theme 旅行者
        element.querySelector('td:nth-child(1) > h2 > a');
    final name = titleNode?.firstEndDeepText();
    final url = titleNode?.firstHref();
    final forumID = url?.split('fid=').lastOrNull?.parseToInt();

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
      forumID: forumID ?? -1,
      url: url ?? '',
      name: name ?? '',
      iconUrl: iconUrl ?? '',
      threadCount: threadCount ?? -1,
      replyCount: replyCount ?? -1,
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
