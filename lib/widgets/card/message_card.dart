import 'package:flutter/material.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/extensions/date_time.dart';
import 'package:tsdm_client/features/notification/models/models.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/widgets/cached_image/cached_image_provider.dart';
import 'package:tsdm_client/widgets/single_line_text.dart';

/// Widget to show a single [PersonalMessage].
final class PrivateMessageCard extends StatelessWidget {
  /// Constructor.
  const PrivateMessageCard({required this.message, super.key});

  /// Message.
  final PersonalMessage message;

  @override
  Widget build(BuildContext context) {
    final tr = context.t.noticePage.privateMessageTab;
    late final CircleAvatar userAvatar;
    if (message.user.avatarUrl != null) {
      userAvatar = CircleAvatar(
        backgroundImage: CachedImageProvider(
          message.user.avatarUrl!,
          context,
          fallbackImageUrl: noAvatarUrl,
        ),
      );
    } else {
      userAvatar = CircleAvatar(child: Text(message.user.name[0]));
    }

    final userUrl = message.user.url;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async => context.dispatchAsUrl(message.chatUrl),
        child: Column(
          children: [
            ListTile(
              leading: GestureDetector(
                onTap: () async => context.dispatchAsUrl(userUrl),
                child: userAvatar,
              ),
              title: Row(
                children: [
                  GestureDetector(
                    onTap: () async => context.dispatchAsUrl(userUrl),
                    child: SingleLineText(message.user.name),
                  ),
                  Expanded(child: Container()),
                ],
              ),
              trailing: message.count != null
                  ? Text(tr.messageCount(count: message.count!))
                  : null,
              subtitle: Text(message.lastMessageTime.yyyyMMDD()),
            ),
            sizedBoxW5H5,
            Padding(
              padding: edgeInsetsL15R15B10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(children: [Expanded(child: Text(message.message))]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget to show a single [BroadcastMessage].
final class BroadcastMessageCard extends StatelessWidget {
  /// Constructor.
  const BroadcastMessageCard({required this.message, super.key});

  /// Message.
  final BroadcastMessage message;

  @override
  Widget build(BuildContext context) {
    final tr = context.t.noticePage.broadcastMessageTab;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: message.redirectUrl != null
            ? () async => context.dispatchAsUrl(message.redirectUrl!)
            : null,
        child: Column(
          children: [
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.campaign_outlined)),
              title: SingleLineText(tr.system),
              subtitle: Text(message.messageTime.yyyyMMDD()),
            ),
            sizedBoxW5H5,
            Padding(
              padding: edgeInsetsL15R15B10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(children: [Expanded(child: Text(message.message))]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
