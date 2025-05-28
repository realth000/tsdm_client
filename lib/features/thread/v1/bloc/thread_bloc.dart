import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:tsdm_client/extensions/uri.dart';
import 'package:tsdm_client/features/forum/models/models.dart';
import 'package:tsdm_client/features/thread/v1/models/models.dart';
import 'package:tsdm_client/features/thread/v1/repository/thread_repository.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:tsdm_client/widgets/card/post_card/post_medal_menu_info.dart';
import 'package:universal_html/html.dart' as uh;

part 'thread_bloc.mapper.dart';

part 'thread_event.dart';

part 'thread_state.dart';

/// Emitter.
typedef ThreadEmitter = Emitter<ThreadState>;

/// Bloc the thread page.
class ThreadBloc extends Bloc<ThreadEvent, ThreadState> with LoggerMixin {
  /// Constructor.
  ThreadBloc({
    required String? tid,
    required String? pid,
    required String? onlyVisibleUid,
    required bool? reverseOrder,
    required int? exactOrder,
    required ThreadRepository threadRepository,
  }) : _threadRepository = threadRepository,
       super(
         ThreadState(
           tid: tid,
           pid: pid,
           onlyVisibleUid: onlyVisibleUid,
           reverseOrder: reverseOrder,
           exactOrder: exactOrder,
         ),
       ) {
    on<ThreadLoadMoreRequested>(_onThreadLoadMoreRequested);
    on<ThreadRefreshRequested>(_onThreadRefreshRequested);
    on<ThreadJumpPageRequested>(_onThreadJumpPageRequested);
    on<ThreadClosedStateUpdated>(_onThreadUpdateClosedState);
    on<ThreadOnlyViewAuthorRequested>(_onThreadOnlyViewAuthorRequested);
    on<ThreadViewAllAuthorsRequested>(_onThreadViewAllAuthorsRequested);
    on<ThreadChangeViewOrderRequested>(_onThreadChangeViewOrderRequested);
  }

  final ThreadRepository _threadRepository;

  Future<void> _onThreadLoadMoreRequested(ThreadLoadMoreRequested event, ThreadEmitter emit) async {
    if (state.status == ThreadStatus.failure) {
      // Restoring from failure.
      emit(state.copyWith(status: ThreadStatus.loading));
    }
    await _threadRepository
        .fetchThread(
          tid: state.tid,
          pid: state.pid,
          pageNumber: event.pageNumber,
          onlyVisibleUid: state.onlyVisibleUid,
          reverseOrder: state.reverseOrder,
          exactOrder: state.exactOrder,
        )
        .match((e) {
          handle(e);
          emit(state.copyWith(status: ThreadStatus.failure));
        }, (v) => _parseFromDocument(v, event.pageNumber).map((v) => emit(v)).run())
        .run();
  }

  Future<void> _onThreadRefreshRequested(ThreadRefreshRequested event, ThreadEmitter emit) async {
    emit(state.copyWith(status: ThreadStatus.loading, postList: []));
    await _threadRepository
        .fetchThread(
          tid: state.tid,
          pid: state.pid,
          onlyVisibleUid: state.onlyVisibleUid,
          reverseOrder: state.reverseOrder,
          exactOrder: state.exactOrder,
        )
        .match((e) {
          handle(e);
          emit(state.copyWith(status: ThreadStatus.failure));
        }, (v) => _parseFromDocument(v, 1).map((v) => emit(v)).run())
        .run();
  }

  Future<void> _onThreadJumpPageRequested(ThreadJumpPageRequested event, ThreadEmitter emit) async {
    emit(state.copyWith(status: ThreadStatus.loading, postList: []));
    await _threadRepository
        .fetchThread(
          tid: state.tid,
          pid: state.pid,
          pageNumber: event.pageNumber,
          onlyVisibleUid: state.onlyVisibleUid,
          reverseOrder: state.reverseOrder,
          exactOrder: state.exactOrder,
        )
        .map((v) => _parseFromDocument(v, event.pageNumber).map((v) => emit(v)).run())
        .mapLeft((e) {
          handle(e);
          emit(state.copyWith(status: ThreadStatus.failure));
        })
        .run();
  }

  Future<void> _onThreadUpdateClosedState(ThreadClosedStateUpdated event, ThreadEmitter emit) async {
    emit(state.copyWith(threadClosed: event.closed));
  }

  Future<void> _onThreadOnlyViewAuthorRequested(ThreadOnlyViewAuthorRequested event, ThreadEmitter emit) async {
    emit(state.copyWith(status: ThreadStatus.loading, postList: []));
    await _threadRepository
        .fetchThread(
          tid: state.tid,
          pid: state.pid,
          pageNumber: state.currentPage,
          onlyVisibleUid: event.uid,
          reverseOrder: state.reverseOrder,
          exactOrder: state.exactOrder,
        )
        .match(
          (e) {
            handle(e);
            error(
              'failed to load thread page: '
              'fid=${state.tid}, pageNumber=1 : $e',
            );
            emit(state.copyWith(status: ThreadStatus.failure, onlyVisibleUid: event.uid));
          },
          // Use "1" as current page number to prevent page number overflow.
          (v) => _parseFromDocument(v, 1).map((v) => emit(v.copyWith(onlyVisibleUid: event.uid))).run(),
        )
        .run();
  }

  Future<void> _onThreadViewAllAuthorsRequested(ThreadViewAllAuthorsRequested event, ThreadEmitter emit) async {
    emit(state.copyWith(status: ThreadStatus.loading, postList: []));
    // Switching from "only view specified author" to "view all authors"
    // will have more posts and pages so there is no page number overflow
    // risk.
    await _threadRepository
        .fetchThread(
          tid: state.tid,
          pid: state.pid,
          pageNumber: state.currentPage,
          reverseOrder: state.reverseOrder,
          exactOrder: state.exactOrder,
        )
        .match(
          (e) {
            handle(e);
            error(
              'failed to load thread page:'
              ' fid=${state.tid}, pageNumber=1 : $e',
            );
            emit(state.copyWith(status: ThreadStatus.failure));
          },
          (v) =>
              _parseFromDocument(
                v,
                state.currentPage,
                clearOnlyVisibleUid: true,
              ).map((v) => emit(v.copyWith(onlyVisibleUid: state.onlyVisibleUid))).run(),
        )
        .run();
  }

  Future<void> _onThreadChangeViewOrderRequested(ThreadChangeViewOrderRequested event, ThreadEmitter emit) async {
    emit(
      state.copyWith(
        status: ThreadStatus.loading,
        postList: [],
        // Set to reverse order if is null.
        // FIXME: Some threads may set reversed order, detect that in page
        //  (though impossible if only one page).
        reverseOrder: !(state.reverseOrder ?? false),
        currentPage: 1,
      ),
    );
    await _threadRepository
        .fetchThread(
          tid: state.tid,
          pid: state.pid,
          pageNumber: state.currentPage,
          onlyVisibleUid: state.onlyVisibleUid,
          reverseOrder: state.reverseOrder,
          exactOrder: state.exactOrder,
        )
        .match(
          (e) {
            error(
              'failed to load thread page: '
              'fid=${state.tid}, pageNumber=1 : $e',
            );
            emit(state.copyWith(status: ThreadStatus.failure, reverseOrder: state.reverseOrder));
          },
          (v) =>
              _parseFromDocument(
                v,
                state.currentPage,
              ).map((v) => emit(v.copyWith(reverseOrder: state.reverseOrder))).run(),
        )
        .run();
  }

  IO<ThreadState> _parseFromDocument(uh.Document document, int pageNumber, {bool? clearOnlyVisibleUid}) => IO(() {
    // Reset the thread id from document.
    final threadLink = document.querySelector('head > link')?.attributes['href'];
    final tid = threadLink?.tryParseAsUri()?.tryGetQueryParameters()?['tid'];

    final threadSoftClosed = document.querySelector('div#postlist h1.ts img[title="关闭"]') != null;
    final threadClosed = document.querySelector('form#fastpostform') == null;
    final threadDataNode = document.querySelector('div#postlist');
    final postList = Post.buildListFromThreadDataNode(threadDataNode, document.currentPage() ?? 1);
    // Title node ALWAYS has an `a` node with id `thread_subject`.
    // It's invisible in most styles and visible in 爱丽丝 style.
    final title = document.querySelector('a#thread_subject')?.text?.trim();

    final allLinksInBreadCrumb = document.querySelectorAll('div#pt a');
    final forumName = switch (allLinksInBreadCrumb.length < 2) {
      true => null,
      false => allLinksInBreadCrumb.elementAtOrNull(allLinksInBreadCrumb.length - 2)?.innerText.trim(),
    };

    final currentPage = document.currentPage() ?? pageNumber;
    final totalPages = document.totalPages() ?? pageNumber;

    var needLogin = false;
    var havePermission = true;
    uh.Element? permissionDeniedMessage;
    if (postList.isEmpty) {
      // Here both normal thread list and subreddit is empty,
      // check permission.
      final docMessage = document.getElementById('messagetext');
      final docLogin = document.getElementById('messagelogin');
      if (docLogin != null) {
        needLogin = true;
      } else if (docMessage != null) {
        havePermission = false;
        permissionDeniedMessage = docMessage.querySelector('p');
      }
    }

    /// Parse thread type from thread page document.
    /// This should only run once.
    final filterTypeNode = document.querySelector('div#postlist h1.ts > a');
    final threadTypeName = filterTypeNode?.firstEndDeepText()?.replaceFirst('[', '').replaceFirst(']', '');
    final threadTypeID = filterTypeNode?.attributes['href']?.tryParseAsUri()?.tryGetQueryParameters()?['typeid'];
    final FilterType? threadType;
    if (threadTypeName != null) {
      threadType = FilterType(name: threadTypeName, typeID: threadTypeID);
    } else {
      threadType = null;
    }

    // Update reply parameters.
    // These reply parameters should be sent to [ReplyBar] later.
    final fid = document.querySelector('input[name="srhfid"]')?.attributes['value']?.parseToInt();
    final postTime = document.querySelector('input[name="posttime"]')?.attributes['value'];
    final formHash = document.querySelector('input[name="formhash"]')?.attributes['value'];
    final subject = document.querySelector('input[name="subject"]')?.attributes['value'];

    // If the post time parameter is null, only warn in log.
    // Because some subreddits do not have it.
    if (postTime == null) {
      warning(
        'null post time found in thread, '
        'reply parameter may be invalid',
      );
    }

    ReplyParameters? replyParameters;
    if (fid == null || formHash == null || subject == null) {
      error(
        'failed to get reply form hash: fid=$fid '
        'formHash=$formHash subject=$subject',
      );
    } else {
      replyParameters = ReplyParameters(
        fid: '$fid',
        tid: tid!,
        postTime: postTime,
        formHash: formHash,
        subject: subject,
      );
    }

    final isDraft = threadDataNode?.querySelector('div#postlist h1.ts > span')?.nodes.firstOrNull?.text?.contains('草稿');

    final latestModAct = document.querySelector('div.modact')?.innerText;

    // Parse breadcrumb.
    final breadcrumbs =
        document
            .querySelectorAll('div#pt > div.z > a')
            .map((e) => (e.innerText, Uri.tryParse(e.attributes['href']!.prependHost())))
            .whereType<(String, Uri)>()
            .skipWhile((e) => !(e.$2.tryGetQueryParameters()?.containsKey('gid') ?? false))
            .map((e) => ThreadBreadcrumb(description: e.$1, link: e.$2))
            .toList();
    if (breadcrumbs.isNotEmpty) {
      breadcrumbs.removeLast();
    }

    // Parse available medals. and designation-card
    final medalsAvailable =
        document
            .querySelectorAll(r'div[id^="md_"][id$="_menu"]')
            .map(PostMedalMenuItem.fromDiv)
            .whereType<PostMedalMenuItem>()
            .toList();

    final statisticsInfo =
        document
            .querySelectorAll('div#postlist > table:nth-child(1) span.xi1')
            .map((e) => e.firstEndDeepText()?.parseToInt())
            .whereType<int>();
    final int? viewCount;
    final int? replyCount;

    if (statisticsInfo.length == 2) {
      viewCount = statisticsInfo.first;
      replyCount = statisticsInfo.elementAt(1);
    } else {
      viewCount = null;
      replyCount = null;
    }

    final threadState = ThreadState(
      tid: tid,
      pid: state.pid,
      replyParameters: replyParameters,
      status: ThreadStatus.success,
      title: title ?? state.title,
      fid: fid,
      forumName: forumName,
      canLoadMore: currentPage < totalPages,
      currentPage: currentPage,
      totalPages: totalPages,
      havePermission: havePermission,
      permissionDeniedMessage: permissionDeniedMessage,
      needLogin: needLogin,
      threadSoftClosed: threadSoftClosed,
      threadClosed: threadClosed,
      postList: [...state.postList, ...postList],
      threadType: threadType,
      onlyVisibleUid: (clearOnlyVisibleUid ?? false) ? null : state.onlyVisibleUid,
      reverseOrder: state.reverseOrder,
      exactOrder: state.exactOrder,
      isDraft: isDraft ?? false,
      latestModAct: latestModAct,
      breadcrumbs: breadcrumbs,
      postMedals: medalsAvailable,
      viewCount: viewCount,
      replyCount: replyCount,
    );

    return threadState;
  });
}
