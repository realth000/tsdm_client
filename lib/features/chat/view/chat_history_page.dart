import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/features/chat/bloc/chat_history_bloc.dart';
import 'package:tsdm_client/features/chat/repository/chat_repository.dart';
import 'package:tsdm_client/features/chat/widgets/chat_message_card.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/utils/retry_button.dart';

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

  Widget _buildContent(BuildContext context, ChatHistoryState state) {
    final messages = state.messages;
    return EasyRefresh(
      scrollBehaviorBuilder: (physics) => ERScrollBehavior(physics)
          .copyWith(physics: physics, scrollbars: false),
      controller: _refreshController,
      scrollController: _scrollController,
      header: const MaterialHeader(),
      onRefresh: () async {
        if (!mounted) {
          return;
        }
        context.read<ChatHistoryBloc>().add(
              ChatHistoryLoadHistoryRequested(
                uid: widget.uid,
                page: state.pageNumber,
              ),
            );
      },
      child: ListView.separated(
        controller: _scrollController,
        padding: edgeInsetsL10T5R10B20,
        separatorBuilder: (context, index) => sizedBoxW5H5,
        itemCount: messages.length,
        itemBuilder: (context, index) => ChatMessageCard(messages[index]),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _refreshController = EasyRefreshController(
      controlFinishRefresh: true,
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
        BlocProvider(
          create: (context) => ChatHistoryBloc(RepositoryProvider.of(context))
            ..add(ChatHistoryLoadHistoryRequested(uid: widget.uid, page: null)),
        ),
      ],
      child: BlocBuilder<ChatHistoryBloc, ChatHistoryState>(
        builder: (context, state) {
          final body = switch (state.status) {
            ChatHistoryStatus.initial ||
            ChatHistoryStatus.loading =>
              const Center(child: CircularProgressIndicator()),
            ChatHistoryStatus.success => _buildContent(context, state),
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
          return Scaffold(
            appBar: AppBar(
              title: Text(tr.title),
            ),
            body: body,
          );
        },
      ),
    );
  }
}
