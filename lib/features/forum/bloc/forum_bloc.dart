import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:tsdm_client/features/forum/repository/forum_repository.dart';
import 'package:tsdm_client/shared/models/forum.dart';
import 'package:tsdm_client/shared/models/normal_thread.dart';
import 'package:tsdm_client/shared/models/stick_thread.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:universal_html/html.dart' as uh;

part 'forum_event.dart';
part 'forum_state.dart';

typedef ForumEmitter = Emitter<ForumState>;

/// Bloc of forum page.
class ForumBloc extends Bloc<ForumEvent, ForumState> {
  ForumBloc({
    required String fid,
    required ForumRepository forumRepository,
  })  : _forumRepository = forumRepository,
        super(ForumState(fid: fid)) {
    //
    on<ForumLoadMoreRequested>(_onForumLoadMoreRequested);
    on<ForumRefreshRequested>(_onForumRefreshRequested);
    on<ForumJumpPageRequested>(_onForumJumpPageRequested);
  }

  final ForumRepository _forumRepository;

  Future<void> _onForumLoadMoreRequested(
    ForumLoadMoreRequested event,
    ForumEmitter emit,
  ) async {
    try {
      final document = await _forumRepository.fetchForum(
        fid: state.fid,
        pageNumber: event.pageNumber,
      );
      emit(await _parseFromDocument(document, event.pageNumber));
    } on HttpRequestFailedException catch (e) {
      debug(
          'failed to load forum page: fid=${state.fid}, pageNumber=${event.pageNumber}: $e');
      emit(state.copyWith(status: ForumStatus.failed));
    }
  }

  Future<void> _onForumRefreshRequested(
    ForumRefreshRequested event,
    ForumEmitter emit,
  ) async {
    emit(
      state.copyWith(
          status: ForumStatus.loading,
          stickThreadList: [],
          normalThreadList: [],
          subredditList: []),
    );

    try {
      final document = await _forumRepository.fetchForum(fid: state.fid);
      emit(await _parseFromDocument(document, 1));
    } on HttpRequestFailedException catch (e) {
      debug('failed to load forum page: fid=${state.fid}, pageNumber=1 : $e');
      emit(state.copyWith(status: ForumStatus.failed));
    }
  }

  Future<void> _onForumJumpPageRequested(
    ForumJumpPageRequested event,
    ForumEmitter emit,
  ) async {
    emit(state.copyWith(status: ForumStatus.loading, normalThreadList: []));

    try {
      final document = await _forumRepository.fetchForum(
        fid: state.fid,
        pageNumber: event.pageNumber,
      );
      emit(await _parseFromDocument(document, event.pageNumber));
    } on HttpRequestFailedException catch (e) {
      debug('failed to load forum page: fid=${state.fid}, pageNumber=1 : $e');
      emit(state.copyWith(status: ForumStatus.failed));
    }
  }

  Future<ForumState> _parseFromDocument(
    uh.Document document,
    int pageNumber,
  ) async {
    // Parse data.
    List<StickThread>? stickThreadList;
    List<Forum>? subredditList;
    final normalThreadList = _buildThreadList<NormalThread>(
        document, 'tsdm_normalthread', NormalThread.fromTBody);

    // When jump to other pages, pinned thread and subreddits should be reserved in state.
    // Only the first page has pinned threads and subreddits.
    if (pageNumber == 1) {
      stickThreadList = _buildThreadList<StickThread>(
          document, 'tsdm_stickthread', StickThread.fromTBody);
      subredditList = _buildForumList(document, state.fid);
    }

    var needLogin = false;
    var havePermission = true;
    uh.Element? permissionDeniedMessage;
    if (normalThreadList.isEmpty && (subredditList?.isEmpty ?? true)) {
      // Here both normal thread list and subreddit is empty, check permission.
      final docMessage = document.getElementById('messagetext');
      final docLogin = document.getElementById('messagelogin');
      if (docLogin != null) {
        needLogin = true;
      } else if (docMessage != null) {
        havePermission = false;
        permissionDeniedMessage = docMessage.querySelector('p');
      }
    }

    final allNormalThread = [...state.normalThreadList, ...normalThreadList];

    // Parse state.
    final canLoadMore = checkCanLoadMore(document);

    final currentPage = document.currentPage();
    final totalPages = document.totalPages();

    return state.copyWith(
      status: ForumStatus.success,
      stickThreadList: stickThreadList,
      normalThreadList: allNormalThread,
      subredditList: subredditList,
      canLoadMore: canLoadMore,
      needLogin: needLogin,
      havePermission: havePermission,
      permissionDeniedMessage: permissionDeniedMessage,
      currentPage: currentPage ?? pageNumber,
      totalPages: totalPages ?? currentPage ?? pageNumber,
    );
  }

  /// Build a list of thread from given html [document].
  List<T> _buildThreadList<T extends NormalThread>(
    uh.Document document,
    String threadClass,
    T? Function(uh.Element element) threadBuilder,
  ) {
    final threadList = document
        .querySelectorAll('tbody.$threadClass')
        .map((e) => threadBuilder(e))
        .whereType<T>()
        .toList();
    return threadList;
  }

  /// Build a list of [Forum] from given [document].
  List<Forum> _buildForumList(uh.Document document, String fid) {
    final subredditRootNode = document.querySelector('div#subforum_$fid');
    if (subredditRootNode == null) {
      return [];
    }

    return subredditRootNode
        .querySelectorAll('table > tbody > tr')
        .map(Forum.fromFlRowNode)
        .whereType<Forum>()
        .toList();
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
  bool checkCanLoadMore(uh.Document document) {
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
}
