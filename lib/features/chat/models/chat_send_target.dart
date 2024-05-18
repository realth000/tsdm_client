part of 'models.dart';

/// Parameters used when sending a new chat to the serer in chat page (dialog).
///
/// All these data are originally used in chat dialog on server.
@MappableClass()
final class ChatSendTarget with ChatSendTargetMappable {
  /// Constructor.
  const ChatSendTarget({
    required this.pmsubmit,
    required this.touid,
    required this.formHash,
    required this.handleKey,
    required this.messageAppend,
  });

  /// Part of form data.
  ///
  /// Should be "true" or "false', always is true.
  final String pmsubmit;

  /// Part of form data.
  ///
  /// Should be an integer.
  final String touid;

  /// Part of form data.
  final String formHash;

  /// Part of form data.
  ///
  /// Always be "showMsgBox".
  final String handleKey;

  /// Part of form data.
  ///
  /// Always be an empty string.
  final String messageAppend;
}
