import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/features/notification/bloc/notification_bloc.dart';
import 'package:tsdm_client/features/notification/repository/notification_repository.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/utils/retry_button.dart';
import 'package:tsdm_client/widgets/card/notice_card.dart';

/// Notice page, shows Notice and PrivateMessage of current user.
class NotificationPage extends StatefulWidget {
  /// Constructor.
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final _refreshController = EasyRefreshController(
    controlFinishRefresh: true,
  );

  Widget _buildBody(BuildContext context, NotificationState state) {
    return EasyRefresh(
      scrollBehaviorBuilder: (physics) {
        // Should use ERScrollBehavior instead of
        // ScrollConfiguration.of(context)
        return ERScrollBehavior(physics)
            .copyWith(physics: physics, scrollbars: false);
      },
      header: const MaterialHeader(),
      controller: _refreshController,
      onRefresh: () async {
        if (!mounted) {
          return;
        }
        context
            .read<NotificationBloc>()
            .add(NotificationRefreshNoticeRequired());
      },
      child: ListView.separated(
        padding: edgeInsetsL10T5R10B20,
        itemCount: state.noticeList.length,
        itemBuilder: (context, index) {
          return NoticeCard(notice: state.noticeList[index]);
        },
        separatorBuilder: (context, index) => sizedBoxW5H5,
      ),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        RepositoryProvider(
          create: (_) => NotificationRepository(),
        ),
        BlocProvider(
          create: (context) => NotificationBloc(
            notificationRepository: RepositoryProvider.of(context),
          )..add(NotificationRefreshNoticeRequired()),
        ),
      ],
      child: BlocListener<NotificationBloc, NotificationState>(
        listener: (context, state) {
          if (state.status == NotificationStatus.failed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.t.general.failedToLoad)),
            );
          }
        },
        child: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            final body = switch (state.status) {
              NotificationStatus.initial ||
              NotificationStatus.loading =>
                const Center(child: CircularProgressIndicator()),
              NotificationStatus.success => _buildBody(context, state),
              NotificationStatus.failed => buildRetryButton(context, () {
                  context
                      .read<NotificationBloc>()
                      .add(NotificationRefreshNoticeRequired());
                }),
            };

            return Scaffold(
              appBar: AppBar(
                title: Text(context.t.noticePage.title),
              ),
              body: body,
            );
          },
        ),
      ),
    );
  }
}
