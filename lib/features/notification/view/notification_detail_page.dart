import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/constants.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/features/notification/bloc/notification_detail_cubit.dart';
import 'package:tsdm_client/features/notification/models/models.dart';
import 'package:tsdm_client/features/notification/repository/notification_repository.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:tsdm_client/utils/retry_button.dart';
import 'package:tsdm_client/utils/show_toast.dart';
import 'package:tsdm_client/widgets/card/post_card/post_card.dart';
import 'package:tsdm_client/widgets/reply_bar/bloc/reply_bloc.dart';
import 'package:tsdm_client/widgets/reply_bar/models/reply_types.dart';
import 'package:tsdm_client/widgets/reply_bar/reply_bar.dart';
import 'package:tsdm_client/widgets/reply_bar/repository/reply_repository.dart';

/// Show details for a single notice, also provides interaction:
/// * Reply to the notice if notice type is [NoticeType.reply]
/// or [NoticeType.mention].
class NoticeDetailPage extends StatefulWidget {
  /// Constructor.
  const NoticeDetailPage({
    required this.url,
    required this.noticeType,
    super.key,
  });

  /// [NoticeType] of current notice.
  ///
  /// Determines different UI layout.
  final NoticeType noticeType;

  /// Url to fetch the notice.
  final String url;

  @override
  State<NoticeDetailPage> createState() => _NoticeDetailPage();
}

class _NoticeDetailPage extends State<NoticeDetailPage> with LoggerMixin {
  final _replyBarController = ReplyBarController();

  String? _tid;
  String? _pid;
  String? _page;

  Widget _buildBody(BuildContext context, NotificationDetailState state) {
    _tid = state.tid;
    _pid = state.pid;
    _page = state.page;

    // Post can not be null because we only call this function when in
    // success state.
    final post = state.post!;
    if (widget.noticeType == NoticeType.rate) {
      return SingleChildScrollView(child: PostCard(post));
    }

    if (state.replyParameters != null) {
      _replyBarController.replyAction = post.replyAction;
      context
          .read<ReplyBloc>()
          .add(ReplyParametersUpdated(state.replyParameters));
    }

    return Column(
      children: [
        Expanded(child: SingleChildScrollView(child: PostCard(post))),
        // Always show reply bar even thread is locked to keep the same UI as
        // visiting locked thread.
        ReplyBar(
          controller: _replyBarController,
          // Set to [ReplyTypes.notice] to avoid clear reply parameters when
          // [ReplyBar] closed.
          replyType: ReplyTypes.notice,
          disabledEditorFeatures: defaultEditorDisabledFeatures,
          fullScreenDisabledEditorFeatures:
              defaultFullScreenDisabledEditorFeatures,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = switch (widget.noticeType) {
      NoticeType.reply => context.t.noticePage.noticeDetailPage.titleReply,
      NoticeType.rate => context.t.noticePage.noticeDetailPage.titleRate,
      NoticeType.mention => context.t.noticePage.noticeDetailPage.titleMention,
      NoticeType.invite ||
      NoticeType.newFriend ||
      NoticeType.batchRate =>
        '', // No detail page for invites, impossible.
    };
    return MultiBlocProvider(
      providers: [
        RepositoryProvider(
          create: (_) => NotificationRepository(),
        ),
        RepositoryProvider(
          create: (_) => const ReplyRepository(),
        ),
        BlocProvider(
          create: (context) => ReplyBloc(replyRepository: context.repo()),
        ),
        BlocProvider(
          create: (context) => NotificationDetailCubit(
            notificationRepository: context.repo(),
          )..fetchDetail(widget.url),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<NotificationDetailCubit, NotificationDetailState>(
            listener: (context, state) {
              if (state.status == NotificationDetailStatus.failed) {
                showFailedToLoadSnackBar(context);
              }
            },
          ),
          BlocListener<ReplyBloc, ReplyState>(
            // Drop only needClearText changed changes.
            listenWhen: (prev, curr) => prev.status != curr.status,
            listener: (context, state) {
              if (state.status == ReplyStatus.success) {
                showSnackBar(
                  context: context,
                  message: context.t.threadPage.replySuccess,
                );
              }
            },
          ),
        ],
        child: BlocBuilder<NotificationDetailCubit, NotificationDetailState>(
          builder: (context, state) {
            final body = switch (state.status) {
              NotificationDetailStatus.initial ||
              NotificationDetailStatus.loading =>
                const Center(child: CircularProgressIndicator()),
              NotificationDetailStatus.success => _buildBody(context, state),
              NotificationDetailStatus.failed => buildRetryButton(context, () {
                  context
                      .read<NotificationDetailCubit>()
                      .fetchDetail(widget.url);
                }),
            };

            // Update thread closed state to reply bar.
            if (state.threadClosed != context.read<ReplyBloc>().state.closed) {
              context
                  .read<ReplyBloc>()
                  .add(ReplyThreadClosed(closed: state.threadClosed));
            }

            return Scaffold(
              appBar: AppBar(
                title: Text(title),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.open_in_new_outlined),
                    onPressed: () async {
                      if (_tid == null || _page == null || _pid == null) {
                        return;
                      }
                      info('find post: tid:$_tid, page:$_page, pid:$_pid');
                      await context.pushNamed(
                        ScreenPaths.thread,
                        queryParameters: <String, String>{
                          'tid': _tid!,
                          'pageNumber': _page!,
                          'pid': _pid!,
                          // Set this value to false to reserve the original
                          // post order in thread so that we are heading to the
                          // correct page contains target post.
                          'overrideReverseOrder': 'false',
                        },
                      );
                    },
                  ),
                ],
              ),
              body: body,
            );
          },
        ),
      ),
    );
  }
}
