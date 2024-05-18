import 'package:flutter/material.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/extensions/date_time.dart';
import 'package:tsdm_client/features/chat/models/models.dart';
import 'package:tsdm_client/packages/html_muncher/lib/html_muncher.dart';
import 'package:tsdm_client/widgets/cached_image/cached_image_provider.dart';
import 'package:universal_html/parsing.dart';

/// Widget to show a chat message.
final class ChatMessageCard extends StatelessWidget {
  /// Constructor.
  const ChatMessageCard(this.chatMessage, {super.key});

  /// Avatar url for current message's author.
  // final String? authorAvatarUrl;

  /// Message to display.
  final ChatMessage chatMessage;

  @override
  Widget build(BuildContext context) {
    final CircleAvatar leading;
    if (chatMessage.authorAvatarUrl != null) {
      leading = CircleAvatar(
        backgroundImage: CachedImageProvider(
          chatMessage.authorAvatarUrl!,
          context,
          fallbackImageUrl: noAvatarUrl,
        ),
      );
    } else {
      leading = CircleAvatar(child: Text(chatMessage.author?[0] ?? ''));
    }

    return Padding(
      padding: edgeInsetsL10R10,
      child: Column(
        children: [
          ListTile(
            leading: leading,
            title: Text(chatMessage.author ?? ''),
            subtitle: chatMessage.dateTime == null
                ? null
                : Text(chatMessage.dateTime!.yyyyMMDDHHMMSS()),
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: edgeInsetsL15R15,
                  child: munchElement(
                    context,
                    parseHtmlDocument(chatMessage.message).body!,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
