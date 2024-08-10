import 'package:flutter/material.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/date_time.dart';
import 'package:tsdm_client/features/chat/models/models.dart';
import 'package:tsdm_client/utils/html/html_muncher.dart';
import 'package:tsdm_client/widgets/heroes.dart';
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
    return Padding(
      padding: edgeInsetsL8R8,
      child: Column(
        children: [
          ListTile(
            leading: HeroUserAvatar(
              username: chatMessage.author ?? '',
              avatarUrl: chatMessage.authorAvatarUrl,
              disableHero: true,
            ),
            title: Text(chatMessage.author ?? ''),
            subtitle: chatMessage.dateTime == null
                ? null
                : Text(chatMessage.dateTime!.yyyyMMDDHHMMSS()),
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: edgeInsetsL16R16,
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
