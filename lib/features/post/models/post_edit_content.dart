import 'package:dart_mappable/dart_mappable.dart';

part '../../../generated/features/post/models/post_edit_content.mapper.dart';

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
    required this.readableName,
  });

  /// Attribute "name".
  final String name;

  /// Attribute "value".
  final String value;

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
  });

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
  final String delattachop;

  /// Response parameter.
  final String wysiwyg;

  /// Response parameter: forum id.
  final String fid;

  /// Response parameter: thread id.
  final String tid;

  /// Response parameter: post id.
  final String pid;

  /// Response parameter: page number.
  final String page;

  /// Post data.
  final String data;

  /// List of options can use when posting.
  ///
  /// Each represents a `<input>` node in web page.
  ///
  /// Allow null values.
  final List<PostEditContentOption>? options;
}
