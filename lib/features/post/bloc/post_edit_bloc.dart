import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/extensions/fp.dart';
import 'package:tsdm_client/features/post/models/models.dart';
import 'package:tsdm_client/features/post/repository/post_edit_repository.dart';
import 'package:tsdm_client/utils/logger.dart';

part 'post_edit_bloc.mapper.dart';
part 'post_edit_event.dart';
part 'post_edit_state.dart';

/// Emitter for post edit.
typedef _Emit = Emitter<PostEditState>;

/// Bloc of editing a post.
final class PostEditBloc extends Bloc<PostEditEvent, PostEditState>
    with LoggerMixin {
  /// Constructor.
  PostEditBloc({required PostEditRepository postEditRepository})
      : _repo = postEditRepository,
        super(const PostEditState()) {
    on<PostEditLoadDataRequested>(_onPostEditLoadDataRequested);
    on<PostEditCompleteEditRequested>(_onPostEditCompleteEditRequested);
    on<ThreadPubFetchInfoRequested>(
      (event, emit) => _onFetchNewThreadInfo(event.fid, emit),
    );
    on<ThreadPubPostThread>(
      (event, emit) => _onPostNewThread(event.info, emit),
    );
  }

  static final _tidRe = RegExp(r'tid=(?<tid>\d+)');

  final PostEditRepository _repo;

  Future<void> _onPostEditLoadDataRequested(
    PostEditLoadDataRequested event,
    _Emit emit,
  ) async {
    emit(state.copyWith(status: PostEditStatus.loading));
    await _repo.fetchData(event.editUrl).match(
      (e) {
        handle(e);
        error('failed to load post edit data: $e');
        emit(state.copyWith(status: PostEditStatus.failedToLoad));
      },
      (v) {
        final document = v;
        final content = PostEditContent.fromDocument(document);
        if (content == null) {
          emit(state.copyWith(status: PostEditStatus.failedToLoad));
          return;
        }
        emit(
          state.copyWith(status: PostEditStatus.editing, content: content),
        );
      },
    ).run();
  }

  Future<void> _onPostEditCompleteEditRequested(
    PostEditCompleteEditRequested event,
    _Emit emit,
  ) async {
    emit(state.copyWith(status: PostEditStatus.uploading));
    await _repo
        .postEditedContent(
      formHash: event.formHash,
      postTime: event.postTime,
      delattachop: event.delattachop,
      wysiwyg: event.wysiwyg,
      fid: event.fid,
      tid: event.tid,
      pid: event.pid,
      page: event.page,
      threadType: event.threadType?.typeID,
      threadTitle: event.threadTitle,
      data: event.data,
      save: event.save,
      options: Map.fromEntries(
        event.options
            .where((e) => !e.disabled && e.checked)
            .map((e) => MapEntry(e.name, e.value)),
      ),
    )
        .match(
      (e) {
        handle(e);
        error('failed to post edited post data: $e');
        if (e case HttpRequestFailedException()) {
          emit(state.copyWith(status: PostEditStatus.failedToUpload));
        } else if (e case PostEditFailedToUploadResult()) {
          emit(
            state.copyWith(
              status: PostEditStatus.failedToUpload,
              errorText: e.errorText,
            ),
          );
        }
      },
      (v) => emit(state.copyWith(status: PostEditStatus.success)),
    ).run();
  }

  Future<void> _onFetchNewThreadInfo(String fid, _Emit emit) async {
    emit(state.copyWith(status: PostEditStatus.loading));

    final docEither = await _repo.prepareInfo(fid).run();
    if (docEither.isLeft()) {
      handle(docEither.unwrapErr());
      emit(state.copyWith(status: PostEditStatus.failedToLoad));
      return;
    }

    final doc = docEither.unwrap();

    final editContent = PostEditContent.fromDocument(
      doc,
      requireThreadInfo: false,
    );
    if (editContent == null) {
      error('failed to build edit content');
      emit(state.copyWith(status: PostEditStatus.failedToLoad));
      return;
    }

    final forumName = doc
        .querySelectorAll('div#pt > div.z > a[href*="&fid="]')
        .lastOrNull
        ?.text;

    emit(
      state.copyWith(
        status: PostEditStatus.editing,
        content: editContent,
        forumName: forumName,
      ),
    );
  }

  Future<void> _onPostNewThread(
    ThreadPublishInfo info,
    _Emit emit,
  ) async {
    emit(state.copyWith(status: PostEditStatus.uploading));

    final tidEither = await _repo.postThread(info).run();
    if (tidEither.isLeft()) {
      handle(tidEither.unwrapErr());
      emit(state.copyWith(status: PostEditStatus.failedToUpload));
      return;
    }
    final tid = _tidRe.firstMatch(tidEither.unwrap())?.namedGroup('tid');

    emit(
      state.copyWith(
        status: PostEditStatus.success,
        redirectTid: tid,
      ),
    );
  }
}
