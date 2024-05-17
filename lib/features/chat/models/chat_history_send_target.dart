part of 'models.dart';

/// Model of target and parameters to send a new message in chat history.
@MappableClass()
final class ChatHistorySendTarget with ChatHistorySendTargetMappable {
  /// Constructor.
  const ChatHistorySendTarget({
    required this.targetUrl,
    required this.formHash,
  });

  /// Target url to send the POST request.
  ///
  /// This url does NOT have a host.
  final String targetUrl;

  /// Form hash value.
  final String formHash;
}
