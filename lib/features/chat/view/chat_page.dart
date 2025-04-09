import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/features/chat/bloc/chat_bloc.dart';
import 'package:tsdm_client/features/chat/models/editor_features.dart';
import 'package:tsdm_client/features/chat/repository/chat_repository.dart';
import 'package:tsdm_client/features/chat/widgets/chat_message_card.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/utils/retry_button.dart';
import 'package:tsdm_client/utils/show_toast.dart';
import 'package:tsdm_client/widgets/reply_bar/bloc/reply_bloc.dart';
import 'package:tsdm_client/widgets/reply_bar/models/reply_types.dart';
import 'package:tsdm_client/widgets/reply_bar/reply_bar.dart';
import 'package:tsdm_client/widgets/reply_bar/repository/reply_repository.dart';
import 'package:tsdm_client/widgets/single_line_text.dart';

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
  const ChatPage({required this.username, required this.uid, super.key});

  /// Username of user chat with.
  ///
  /// May be null.
  final String? username;

  /// User id to chat with.
  final String uid;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

final class _ChatPageState extends State<ChatPage> {
  late final EasyRefreshController _refreshController;
  final _scrollController = ScrollController();
  final _replyBarController = ReplyBarController();

  Widget _buildContent(BuildContext context, ChatState state) {
    final messages = state.messageList;
    final messageList = EasyRefresh(
      scrollBehaviorBuilder: (physics) => ERScrollBehavior(physics).copyWith(physics: physics, scrollbars: false),
      controller: _refreshController,
      scrollController: _scrollController,
      header: const MaterialHeader(),
      onRefresh: () async {
        if (!mounted) {
          return;
        }
        context.read<ChatBloc>().add(ChatFetchHistoryRequested(state.uid));
      },
      child: ListView.separated(
        controller: _scrollController,
        separatorBuilder: (context, index) => const Divider(thickness: 0.5),
        itemCount: messages.length,
        itemBuilder: (context, index) => ChatMessageCard(messages[index]),
      ),
    );

    return Column(
      children: [
        Expanded(child: messageList),
        sizedBoxW12H12,
        ReplyBar(
          controller: _replyBarController,
          replyType: ReplyTypes.chat,
          chatSendTarget: state.chatSendTarget,
          disabledEditorFeatures: chatPagesDisabledFeatures,
          fullScreenDisabledEditorFeatures: chatPagesDisabledFeatures,
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _refreshController = EasyRefreshController(controlFinishLoad: true);
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.t.chatPage;
    return MultiBlocProvider(
      providers: [
        RepositoryProvider(create: (context) => const ChatRepository()),
        RepositoryProvider(create: (context) => const ReplyRepository()),
        BlocProvider(create: (context) => ReplyBloc(replyRepository: context.repo())),
        BlocProvider(create: (context) => ChatBloc(context.repo())..add(ChatFetchHistoryRequested(widget.uid))),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<ChatBloc, ChatState>(
            listener: (context, state) {
              if (state.status == ChatStatus.success) {
                _refreshController.finishLoad();
              }
            },
          ),
          BlocListener<ReplyBloc, ReplyState>(
            listenWhen: (prev, curr) => prev.status != curr.status,
            listener: (context, state) {
              if (state.status == ReplyStatus.success) {
                showSnackBar(context: context, message: tr.success);
                // Close the reply bar when sent success.
                if (_replyBarController.showingEditor) {
                  context.pop();
                }
              } else if (state.status == ReplyStatus.failure && state.failedReason != null) {
                showSnackBar(context: context, message: tr.failed(message: state.failedReason!));
              }
            },
          ),
        ],
        child: BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            final body = switch (state.status) {
              ChatStatus.initial || ChatStatus.loading => const Center(child: CircularProgressIndicator()),
              ChatStatus.success => _buildContent(context, state),
              ChatStatus.failure => buildRetryButton(
                context,
                () => context.read<ChatBloc>().add(ChatFetchHistoryRequested(widget.uid)),
              ),
            };

            return Scaffold(
              // Required by chat_bottom_container in reply bar.
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                title: Text(tr.title),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.contact_page_outlined),
                    onPressed: () async => context.dispatchAsUrl(state.spaceUrl),
                  ),
                  IconButton(
                    icon: const Icon(Icons.history_outlined),
                    onPressed: () async => context.dispatchAsUrl(state.chatHistoryUrl),
                  ),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size(kToolbarHeight / 2, kToolbarHeight / 2),
                  child: Padding(
                    padding: edgeInsetsL12R12B12,
                    child: Row(
                      children: [
                        SingleLineText(
                          '${tr.hint(user: widget.username ?? widget.uid)} '
                          '${state.online ? tr.online : tr.offline}',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              body: SafeArea(bottom: false, child: body),
            );
          },
        ),
      ),
    );
  }
}
