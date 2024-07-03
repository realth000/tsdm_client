import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/features/authentication/repository/authentication_repository.dart';
import 'package:tsdm_client/features/home/cubit/home_cubit.dart';
import 'package:tsdm_client/features/homepage/bloc/homepage_bloc.dart';
import 'package:tsdm_client/features/homepage/widgets/widgets.dart';
import 'package:tsdm_client/features/need_login/view/need_login_page.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/shared/repositories/forum_home_repository/forum_home_repository.dart';
import 'package:tsdm_client/shared/repositories/profile_repository/profile_repository.dart';
import 'package:tsdm_client/utils/retry_button.dart';
import 'package:tsdm_client/utils/show_toast.dart';
import 'package:tsdm_client/widgets/loading_shimmer.dart';

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
  bool _fabVisible = true;

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
      child: BlocListener<HomeCubit, HomeState>(
        listener: (context, state) {
          if (state.inHome ?? false) {
            context.read<HomepageBloc>().add(const HomepageResumeSwiper());
          } else if (state.inHome == false) {
            context.read<HomepageBloc>().add(const HomepagePauseSwiper());
          }
        },
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
                  child: const LoadingShimmer(child: HomepagePlaceholder()),
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
              HomepageStatus.success => EasyRefresh(
                  key: const ValueKey('success'),
                  scrollController: _scrollController,
                  controller: _refreshController,
                  header: const MaterialHeader(),
                  onRefresh: () {
                    context
                        .read<HomepageBloc>()
                        .add(HomepageRefreshRequested());
                  },
                  child: ListView(
                    controller: _scrollController,
                    padding: edgeInsetsL10T5R10B20,
                    children: [
                      WelcomeSection(
                        forumStatus: state.forumStatus,
                        loggedUserInfo: state.loggedUserInfo,
                        swiperUrlList: state.swiperUrlList,
                      ),
                      sizedBoxW5H5,
                      PinSection(state.pinnedThreadGroupList),
                    ],
                  ),
                ),
            };

            _refreshController.finishRefresh();

            return Scaffold(
              appBar: AppBar(
                title: Text(context.t.homepage.title),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search_outlined),
                    onPressed: () async {
                      await context.pushNamed(ScreenPaths.search);
                    },
                  ),
                ],
              ),
              body: NotificationListener<UserScrollNotification>(
                onNotification: (notification) {
                  if (notification.direction == ScrollDirection.forward &&
                      !_fabVisible) {
                    setState(() {
                      _fabVisible = true;
                    });
                  } else if (notification.direction ==
                          ScrollDirection.reverse &&
                      _fabVisible) {
                    setState(() {
                      _fabVisible = false;
                    });
                  }
                  return true;
                },
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
