part of 'models.dart';

/// Definition Thread type.
///
/// Only use this when editing thread.
@MappableClass()
final class PostEditThreadType with PostEditThreadTypeMappable {
  /// Constructor.
  const PostEditThreadType({required this.name, required this.typeID});

  /// Thread type name.
  ///
  /// e.g. 其他
  final String name;

  /// Type id value.
  ///
  /// e.g. &typeid=2
  ///
  /// Null value means do not filter by thread type.
  final String? typeID;
}

/// Model of extra content when editing post.
///
/// Generally, each instance represents a `<input>` node in "div#psd input".
///
/// These are extra options provided by the post edit page on server side and
/// need to set with suitable value when submit the edited content back to
/// server.
@MappableClass()
final class PostEditContentOption with PostEditContentOptionMappable {
  /// Constructor.
  const PostEditContentOption({
    required this.name,
    required this.value,
    required this.disabled,
    required this.checked,
    required this.readableName,
  });

  /// Attribute "name".
  ///
  /// This value is the name parameter in form.
  final String name;

  /// Attribute "value".
  ///
  /// When this checkbox meets all the following conditions:
  /// * Do not have [disabled] attribute.
  /// * Have [checked] attribute.
  ///
  /// This [value] will be added in form when submit to the server.
  final String value;

  /// Attribute "disabled".
  ///
  /// Html checkbox "disabled" attribute.
  ///
  /// Have this attribute (no matter has value or not) means the checkbox is
  /// disabled.
  final bool disabled;

  /// Attribute "checked".
  ///
  /// Have this attribute (no matter has value or not) means the checkbox is in
  /// checked state.
  ///
  /// When in checked state, the [value] will be added in form data when submit
  /// form to server.
  final bool checked;

  /// Human readable name inside <input> node.
  final String readableName;
}

/// Model of content when editing a post.
@MappableClass()
final class PostEditContent with PostEditContentMappable {
  /// Constructor.
  const PostEditContent({
    required this.threadType,
    required this.threadTypeList,
    required this.threadTitle,
    required this.threadTitleMaxLength,
    required this.formHash,
    required this.postTime,
    required this.delattachop,
    required this.wysiwyg,
    required this.fid,
    required this.tid,
    required this.pid,
    required this.page,
    required this.data,
    required this.options,
    required this.permList,
    required this.price,
  });

  /// Build a instance of [PostEditContent] from [document].
  ///
  /// Set [requireThreadInfo] to false if [document] is expected to have no
  /// info about current editing thread. e.g. Drafting a new thread where those
  /// info are not generated until we post the thread to server.
  static PostEditContent? fromDocument(
    uh.Document document, {
    bool requireThreadInfo = true,
  }) {
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
    final wysiwyg =
        rootNode?.querySelector('input[name="wysiwyg"]')?.attributes['value'];

    final delattachop = rootNode
        ?.querySelector('input[name="delattachop"]')
        ?.attributes['value'];
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

    if (formHash == null ||
        postTime == null ||
        wysiwyg == null ||
        (requireThreadInfo &&
            // Only check these thread info when `requireThreadInfo` is true.
            (delattachop == null ||
                fid == null ||
                tid == null ||
                pid == null ||
                page == null)) ||
        data == null) {
      talker.error('invalid post edit form data: '
          'formhash=$formHash, posttime=$postTime, '
          'delattachop=$delattachop, wysiwyg=$wysiwyg, '
          'fid=$fid, tid=$tid, pid=$pid, page=$page, data=$data');
      return null;
    }

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

    final permListNode = rootNode?.querySelector('select#readperm');
    List<ThreadPerm>? permList;
    if (permListNode != null) {
      permList = ThreadPerm.buildListFromSelect(permListNode);
    }

    // A `div class="extra_price_c"` is the row to set price on current thread
    // if current post is an thread (the 1st floor).
    final int? price;
    final priceNode = rootNode?.querySelector('div#extra_price_c > input');
    if (priceNode != null) {
      // Price node exists means user can definitely set a price.
      // the "value" attr may not have an value if is in an entire new thread.
      price = priceNode.attributes['value']?.parseToInt() ?? 0;
    } else {
      price = null;
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
      permList: permList,
      price: price,
    );
  }

  /// Thread type.
  ///
  /// Only not null when editing a thread (post on the first floor).
  final PostEditThreadType? threadType;

  /// All available thread types.
  ///
  /// Only not null when editing a thread (post on the first floor).
  final List<PostEditThreadType>? threadTypeList;

  /// Max title length (bytes in utf8).
  ///
  /// Title length is limited by the server side and this value is a common used
  /// value. We parse the max length from page.
  final int? threadTitleMaxLength;

  /// Thread title
  ///
  /// Only not null (and also not empty) when editing a
  /// thread (post on the first floor).
  final String? threadTitle;

  /// Response parameter.
  final String formHash;

  /// Response parameter,
  final String postTime;

  /// Response parameter.
  ///
  /// Do not know what it means but just copy it!
  final String? delattachop;

  /// Response parameter.
  final String wysiwyg;

  /// Response parameter: forum id.
  ///
  /// Sometimes null, e.g. drafting new thread.
  final String? fid;

  /// Response parameter: thread id.
  ///
  /// Sometimes null, e.g. drafting new thread.
  final String? tid;

  /// Response parameter: post id.
  ///
  /// Sometimes null, e.g. drafting new thread.
  final String? pid;

  /// Response parameter: page number.
  ///
  /// Sometimes null, e.g. drafting new thread.
  final String? page;

  /// Post data.
  final String data;

  /// List of options can use when posting.
  ///
  /// Each represents a `<input>` node in web page.
  ///
  /// Allow null values.
  final List<PostEditContentOption>? options;

  /// All available perms to select, require to access this thread.
  ///
  /// Only used in editing thread.
  final List<ThreadPerm>? permList;

  /// Whether can set price in this edit.
  ///
  /// Only post in the first floor (exactly is a thread, not a post) can set
  /// price, this field indicates can do that or not.
  ///
  /// A null value indicates this post is unable to set a price.
  ///
  /// A 0 value will be here if it can but not set yet.
  final int? price;
}
