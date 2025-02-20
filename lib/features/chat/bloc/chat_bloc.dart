import 'dart:async';

import 'package:collection/collection.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tsdm_client/features/chat/models/models.dart';
import 'package:tsdm_client/features/chat/repository/chat_repository.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:universal_html/html.dart' as uh;

part 'chat_bloc.mapper.dart';
part 'chat_event.dart';
part 'chat_state.dart';

/// Emit
typedef _Emit = Emitter<ChatState>;

/// Bloc of chat.
///
/// This bloc is originally the login in chat dialog on server side.
///
/// Way to access this page:
/// see `formatChatUrl`.
final class ChatBloc extends Bloc<ChatEvent, ChatState> with LoggerMixin {
  /// Constructor.
  ChatBloc(this._chatRepository) : super(const ChatState()) {
    on<ChatFetchHistoryRequested>(_onChatFetchHistoryRequested);
  }

  final ChatRepository _chatRepository;

  FutureOr<void> _onChatFetchHistoryRequested(ChatFetchHistoryRequested event, _Emit emit) async {
    emit(state.copyWith(status: ChatStatus.loading));

    await await _chatRepository.fetchChat(event.uid).match((e) {
      handle(e);
      emit(state.copyWith(status: ChatStatus.failure));
    }, (v) async => _updateState(v, emit)).run();
  }

  void _updateState(uh.Document document, _Emit emit) {
    final titleText = document.querySelector('h3 > em')?.innerText.replaceFirst('正在与', '').split('聊天中');

    final username = titleText?.reversed.toList().slice(1).reversed.toList().join();
    final online = titleText?.elementAtOrNull(1)?.endsWith('[在线]');

    final chatHistoryUrl = document.querySelector('div.pm_tac.bbda.cl > a:nth-child(1)')?.attributes['href'];
    final userspaceUrl = document.querySelector('div.pm_tac.bbda.cl > a:nth-child(2)')?.attributes['href'];
    if (username == null || chatHistoryUrl == null || userspaceUrl == null) {
      error(
        'failed to build chat state: '
        'username=$username, userspaceUrl=$userspaceUrl, '
        'chatHistoryUrl=$chatHistoryUrl',
      );
      emit(state.copyWith(status: ChatStatus.failure));
      return;
    }

    // TODO: Parse and save message send date time.
    // Here we ignored message send time.
    final messagelist =
        document.querySelectorAll('ul#msglist > li').map(ChatMessage.fromLi).whereType<ChatMessage>().toList();

    final formNode = document.querySelector('div.pmfm > form');
    if (formNode == null) {
      error('failed to build chat state: form node not found');
      emit(state.copyWith(status: ChatStatus.failure));
      return;
    }
    final pmsubmit = formNode.querySelector('input[name="pmsubmit"]')?.attributes['value'];
    final touid = formNode.querySelector('input[name="touid"]')?.attributes['value'];
    final formHash = formNode.querySelector('input[name="formhash"]')?.attributes['value'];
    final handlekey = formNode.querySelector('input[name="handlekey"]')?.attributes['value'];
    final messageAppend = formNode.querySelector('div#messageappend')?.attributes['value'];
    // TODO: Parse and handle message refresh url.
    // Here we ignored message refresh url.

    if (touid == null || formHash == null) {
      error('failed to build chat state: touid=$touid formHash=$formHash');
      emit(state.copyWith(status: ChatStatus.failure));
      return;
    }

    // Some value will fallback to default value, it's ok.
    final chatSendTarget = ChatSendTarget(
      pmsubmit: pmsubmit ?? 'true',
      touid: touid,
      formHash: formHash,
      handleKey: handlekey ?? 'showMsgBox',
      messageAppend: messageAppend ?? '',
    );

    emit(
      state.copyWith(
        status: ChatStatus.success,
        username: username,
        online: online,
        uid: touid,
        chatHistoryUrl: chatHistoryUrl,
        spaceUrl: userspaceUrl,
        chatSendTarget: chatSendTarget,
        messageList: messagelist,
      ),
    );
  }
}
