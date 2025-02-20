import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/date_time.dart';
import 'package:tsdm_client/features/chat/models/models.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
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
            leading: GestureDetector(
              onTap:
                  chatMessage.author != null
                      ? () async =>
                          context.pushNamed(ScreenPaths.profile, queryParameters: {'username': chatMessage.author})
                      : null,
              child: HeroUserAvatar(
                username: chatMessage.author ?? '',
                avatarUrl: chatMessage.authorAvatarUrl,
                disableHero: true,
              ),
            ),
            title: GestureDetector(
              onTap:
                  chatMessage.author != null
                      ? () async =>
                          context.pushNamed(ScreenPaths.profile, queryParameters: {'username': chatMessage.author})
                      : null,
              child: Align(alignment: Alignment.centerLeft, child: Text(chatMessage.author ?? '')),
            ),
            subtitle: chatMessage.dateTime == null ? null : Text(chatMessage.dateTime!.yyyyMMDDHHMMSS()),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: edgeInsetsL16R16,
              child: munchElement(context, parseHtmlDocument(chatMessage.message).body!),
            ),
          ),
        ],
      ),
    );
  }
}
