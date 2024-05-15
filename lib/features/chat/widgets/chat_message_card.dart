import 'package:flutter/material.dart';
import 'package:tsdm_client/features/chat/models/models.dart';
import 'package:tsdm_client/packages/html_muncher/lib/html_muncher.dart';
import 'package:universal_html/parsing.dart';

/// Widget to show a chat message.
final class ChatMessageCard extends StatelessWidget {
  /// Constructor.
  const ChatMessageCard(this.chatMessage, {super.key});

  /// Message to display.
  final ChatMessage chatMessage;

  @override
  Widget build(BuildContext context) {
    return munchElement(context, parseHtmlDocument(chatMessage.message).body!);
  }
}
