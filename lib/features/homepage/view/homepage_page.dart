import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/features/authentication/repository/authentication_repository.dart';
import 'package:tsdm_client/features/checkin/widgets/checkin_button.dart';
import 'package:tsdm_client/features/home/cubit/home_cubit.dart';
import 'package:tsdm_client/features/homepage/bloc/homepage_bloc.dart';
import 'package:tsdm_client/features/homepage/widgets/user_operation_dialog.dart';
import 'package:tsdm_client/features/homepage/widgets/widgets.dart';
import 'package:tsdm_client/features/need_login/view/need_login_page.dart';
import 'package:tsdm_client/features/notification/bloc/notification_bloc.dart';
import 'package:tsdm_client/features/profile/repository/profile_repository.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/shared/repositories/forum_home_repository/forum_home_repository.dart';
import 'package:tsdm_client/utils/retry_button.dart';
import 'package:tsdm_client/utils/show_toast.dart';
import 'package:tsdm_client/widgets/heroes.dart';
import 'package:tsdm_client/widgets/notice_button.dart';

/// Show [FloatingActionButton] when offset is larger than this value.
const _showFabOffset = 100;

/// Homepage page.
///
/// Be stateful because scrollable.
///
/// This page is in the Homepage of the app, already wrapped in a [Scaffold].
class HomepagePage extends StatefulWidget {
  /// Constructor.
  const HomepagePage({super.key});

  @override
  State<HomepagePage> createState() => _HomepagePageState();
}

class _HomepagePageState extends State<HomepagePage> {
  final _scrollController = ScrollController();
  final _refreshController = EasyRefreshController(controlFinishRefresh: true);

  /// Flag the visibility of floating action button.
  ///
  /// Only set to true when scrolling up and offset is larger than
  /// [_showFabOffset].
  ///
  /// Set to false when offset is smaller than [_showFabOffset] or scrolling
  /// down.
  bool _fabVisible = false;

  bool _handleScrollNotification(UserScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) {
      return false;
    }

    // Update fab visibility according to scroll offset.
    if (notification.metrics.pixels <= _showFabOffset) {
      // Offset smaller than boundary.
      if (_fabVisible) {
        setState(() {
          _fabVisible = false;
        });
      }
      return true;
    }

    // Update fab visibility according to scroll direction.
    if (notification.direction == ScrollDirection.forward && !_fabVisible) {
      setState(() {
        _fabVisible = true;
      });
    } else if (notification.direction == ScrollDirection.reverse &&
        _fabVisible) {
      setState(() {
        _fabVisible = false;
      });
    }
    return true;
  }

  Widget? _buildFloatingActionButton(
    BuildContext context,
    HomepageState state,
  ) {
    if (state.status != HomepageStatus.success || !_fabVisible) {
      return null;
    }

    return FloatingActionButton(
      onPressed: () async => _scrollController.animateTo(
        0,
        duration: duration200,
        curve: Curves.easeInOut,
      ),
      child: const Icon(Icons.arrow_upward_outlined),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomepageBloc(
        authenticationRepository:
            RepositoryProvider.of<AuthenticationRepository>(context),
        forumHomeRepository:
            RepositoryProvider.of<ForumHomeRepository>(context),
        profileRepository: RepositoryProvider.of<ProfileRepository>(context),
      )..add(HomepageLoadRequested()),
      child: MultiBlocListener(
        listeners: [
          BlocListener<HomeCubit, HomeState>(
            listener: (context, state) {
              if (state.inHome ?? false) {
                context.read<HomepageBloc>().add(const HomepageResumeSwiper());
              } else if (state.inHome == false) {
                context.read<HomepageBloc>().add(const HomepagePauseSwiper());
              }
            },
          ),
          BlocListener<HomepageBloc, HomepageState>(
            listenWhen: (prev, curr) =>
                prev.status == HomepageStatus.loading &&
                curr.status == HomepageStatus.success,
            listener: (context, _) {
              // From loading state to success state, refresh notice.
              context
                  .read<NotificationBloc>()
                  .add(NotificationUpdateAllRequested());
            },
          ),
        ],
        child: BlocConsumer<HomepageBloc, HomepageState>(
          listener: (context, state) {
            if (state.status == HomepageStatus.failure) {
              showFailedToLoadSnackBar(context);
            }
          },
          builder: (context, state) {
            final body = switch (state.status) {
              HomepageStatus.initial || HomepageStatus.loading => EasyRefresh(
                  key: const ValueKey('loading'),
                  scrollController: _scrollController,
                  controller: _refreshController,
                  header: const MaterialHeader(),
                  onRefresh: () {
                    context
                        .read<HomepageBloc>()
                        .add(HomepageRefreshRequested());
                  },
                  child: const Center(child: CircularProgressIndicator()),
                ),
              HomepageStatus.needLogin => NeedLoginPage(
                  backUri: GoRouterState.of(context).uri,
                  needPop: true,
                  popCallback: (context) {
                    context
                        .read<HomepageBloc>()
                        .add(HomepageRefreshRequested());
                  },
                ),
              HomepageStatus.failure => buildRetryButton(context, () {
                  context.read<HomepageBloc>().add(HomepageRefreshRequested());
                }),
              HomepageStatus.success => EasyRefresh.builder(
                  key: const ValueKey('success'),
                  scrollController: _scrollController,
                  controller: _refreshController,
                  header: const MaterialHeader(),
                  onRefresh: () {
                    context
                        .read<HomepageBloc>()
                        .add(HomepageRefreshRequested());
                  },
                  childBuilder: (context, physics) => ListView(
                    physics: physics,
                    controller: _scrollController,
                    padding: edgeInsetsL12T4R12B4,
                    children: [
                      WelcomeSection(
                        forumStatus: state.forumStatus,
                        loggedUserInfo: state.loggedUserInfo,
                        swiperUrlList: state.swiperUrlList,
                      ),
                      sizedBoxW12H12,
                      PinSection(state.pinnedThreadGroupList),
                    ],
                  ),
                ),
            };

            _refreshController.finishRefresh();

            final username = state.loggedUserInfo?.username;
            final avatarUrl = state.loggedUserInfo?.avatarUrl;

            return Scaffold(
              appBar: AppBar(
                title: Text(context.t.homepage.title),
                actions: [
                  if (username != null) ...[
                    IconButton(
                      icon: SizedBox(
                        width: 32,
                        height: 32,
                        child: HeroUserAvatar(
                          username: username,
                          avatarUrl: avatarUrl,
                          heroTag: username,
                        ),
                      ),
                      onPressed: () async => showHeroDialog(
                        context,
                        (context, _, __) => UserOperationDialog(
                          username: username,
                          avatarUrl: avatarUrl,
                          heroTag: username,
                          // Ok to use record.
                          // ignore: avoid_positional_fields_in_records
                          latestThreadUrl: state.loggedUserInfo
                              ?.relatedLinkPairList.lastOrNull?.$2,
                        ),
                      ),
                    ),
                    const NoticeButton(),
                    const CheckinButton(enableSnackBar: true),
                  ],
                  IconButton(
                    icon: const Icon(Icons.search_outlined),
                    tooltip: context.t.searchPage.title,
                    onPressed: () async {
                      await context.pushNamed(ScreenPaths.search);
                    },
                  ),
                ],
              ),
              body: NotificationListener<UserScrollNotification>(
                onNotification: _handleScrollNotification,
                child: AnimatedSwitcher(duration: duration200, child: body),
              ),
              floatingActionButton: _buildFloatingActionButton(context, state),
            );
          },
        ),
      ),
    );
  }
}
