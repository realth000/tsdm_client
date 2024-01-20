import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/features/authentication/repository/authentication_repository.dart';
import 'package:tsdm_client/features/homepage/bloc/homepage_bloc.dart';
import 'package:tsdm_client/features/homepage/widgets/pin_section.dart';
import 'package:tsdm_client/features/homepage/widgets/welcome_section.dart';
import 'package:tsdm_client/features/need_login/view/need_login_page.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/shared/repositories/forum_home_repository/forum_home_repository.dart';
import 'package:tsdm_client/shared/repositories/profile_repository/profile_repository.dart';
import 'package:tsdm_client/utils/retry_button.dart';

/// Homepage page.
///
/// Be stateful because scrollable.
///
/// This page is in the Homepage of the app, already wrapped in a [Scaffold].
class HomepagePage extends StatefulWidget {
  const HomepagePage({super.key});

  @override
  State<HomepagePage> createState() => _HomepagePageState();
}

class _HomepagePageState extends State<HomepagePage> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
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
      child: BlocListener<HomepageBloc, HomepageState>(
        listener: (context, state) {
          if (state.status == HomepageStatus.failed) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.t.general.failedToLoad)));
          }
        },
        child: BlocBuilder<HomepageBloc, HomepageState>(
          builder: (context, state) {
            final body = switch (state.status) {
              HomepageStatus.initial ||
              HomepageStatus.loading =>
                const Center(child: CircularProgressIndicator()),
              HomepageStatus.needLogin => NeedLoginPage(
                  backUri: GoRouterState.of(context).uri,
                  needPop: true,
                  popCallback: (context) {
                    context
                        .read<HomepageBloc>()
                        .add(HomepageRefreshRequested());
                  },
                ),
              HomepageStatus.failed => buildRetryButton(context, () {
                  context.read<HomepageBloc>().add(HomepageRefreshRequested());
                }),
              HomepageStatus.success => SingleChildScrollView(
                  controller: _scrollController,
                  child: Padding(
                    padding: edgeInsetsL10T5R10B20,
                    child: Column(
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
                ),
            };
            return Scaffold(
              appBar: AppBar(
                title: Text(context.t.homepage.title),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search_outlined),
                    onPressed: () async {
                      await context.pushNamed(ScreenPaths.search);
                    },
                  )
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
