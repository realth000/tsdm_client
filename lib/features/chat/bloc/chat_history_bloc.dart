import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/features/authentication/repository/models/models.dart';
import 'package:tsdm_client/features/chat/models/models.dart';
import 'package:tsdm_client/features/chat/repository/chat_repository.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:universal_html/html.dart' as uh;

part '../../../generated/features/chat/bloc/chat_history_bloc.mapper.dart';
part 'chat_history_event.dart';
part 'chat_history_state.dart';

typedef _Emit = Emitter<ChatHistoryState>;

/// Bloc of chat history.
final class ChatHistoryBloc extends Bloc<ChatHistoryEvent, ChatHistoryState> {
  /// Constructor.
  ChatHistoryBloc(this._chatRepository) : super(const ChatHistoryState()) {
    on<ChatHistoryLoadHistoryRequested>(_onChatHistoryLoadHistoryRequested);
  }

  final ChatRepository _chatRepository;

  static final _re = RegExp(r'page=(?<page>\d+)');

  FutureOr<void> _onChatHistoryLoadHistoryRequested(
    ChatHistoryLoadHistoryRequested event,
    _Emit emit,
  ) async {
    emit(state.copyWith(status: ChatHistoryStatus.loading));
    try {
      final document = await _chatRepository.fetchChatHistory(
        event.uid,
        page: event.page,
      );
      await _updateState(document, emit, event.page);
    } on HttpRequestFailedException catch (e) {
      debug('failed to fetch chat history: $e');
      emit(state.copyWith(status: ChatHistoryStatus.failure));
    }
  }

  FutureOr<void> _updateState(
    uh.Document document,
    _Emit emit,
    int? page,
  ) async {
    final rootNode = document.querySelector('div.bm.bw0');
    if (rootNode == null) {
      debug('failed to build chat history: root node not found');
      emit(state.copyWith(status: ChatHistoryStatus.failure));
      return;
    }

    final emptyNode = rootNode.querySelector('div.emp');
    // Info node of the other user in chat.
    final userNode = rootNode.querySelector('div.tbmu.pml > div.xw1 > a');
    if (userNode == null) {
      debug('failed to build chat history: user node not found');
      emit(state.copyWith(status: ChatHistoryStatus.failure));
      return;
    }
    final username = userNode.innerText;
    // final userspaceUrl = userNode.attributes['href'];
    if (emptyNode != null) {
      // Empty chat history.
      emit(
        state.copyWith(
          status: ChatHistoryStatus.success,
          messageCount: 0,
          messages: [],
        ),
      );
      return;
    }
    final messageCount =
        rootNode.querySelector('span#membernum')?.innerText.parseToInt();
    if (messageCount == null) {
      debug('failed to build chat history: message count not found');
      emit(state.copyWith(status: ChatHistoryStatus.failure));
      return;
    }

    final previousPage = _re
        .firstMatch(
          rootNode.querySelector('div.pg > span.pgb > a')?.attributes['href'] ??
              '',
        )
        ?.namedGroup('page')
        ?.parseToInt();
    final nextPage = _re
        .firstMatch(
          rootNode.querySelector('div.pg > a.nxt')?.attributes['href'] ?? '',
        )
        ?.namedGroup('page')
        ?.parseToInt();

    final messages = rootNode
        .querySelectorAll('div#pm_ul > dl')
        .map(ChatMessage.fromDl)
        .whereType<ChatMessage>()
        .toList();

    emit(
      state.copyWith(
        status: ChatHistoryStatus.success,
        user: User(username: username),
        messageCount: messageCount,
        pageNumber: page,
        previousPage: previousPage,
        nextPage: nextPage,
        messages: messages,
      ),
    );
  }
}
