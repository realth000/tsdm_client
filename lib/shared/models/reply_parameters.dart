part of 'models.dart';

/// Model contains parameters to make a reply to:
///
/// * Thread.
/// * Post.
@MappableClass()
class ReplyParameters with ReplyParametersMappable {
  /// Constructor.
  const ReplyParameters({
    required this.fid,
    required this.tid,
    required this.postTime,
    required this.formHash,
    required this.subject,
  });

  /// Forum id.
  final String fid;

  /// Thread id.
  final String tid;

  /// Post time.
  final String postTime;

  /// Form hash used in post request.
  final String formHash;

  /// Subject usually is an empty string.
  final String subject;
}
