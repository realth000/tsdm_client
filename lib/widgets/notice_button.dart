import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/features/authentication/repository/authentication_repository.dart';
import 'package:tsdm_client/features/notification/bloc/notification_bloc.dart';
import 'package:tsdm_client/features/notification/bloc/notification_state_cubit.dart';
import 'package:tsdm_client/features/settings/repositories/settings_repository.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/routes/screen_paths.dart';

/// Widget to show notice state and allow user goto the notification page.
///
/// Only available when user login.
class NoticeButton extends StatefulWidget {
  /// Constructor.
  const NoticeButton({super.key});

  @override
  State<NoticeButton> createState() => _NoticeButtonState();
}

class _NoticeButtonState extends State<NoticeButton> {
  static const iconData = Icon(Icons.notifications_outlined);

  @override
  Widget build(BuildContext context) {
    final noticeState = context.watch<NotificationBloc>().state;
    final isLogin = context.select<AuthenticationRepository, bool>(
      (repo) => repo.currentUser != null,
    );
    final showUnreadHint =
        getIt.get<SettingsRepository>().currentSettings.showUnreadInfoHint;
    final unreadNoticeCount = context
        .select<NotificationStateCubit, int>((cubit) => cubit.state.total);

    if (!isLogin) {
      return const IconButton(icon: iconData, onPressed: null);
    }

    final Widget noticeIcon;
    if (noticeState.status == NotificationStatus.initial ||
        noticeState.status == NotificationStatus.loading) {
      noticeIcon = sizedCircularProgressIndicator;
    } else if (showUnreadHint && unreadNoticeCount > 0) {
      noticeIcon = Badge(label: Text('$unreadNoticeCount'), child: iconData);
    } else {
      noticeIcon = iconData;
    }

    return IconButton(
      icon: noticeIcon,
      tooltip: context.t.noticePage.title,
      onPressed: () async => context.pushNamed(ScreenPaths.notice),
    );
  }
}
