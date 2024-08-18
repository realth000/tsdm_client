import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/features/notification/bloc/notification_bloc.dart';
import 'package:tsdm_client/features/notification/repository/notification_repository.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/utils/retry_button.dart';
import 'package:tsdm_client/utils/show_toast.dart';
import 'package:tsdm_client/widgets/card/message_card.dart';
import 'package:tsdm_client/widgets/card/notice_card.dart';

/// Notice page, shows Notice and PrivateMessage of current user.
class NotificationPage extends StatefulWidget {
  /// Constructor.
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage>
    with SingleTickerProviderStateMixin {
  late final EasyRefreshController _noticeRefreshController;
  late final EasyRefreshController _personalMessageRefreshController;
  late final EasyRefreshController _broadcastMessageRefreshController;
  late final TabController _tabController;

  Widget _buildEmptyBody(BuildContext context) {
    return Row(
      children: [
        LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width,
                minHeight: constraints.maxHeight,
              ),
              child: Center(
                child: Text(
                  context.t.general.noData,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoticeTab(BuildContext context, NotificationState state) {
    return switch (state.noticeStatus) {
      NotificationStatus.initial ||
      NotificationStatus.loading =>
        const Center(child: CircularProgressIndicator()),
      NotificationStatus.success =>
        (BuildContext context, NotificationState state) {
          final Widget content;
          if (state.noticeList.isEmpty) {
            content = _buildEmptyBody(context);
          } else {
            content = ListView.separated(
              padding: edgeInsetsL12T4R12B24,
              itemCount: state.noticeList.length,
              itemBuilder: (context, index) {
                return NoticeCard(notice: state.noticeList[index]);
              },
              separatorBuilder: (context, index) => sizedBoxW4H4,
            );
          }

          return EasyRefresh(
            scrollBehaviorBuilder: (physics) {
              // Should use ERScrollBehavior instead of
              // ScrollConfiguration.of(context)
              return ERScrollBehavior(physics)
                  .copyWith(physics: physics, scrollbars: false);
            },
            header: const MaterialHeader(),
            controller: _noticeRefreshController,
            onRefresh: () async {
              if (!mounted) {
                return;
              }
              context
                  .read<NotificationBloc>()
                  .add(NotificationRefreshNoticeRequired());
            },
            child: content,
          );
        }(context, state),
      NotificationStatus.failed => buildRetryButton(
          context,
          () => context
              .read<NotificationBloc>()
              .add(NotificationRefreshNoticeRequired()),
        ),
    };
  }

  Widget _buildPrivateMessageTab(
    BuildContext context,
    NotificationState state,
  ) {
    return switch (state.personalMessageStatus) {
      NotificationStatus.initial ||
      NotificationStatus.loading =>
        const Center(child: CircularProgressIndicator()),
      NotificationStatus.success =>
        (BuildContext context, NotificationState state) {
          final Widget content;
          if (state.personalMessageList.isEmpty) {
            content = _buildEmptyBody(context);
          } else {
            content = ListView.separated(
              padding: edgeInsetsL12T4R12B24,
              itemCount: state.personalMessageList.length,
              itemBuilder: (context, index) =>
                  PrivateMessageCard(message: state.personalMessageList[index]),
              separatorBuilder: (context, index) => sizedBoxW4H4,
            );
          }

          return EasyRefresh(
            scrollBehaviorBuilder: (physics) {
              // Should use ERScrollBehavior instead of
              // ScrollConfiguration.of(context)
              return ERScrollBehavior(physics)
                  .copyWith(physics: physics, scrollbars: false);
            },
            header: const MaterialHeader(),
            controller: _personalMessageRefreshController,
            onRefresh: () async {
              if (!mounted) {
                return;
              }
              context
                  .read<NotificationBloc>()
                  .add(NotificationRefreshPersonalMessageRequired());
            },
            child: content,
          );
        }(context, state),
      NotificationStatus.failed => buildRetryButton(
          context,
          () => context
              .read<NotificationBloc>()
              .add(NotificationRefreshPersonalMessageRequired()),
        ),
    };
  }

  Widget _buildBroadcastMessageTab(
    BuildContext context,
    NotificationState state,
  ) {
    return switch (state.broadcastMessageStatus) {
      NotificationStatus.initial ||
      NotificationStatus.loading =>
        const Center(child: CircularProgressIndicator()),
      NotificationStatus.success =>
        (BuildContext context, NotificationState state) {
          final Widget content;
          if (state.broadcastMessageList.isEmpty) {
            content = _buildEmptyBody(context);
          } else {
            content = ListView.separated(
              padding: edgeInsetsL12T4R12B24,
              itemCount: state.broadcastMessageList.length,
              itemBuilder: (context, index) {
                return BroadcastMessageCard(
                  message: state.broadcastMessageList[index],
                );
              },
              separatorBuilder: (context, index) => sizedBoxW4H4,
            );
          }

          return EasyRefresh(
            scrollBehaviorBuilder: (physics) {
              // Should use ERScrollBehavior instead of
              // ScrollConfiguration.of(context)
              return ERScrollBehavior(physics)
                  .copyWith(physics: physics, scrollbars: false);
            },
            header: const MaterialHeader(),
            controller: _broadcastMessageRefreshController,
            onRefresh: () async {
              if (!mounted) {
                return;
              }
              context
                  .read<NotificationBloc>()
                  .add(NotificationRefreshBroadcastMessageRequired());
            },
            child: content,
          );
        }(context, state),
      NotificationStatus.failed => buildRetryButton(
          context,
          () => context
              .read<NotificationBloc>()
              .add(NotificationRefreshBroadcastMessageRequired()),
        ),
    };
  }

  @override
  void initState() {
    super.initState();
    _noticeRefreshController = EasyRefreshController(
      controlFinishLoad: true,
      controlFinishRefresh: true,
    );
    _personalMessageRefreshController = EasyRefreshController(
      controlFinishLoad: true,
      controlFinishRefresh: true,
    );
    _broadcastMessageRefreshController = EasyRefreshController(
      controlFinishLoad: true,
      controlFinishRefresh: true,
    );
    _tabController = TabController(vsync: this, length: 3);
  }

  @override
  void dispose() {
    _noticeRefreshController.dispose();
    _personalMessageRefreshController.dispose();
    _broadcastMessageRefreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.t.noticePage;
    return MultiBlocProvider(
      providers: [
        RepositoryProvider(
          create: (_) => NotificationRepository(),
        ),
        BlocProvider(
          create: (context) => NotificationBloc(
            notificationRepository: RepositoryProvider.of(context),
          )
            ..add(NotificationRefreshNoticeRequired())
            ..add(NotificationRefreshPersonalMessageRequired())
            ..add(NotificationRefreshBroadcastMessageRequired()),
        ),
      ],
      child: BlocListener<NotificationBloc, NotificationState>(
        listener: (context, state) {
          if (state.noticeStatus == NotificationStatus.failed) {
            showFailedToLoadSnackBar(context);
          }
        },
        child: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                title: Text(tr.title),
                bottom: TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(child: Text(tr.noticeTab.title)),
                    Tab(child: Text(tr.privateMessageTab.title)),
                    Tab(child: Text(tr.broadcastMessageTab.title)),
                  ],
                ),
              ),
              body: TabBarView(
                controller: _tabController,
                children: [
                  _buildNoticeTab(context, state),
                  _buildPrivateMessageTab(context, state),
                  _buildBroadcastMessageTab(context, state),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
