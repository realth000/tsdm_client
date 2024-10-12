import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/features/need_login/view/need_login_page.dart';
import 'package:tsdm_client/features/parse_url/widgets/parse_url_dialog.dart';
import 'package:tsdm_client/features/topics/bloc/topics_bloc.dart';
import 'package:tsdm_client/features/topics/widgets/topics_placeholder.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/shared/repositories/forum_home_repository/forum_home_repository.dart';
import 'package:tsdm_client/shared/repositories/fragments_repository/fragments_repository.dart';
import 'package:tsdm_client/utils/retry_button.dart';
import 'package:tsdm_client/utils/show_toast.dart';
import 'package:tsdm_client/widgets/card/forum_card.dart';
import 'package:tsdm_client/widgets/loading_shimmer.dart';

/// App topic page.
///
/// Contains most subreddits in homepage of server.
///
class TopicsPage extends StatefulWidget {
  /// Constructor.
  const TopicsPage({super.key});

  // /// Group of forums.
  // final List<ForumGroup> forumGroupList;

  @override
  State<TopicsPage> createState() => _TopicsPageState();
}

/// State of homepage.
class _TopicsPageState extends State<TopicsPage>
    with SingleTickerProviderStateMixin {
  /// Constructor.
  _TopicsPageState();

  TabController? tabController;

  VoidCallback? _updateIndexListener;

  final _refreshController = EasyRefreshController(controlFinishRefresh: true);

  Widget _buildContent(BuildContext context, TopicsState state) {
    final forumGroupList = state.forumGroupList;

    // Capture `context` and wrap in a void callback.
    _updateIndexListener ??= () {
      if (tabController == null) {
        return;
      }
      RepositoryProvider.of<FragmentsRepository>(context).topicsPageTabIndex =
          tabController!.index;
    };

    tabController ??= TabController(
      initialIndex: RepositoryProvider.of<FragmentsRepository>(context)
          .topicsPageTabIndex,
      length: forumGroupList.length,
      vsync: this,
    )..addListener(_updateIndexListener!);

    final groupTabBodyList = forumGroupList
        .map(
          (e) => ListView.separated(
            padding: edgeInsetsL12T4R12B24,
            itemCount: e.forumList.length,
            itemBuilder: (context, index) => ForumCard(e.forumList[index]),
            separatorBuilder: (context, index) => sizedBoxW4H4,
          ),
        )
        .toList();

    _refreshController.finishRefresh();

    return EasyRefresh(
      key: const ValueKey('success'),
      controller: _refreshController,
      header: const MaterialHeader(),
      onRefresh: () {
        context.read<TopicsBloc>().add(TopicsRefreshRequested());
      },
      child: TabBarView(
        controller: tabController,
        children: groupTabBodyList,
      ),
    );
  }

  @override
  void dispose() {
    if (tabController != null) {
      tabController!
        ..removeListener(_updateIndexListener ?? () {})
        ..dispose();
    }
    _refreshController.dispose();
    tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TopicsBloc(
        forumHomeRepository:
            RepositoryProvider.of<ForumHomeRepository>(context),
      )..add(TopicsLoadRequested()),
      child: BlocConsumer<TopicsBloc, TopicsState>(
        listener: (context, state) {
          if (state.status == TopicsStatus.failed) {
            showFailedToLoadSnackBar(context);
          }
        },
        builder: (context, state) {
          final body = switch (state.status) {
            TopicsStatus.loading || TopicsStatus.initial => EasyRefresh(
                key: const ValueKey('loading'),
                controller: _refreshController,
                header: const MaterialHeader(),
                child: const LoadingShimmer(child: TopicsPlaceholder()),
              ),
            TopicsStatus.failed => buildRetryButton(context, () {
                context.read<TopicsBloc>().add(TopicsRefreshRequested());
              }),
            TopicsStatus.success when state.forumGroupList.isNotEmpty =>
              _buildContent(context, state),
            // Some server enforced situation.
            TopicsStatus.success => NeedLoginPage(
                backUri: GoRouterState.of(context).uri,
                needPop: true,
                popCallback: (context) {
                  context.read<TopicsBloc>().add(TopicsRefreshRequested());
                },
              ),
          };

          final PreferredSizeWidget tabBar;
          if (state.status == TopicsStatus.success) {
            tabBar = TabBar(
              controller: tabController,
              tabs: state.forumGroupList.map((e) => Tab(text: e.name)).toList(),
              isScrollable: true,
              tabAlignment: TabAlignment.start,
            );
          } else {
            tabBar = const PreferredSize(
              preferredSize: Size(40, 40),
              child: SizedBox.shrink(),
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: Text(context.t.navigation.topics),
              actions: [
                const ParseUrlDialogButton(),
                IconButton(
                  icon: const Icon(Icons.search_outlined),
                  onPressed: () async {
                    await context.pushNamed(ScreenPaths.search);
                  },
                ),
              ],
              // Some server enforced situation.
              bottom: state.forumGroupList.isNotEmpty ? tabBar : null,
            ),
            body: AnimatedSwitcher(duration: duration200, child: body),
          );
        },
      ),
    );
  }
}
