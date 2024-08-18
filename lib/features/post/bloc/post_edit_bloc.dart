import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/features/post/exceptions/exceptions.dart';
import 'package:tsdm_client/features/post/models/post_edit_content.dart';
import 'package:tsdm_client/features/post/repository/post_edit_repository.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:universal_html/html.dart' as uh;

part 'post_edit_bloc.mapper.dart';
part 'post_edit_event.dart';

part 'post_edit_state.dart';

/// Emitter for post edit.
typedef PostEditEmit = Emitter<PostEditState>;

/// Bloc of editing a post.
final class PostEditBloc extends Bloc<PostEditEvent, PostEditState>
    with LoggerMixin {
  /// Constructor.
  PostEditBloc({required PostEditRepository postEditRepository})
      : _postEditRepository = postEditRepository,
        super(const PostEditState()) {
    on<PostEditLoadDataRequested>(_onPostEditLoadDataRequested);
    on<PostEditCompleteEditRequested>(_onPostEditCompleteEditRequested);
  }

  final PostEditRepository _postEditRepository;

  Future<void> _onPostEditLoadDataRequested(
    PostEditLoadDataRequested event,
    PostEditEmit emit,
  ) async {
    emit(state.copyWith(status: PostEditStatus.loading));
    try {
      final document = await _postEditRepository.fetchData(event.editUrl);
      final content = _parseContent(document);
      if (content == null) {
        emit(state.copyWith(status: PostEditStatus.failedToLoad));
        return;
      }
      emit(state.copyWith(status: PostEditStatus.editing, content: content));
    } on HttpRequestFailedException catch (e) {
      error('failed to load post edit data: $e');
      emit(state.copyWith(status: PostEditStatus.failedToLoad));
    }
  }

  Future<void> _onPostEditCompleteEditRequested(
    PostEditCompleteEditRequested event,
    PostEditEmit emit,
  ) async {
    emit(state.copyWith(status: PostEditStatus.uploading));
    try {
      await _postEditRepository.postEditedContent(
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
        options: Map.fromEntries(
          event.options
              .where((e) => !e.disabled && e.checked)
              .map((e) => MapEntry(e.name, e.value)),
        ),
      );
      emit(state.copyWith(status: PostEditStatus.success));
    } on HttpRequestFailedException catch (e) {
      error('failed to post edited post data: $e');
      emit(state.copyWith(status: PostEditStatus.failedToUpload));
    } on PostEditFailedToUploadResult catch (e) {
      error('failed to post edited post data: $e');
      emit(
        state.copyWith(
          status: PostEditStatus.failedToUpload,
          errorText: e.errorText,
        ),
      );
    }
  }

  PostEditContent? _parseContent(uh.Document document) {
    final rootNode = document.querySelector('div#ct');
    final postBoxNode = document.querySelector('div#postbox');

    // Similar to what we do in the forum feature:
    // Load thread types dynamically:
    //
    // Example raw data:
    //
    // ```html
    // <div class="pbt cl">
    //   <div class="ftid">
    //     <select name="typeid" id="typeid" width="80">
    //       <option value="0">选择主题分类</option>
    //       <option value="1968">活动</option>
    //       <option value="3777">提问</option>
    //       <option value="4413" selected="selected">新人报道</option>
    //       <option value="4414">旧人回归</option>
    //       <option value="4415">掉号报道</option>
    //     </select>
    //   </div>
    //   <div class="z">
    //     <span><input style="width: 25em" type="text" name="subject" id="subject" class="px" value="${thread_title}" onkeyup="strLenCalc(this, 'checklen', 210);" tabindex="1"></span>
    //     <span id="subjectchk">还可输入 <strong id="checklen">210</strong> 个字符</span>
    //   </div>
    // </div>
    // ```
    final threadTypeList = postBoxNode
        ?.querySelector('div select')
        ?.querySelectorAll('option')
        .where(
          (e) => e.attributes['value'] != null && e.innerText.trim().isNotEmpty,
        )
        .map(
          (e) => PostEditThreadType(
            name: e.innerText.trim(),
            typeID: e.attributes['value'],
          ),
        )
        .toList();

    // Current thread type.
    PostEditThreadType? threadType;
    final threadTypeNode =
        postBoxNode?.querySelector('div select > option[selected="selected"]');
    if (threadTypeNode != null) {
      threadType = PostEditThreadType(
        name: threadTypeNode.innerText.trim(),
        typeID: threadTypeNode.attributes['value'],
      );
    }

    // Thread title.
    // Max length is 210 bytes (utf-8).
    final threadTitle =
        postBoxNode?.querySelector('div.z > span > input')?.attributes['value'];
    final threadTitleMaxLength = postBoxNode
        ?.querySelector('div.z > span > input')
        ?.attributes['onkeyup']
        ?.split(' ')
        .lastOrNull
        ?.replaceFirst(');', '')
        .parseToInt();

    // Parse response parameters.
    final formHash =
        rootNode?.querySelector('input[name="formhash"]')?.attributes['value'];
    final postTime =
        rootNode?.querySelector('input[name="posttime"]')?.attributes['value'];
    final delattachop = rootNode
        ?.querySelector('input[name="delattachop"]')
        ?.attributes['value'];
    final wysiwyg =
        rootNode?.querySelector('input[name="wysiwyg"]')?.attributes['value'];
    final fid =
        rootNode?.querySelector('input[name="fid"]')?.attributes['value'];
    final tid =
        rootNode?.querySelector('input[name="tid"]')?.attributes['value'];
    final pid =
        rootNode?.querySelector('input[name="pid"]')?.attributes['value'];
    final page =
        rootNode?.querySelector('input[name="page"]')?.attributes['value'];

    // Post data.
    final data = postBoxNode?.querySelector('div.area > textarea')?.innerText;

    // Additional options;
    final options = rootNode
        ?.querySelectorAll('div#psd p.mbn')
        .where(
          (e) =>
              e.querySelector('input') != null &&
              e.querySelector('label') != null,
        )
        .map(
      (e) {
        final input = e.querySelector('input')!;
        final label = e.querySelector('label')!;

        return PostEditContentOption(
          name: input.id,
          readableName: label.innerText,
          disabled: input.attributes.containsKey('disabled'),
          checked: input.attributes.containsKey('checked'),
          value: input.attributes['value']!,
        );
      },
    ).toList();

    if (formHash == null ||
        postTime == null ||
        delattachop == null ||
        wysiwyg == null ||
        fid == null ||
        tid == null ||
        pid == null ||
        page == null ||
        data == null) {
      error('invalid post edit form data: '
          'formhash=$formHash, posttime=$postTime, '
          'delattachop=$delattachop, wysiwyg=$wysiwyg, '
          'fid=$fid, tid=$tid, pid=$pid, page=$page, data=$data');
      return null;
    }

    return PostEditContent(
      threadType: threadType,
      threadTypeList: threadTypeList,
      threadTitle: threadTitle,
      threadTitleMaxLength: threadTitleMaxLength,
      formHash: formHash,
      postTime: postTime,
      delattachop: delattachop,
      wysiwyg: wysiwyg,
      fid: fid,
      tid: tid,
      pid: pid,
      page: page,
      data: data,
      options: options,
    );
  }
}
