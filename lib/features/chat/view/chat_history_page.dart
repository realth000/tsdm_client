import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/features/chat/bloc/chat_history_bloc.dart';
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

/// Chat history page shows full chat history with another user [uid] and an
/// area to send new messages.
///
/// Full chat history is desc sorted and split 10 messages per page by server.
///
/// Note that an empty page with no message send area may return when the chat
/// history is empty. Usually this happened because user is redirected from chat
/// page that with a user never chatted before.
final class ChatHistoryPage extends StatefulWidget {
  /// Constructor.
  const ChatHistoryPage({required this.uid, super.key});

  /// User id to chat with.
  final String uid;

  @override
  State<ChatHistoryPage> createState() => _ChatHistoryPageState();
}

final class _ChatHistoryPageState extends State<ChatHistoryPage> {
  late final EasyRefreshController _refreshController;
  final _scrollController = ScrollController();
  final _replyBarController = ReplyBarController();

  Widget _buildContent(BuildContext context, ChatHistoryState state) {
    final messages = state.messages;
    final messageList = EasyRefresh(
      scrollBehaviorBuilder: (physics) => ERScrollBehavior(physics)
          .copyWith(physics: physics, scrollbars: false),
      controller: _refreshController,
      scrollController: _scrollController,
      footer: const MaterialFooter(),
      onLoad: () async {
        if (!mounted) {
          return;
        }
        // Try load
        if (state.previousPage == null) {
          _refreshController.finishLoad(IndicatorResult.noMore);
          showNoMoreSnackBar(context);
          return;
        }
        context.read<ChatHistoryBloc>().add(
              ChatHistoryLoadHistoryRequested(
                uid: widget.uid,
                page: state.previousPage,
              ),
            );
      },
      child: ListView.separated(
        // Reverse the list view and data received from server to let scroll
        // position keep the same after new pages of data.
        // See `messages` in `ChatHistoryState` for details.
        reverse: true,
        shrinkWrap: true,
        controller: _scrollController,
        separatorBuilder: (context, index) => const Divider(thickness: 0.5),
        itemCount: messages.length,
        itemBuilder: (context, index) => ChatMessageCard(messages[index]),
      ),
    );

    return Column(
      children: [
        Expanded(
          child: messageList,
        ),
        sizedBoxW12H12,
        ReplyBar(
          controller: _replyBarController,
          replyType: ReplyTypes.chatHistory,
          chatHistorySendTarget: state.sendTarget,
          disabledEditorFeatures: chatPagesDisabledFeatures,
          fullScreenDisabledEditorFeatures: chatPagesDisabledFeatures,
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _refreshController = EasyRefreshController(
      controlFinishLoad: true,
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.t.chatHistoryPage;
    return MultiBlocProvider(
      providers: [
        RepositoryProvider(
          create: (context) => const ChatRepository(),
        ),
        RepositoryProvider(
          create: (context) => const ReplyRepository(),
        ),
        BlocProvider(
          create: (context) =>
              ReplyBloc(replyRepository: RepositoryProvider.of(context)),
        ),
        BlocProvider(
          create: (context) => ChatHistoryBloc(RepositoryProvider.of(context))
            ..add(ChatHistoryLoadHistoryRequested(uid: widget.uid, page: null)),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<ChatHistoryBloc, ChatHistoryState>(
            listener: (context, state) {
              if (state.status == ChatHistoryStatus.success) {
                _refreshController.finishLoad();
              }
            },
          ),
          BlocListener<ReplyBloc, ReplyState>(
            listenWhen: (prev, curr) => prev.status != curr.status,
            listener: (context, state) {
              if (state.status == ReplyStatus.success) {
                showSnackBar(context: context, message: tr.success);
              } else if (state.status == ReplyStatus.failed &&
                  state.failedReason != null) {
                showSnackBar(
                  context: context,
                  message: tr.failed(message: state.failedReason!),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<ChatHistoryBloc, ChatHistoryState>(
          builder: (context, state) {
            final body = switch (state.status) {
              ChatHistoryStatus.initial ||
              ChatHistoryStatus.loading =>
                const Center(child: CircularProgressIndicator()),
              ChatHistoryStatus.success ||
              ChatHistoryStatus.loadingMore =>
                _buildContent(context, state),
              ChatHistoryStatus.failure => buildRetryButton(
                  context,
                  () => context.read<ChatHistoryBloc>().add(
                        ChatHistoryLoadHistoryRequested(
                          uid: widget.uid,
                          page: state.pageNumber,
                        ),
                      ),
                ),
            };

            PreferredSize? bottom;
            if ((state.user.username != null || state.user.uid != null) &&
                state.messageCount > 0) {
              bottom = PreferredSize(
                preferredSize:
                    const Size(kToolbarHeight / 2, kToolbarHeight / 2),
                child: Padding(
                  padding: edgeInsetsL12R12B12,
                  child: Row(
                    children: [
                      SingleLineText(
                        tr.info(
                          user: state.user.username ?? state.user.uid ?? '',
                          count: state.messageCount,
                        ),
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
              );
            }

            return Scaffold(
              appBar: AppBar(
                title: Text(tr.title),
                bottom: bottom,
              ),
              body: body,
            );
          },
        ),
      ),
    );
  }
}
