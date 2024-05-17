part of 'models.dart';

/// Model of target and parameters to send a new message in chat history.
@MappableClass()
final class ChatHistorySendTarget with ChatHistorySendTargetMappable {
  /// Constructor.
  const ChatHistorySendTarget({
    required this.targetUrl,
    required this.pmid,
    required this.formHash,
  });

  /// Target url to send the POST request.
  final String targetUrl;

  /// Post message id of the upcoming message to send.
  final String pmid;

  /// Form hash value.
  final String formHash;
}
