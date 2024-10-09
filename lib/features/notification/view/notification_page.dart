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

  Widget _buildEmptyBody() {
    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.sizeOf(context).width,
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
    );
  }

  Widget _buildNoticeTab(BuildContext context, NoticeState state) {
    return switch (state.status) {
      NotificationStatus.initial ||
      NotificationStatus.loading =>
        const Center(child: CircularProgressIndicator()),
      NotificationStatus.success => (BuildContext context, NoticeState state) {
          final Widget content;
          if (state.noticeList.isEmpty) {
            content = _buildEmptyBody();
          } else {
            content = ListView.separated(
              padding: edgeInsetsL12T4R12B24,
              itemCount: state.noticeList.length,
              itemBuilder: (_, index) =>
                  NoticeCard(notice: state.noticeList[index]),
              separatorBuilder: (_, __) => sizedBoxW4H4,
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
            onLoad: () async {
              if (!mounted) {
                return;
              }
              if (!state.hasNextPage) {
                _broadcastMessageRefreshController.finishLoad(
                  IndicatorResult.noMore,
                );
                return;
              }
              context.read<NoticeBloc>().add(NotificationLoadMoreRequested());
            },
            onRefresh: () async {
              if (!mounted) {
                return;
              }
              context.read<NoticeBloc>().add(NotificationRefreshRequested());
            },
            child: content,
          );
        }(context, state),
      NotificationStatus.failure => buildRetryButton(
          context,
          () => context.read<NoticeBloc>().add(NotificationRefreshRequested()),
        ),
    };
  }

  Widget _buildPersonalMessageTab(
    BuildContext context,
    PersonalMessageState state,
  ) {
    return switch (state.status) {
      NotificationStatus.initial ||
      NotificationStatus.loading =>
        const Center(child: CircularProgressIndicator()),
      NotificationStatus.success =>
        (BuildContext context, PersonalMessageState state) {
          final Widget content;
          if (state.noticeList.isEmpty) {
            content = _buildEmptyBody();
          } else {
            content = ListView.separated(
              padding: edgeInsetsL12T4R12B24,
              itemCount: state.noticeList.length,
              itemBuilder: (context, index) =>
                  PrivateMessageCard(message: state.noticeList[index]),
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
            onLoad: () async {
              if (!mounted) {
                return;
              }
              if (!state.hasNextPage) {
                context
                    .read<PersonalMessageBloc>()
                    .add(NotificationLoadMoreRequested());
                return;
              }
              context
                  .read<PersonalMessageBloc>()
                  .add(NotificationRefreshRequested());
            },
            onRefresh: () async {
              if (!mounted) {
                return;
              }
              context
                  .read<PersonalMessageBloc>()
                  .add(NotificationRefreshRequested());
            },
            child: content,
          );
        }(context, state),
      NotificationStatus.failure => buildRetryButton(
          context,
          () => context
              .read<PersonalMessageBloc>()
              .add(NotificationRefreshRequested()),
        ),
    };
  }

  Widget _buildBroadcastMessageTab(
    BuildContext context,
    BroadcastMessageState state,
  ) {
    return switch (state.status) {
      NotificationStatus.initial ||
      NotificationStatus.loading =>
        const Center(child: CircularProgressIndicator()),
      NotificationStatus.success =>
        (BuildContext context, BroadcastMessageState state) {
          final Widget content;
          if (state.noticeList.isEmpty) {
            content = _buildEmptyBody();
          } else {
            content = ListView.separated(
              padding: edgeInsetsL12T4R12B24,
              itemCount: state.noticeList.length,
              itemBuilder: (context, index) {
                return BroadcastMessageCard(
                  message: state.noticeList[index],
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
            onLoad: () async {
              if (!mounted) {
                return;
              }
              if (!state.hasNextPage) {
                _broadcastMessageRefreshController.finishLoad(
                  IndicatorResult.noMore,
                );
                return;
              }
              context
                  .read<BroadcastMessageBloc>()
                  .add(NotificationLoadMoreRequested());
            },
            onRefresh: () async {
              if (!mounted) {
                return;
              }
              context
                  .read<BroadcastMessageBloc>()
                  .add(NotificationRefreshRequested());
            },
            child: content,
          );
        }(context, state),
      NotificationStatus.failure => buildRetryButton(
          context,
          () => context
              .read<BroadcastMessageBloc>()
              .add(NotificationRefreshRequested()),
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
    _tabController.dispose();
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
          create: (context) => NoticeBloc(
            notificationRepository: RepositoryProvider.of(context),
          )..add(NotificationRefreshRequested()),
        ),
        BlocProvider(
          create: (context) => PersonalMessageBloc(
            notificationRepository: RepositoryProvider.of(context),
          )..add(NotificationRefreshRequested()),
        ),
        BlocProvider(
          create: (context) => BroadcastMessageBloc(
            notificationRepository: RepositoryProvider.of(context),
          )..add(NotificationRefreshRequested()),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<NoticeBloc, NoticeState>(
            listener: (context, state) {
              if (state.status == NotificationStatus.failure) {
                showFailedToLoadSnackBar(context);
              }
            },
          ),
          BlocListener<PersonalMessageBloc, PersonalMessageState>(
            listener: (context, state) {
              if (state.status == NotificationStatus.failure) {
                showFailedToLoadSnackBar(context);
              }
            },
          ),
          BlocListener<BroadcastMessageBloc, BroadcastMessageState>(
            listener: (context, state) {
              if (state.status == NotificationStatus.failure) {
                showFailedToLoadSnackBar(context);
              }
            },
          ),
        ],
        child: Builder(
          builder: (context) {
            final noticeState = context.watch<NoticeBloc>().state;
            final personalMessageState =
                context.watch<PersonalMessageBloc>().state;
            final broadcastMessageState =
                context.watch<BroadcastMessageBloc>().state;

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
                  _buildNoticeTab(context, noticeState),
                  _buildPersonalMessageTab(context, personalMessageState),
                  _buildBroadcastMessageTab(context, broadcastMessageState),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
