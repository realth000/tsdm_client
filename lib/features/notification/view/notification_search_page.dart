import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/list.dart';
import 'package:tsdm_client/features/notification/bloc/notification_bloc.dart';
import 'package:tsdm_client/features/notification/models/models.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/widgets/card/notice_card_v2.dart';

/// Gather all kinds of notifications.
final class _SavedNotifications {
  /// Constructor.
  const _SavedNotifications({
    required this.noticeList,
    required this.personalMessageList,
    required this.broadcastMessageList,
  });

  /// All saved notice.
  final List<NoticeV2> noticeList;

  /// All saved personal messages.
  final List<PersonalMessageV2> personalMessageList;

  /// All saved broadcast messages.
  final List<BroadcastMessageV2> broadcastMessageList;
}

/// Search and filter notifications.
class NotificationSearchPage extends StatefulWidget {
  /// Constructor.
  const NotificationSearchPage({super.key});

  @override
  State<NotificationSearchPage> createState() => _NotificationSearchPageState();
}

class _NotificationSearchPageState extends State<NotificationSearchPage> {
  _SavedNotifications? notice;

  var _searchContent = '';

  @override
  Widget build(BuildContext context) {
    if (notice == null) {
      final state = context.read<NotificationBloc>().state;
      notice = _SavedNotifications(
        noticeList: state.noticeList,
        personalMessageList: state.personalMessageList,
        broadcastMessageList: state.broadcastMessageList,
      );
    }

    final tr = context.t.noticeSearchPage;
    return Scaffold(
      appBar: AppBar(
        title: SearchBar(
          autoFocus: true,
          hintText: tr.title,
          onChanged: (str) {
            setState(() {
              _searchContent = str;
            });
          },
        ),
      ),
      body: ListView(
        padding: edgeInsetsL12T4R12B4,
        children: <Widget>[
          ...notice!.noticeList.where((e) => e.data.contains(_searchContent)).map(NoticeCardV2.new),
          ...notice!.personalMessageList.where((e) => e.data.contains(_searchContent)).map(PersonalMessageCardV2.new),
          ...notice!.broadcastMessageList.where((e) => e.data.contains(_searchContent)).map(BroadcastMessageCardV2.new),
        ].insertBetween(sizedBoxW4H4),
      ),
    );
  }
}
