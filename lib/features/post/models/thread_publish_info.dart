part of 'models.dart';

/// Model of info then posting thread data to server.
///
/// Maybe used in publishing a new thread or create/edit drafts.
///
/// Many of the options are shared with post editing.
/// But the action is "newthread" with unknown tid/pid.
@MappableClass()
final class ThreadPublishInfo with ThreadPublishInfoMappable {
  /// Constructor.
  const ThreadPublishInfo({
    required this.formHash,
    required this.postTime,
    required this.delAttachOp,
    required this.wysiwyg,
    required this.fid,
    required this.threadType,
    required this.checkbox,
    required this.subject,
    required this.message,
    required this.price,
    required this.perm,
    required this.save,
    required this.options,
  });

  /// Build to json format payload which can be used in publishing new thread.
  Map<String, String> toPostPayload() {
    final body = <String, String>{
      'formhash': formHash,
      'posttime': postTime,
      'wysiwyg': wysiwyg,
      'checkbox': '0',
      'subject': subject,
      'message': message,
      'save': save,
      'mastertid': '',
      'price': '${price ?? ""}',
    };
    for (final entry in options) {
      body[entry.name] = entry.checked ? '1' : '';
    }
    if (perm != null) {
      body['readperm'] = perm!;
    }
    final typeId = threadType?.typeID;
    if (typeId != null) {
      body['typeid'] = typeId;
    }

    return body;
  }

  /// Form hash used in action
  final String formHash;

  /// Timestamp when post info.
  final String postTime;

  /// Some info, always empty.
  ///
  /// "0"
  ///
  /// Seems is the operation on deleting thread attachment.
  final String delAttachOp;

  /// WYSIWYG, always zero.
  ///
  /// "0".
  final String wysiwyg;

  /// Forum id to post thread in.
  ///
  /// Fid saved in query parameter with "topicsubmit".
  final String fid;

  /// Thread type id.
  ///
  /// Provided by server, selected by user.
  final PostEditThreadType? threadType;

  /// Checkbox?
  ///
  /// Always "0"
  final String checkbox;

  /// Subject of thread.
  final String subject;

  /// Thread body.
  final String message;

  /// Sell price used in post.
  final int? price;

  /// Least permission to read this thread.
  final String? perm;

  /// Save to draft or not.
  ///
  /// * Draft if 0.
  /// * Publish if 1.
  final String save;

  /// Options.
  final List<PostEditContentOption> options;
}
