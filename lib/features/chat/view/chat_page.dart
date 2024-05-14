import 'package:flutter/material.dart';

/// Chat page shows a page to let user chat with another user.
///
/// This page is originally a message dialog (or call it message box) on the
/// server side. In that dialog, optional recent history and a reply area are
/// shown. Along side with some extra info
/// including:
///
/// 1. Name of user.
/// 2. User state: online or offline.
/// 3. User space url.
/// 4. Redirect url to show full chat history.
/// 5. Button to refresh recent chat history.
///
/// User above all refers to the user chatting with, not current logged user.
///
/// In our page, 3. and 4. is not needed because they are urls only require user
/// uid and we definitely know it when push to this page. And 5 is not needed
final class ChatPage extends StatefulWidget {
  /// Constructor.
  const ChatPage({required this.uid, super.key});

  /// User id to chat with.
  final String uid;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

final class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
