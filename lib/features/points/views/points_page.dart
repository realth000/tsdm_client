import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/extensions/list.dart';
import 'package:tsdm_client/features/points/bloc/points_bloc.dart';
import 'package:tsdm_client/features/points/repository/points_repository.dart';
import 'package:tsdm_client/features/points/widgets/points_card.dart';
import 'package:tsdm_client/features/points/widgets/points_query_form.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/utils/show_toast.dart';
import 'package:tsdm_client/widgets/attr_block.dart';
import 'package:tsdm_client/widgets/single_line_text.dart';

/// Page to show current logged user's points statistics and changelog.
class PointsPage extends StatefulWidget {
  /// Constructor
  const PointsPage({super.key});

  @override
  State<PointsPage> createState() => _PointsPageState();
}

class _PointsPageState extends State<PointsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final EasyRefreshController _statisticsRefreshController;
  late final ScrollController _statisticsScrollController;
  late final EasyRefreshController _changelogRefreshController;
  late final ScrollController _changelogScrollController;

  Widget _buildStatisticsTab(
    BuildContext context,
    PointsStatisticsState state,
  ) {
    if (state.status == PointsStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    _statisticsRefreshController.finishRefresh();

    final attrList = state.pointsMap.entries.toList();

    return EasyRefresh(
      controller: _statisticsRefreshController,
      scrollController: _statisticsScrollController,
      header: const MaterialHeader(),
      onRefresh: () {
        context
            .read<PointsStatisticsBloc>()
            .add(PointsStatisticsRefreshRequested());
      },
      child: SingleChildScrollView(
        controller: _statisticsScrollController,
        child: Padding(
          padding: edgeInsetsL12T4R12B4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              sizedBoxW4H4,
              GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisExtent: 70,
                ),
                itemCount: attrList.length,
                itemBuilder: (context, index) {
                  final attr = attrList[index];
                  return AttrBlock(name: attr.key, value: attr.value);
                },
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
              ),
              Row(
                children: [
                  SingleLineText(
                    context.t.pointsPage.statisticsTab.recentChangelog,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  TextButton(
                    child: Text(context.t.general.more),
                    onPressed: () {
                      _tabController.animateTo(1);
                    },
                  ),
                ],
              ),
              sizedBoxW12H12,
              ...state.recentChangelog
                  .map(PointsChangeCard.new)
                  .toList()
                  .cast<Widget>()
                  .insertBetween(sizedBoxW4H4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChangelogTab(
    BuildContext context,
    PointsChangelogState state,
  ) {
    late final Widget body;
    if (state.status == PointsStatus.loading) {
      body = const Expanded(
        child: Center(child: CircularProgressIndicator()),
      );
    } else {
      final changelogList = EasyRefresh(
        controller: _changelogRefreshController,
        scrollController: _changelogScrollController,
        header: const MaterialHeader(),
        footer: const MaterialFooter(),
        onLoad: () async {
          if (state.currentPage >= state.totalPages) {
            _changelogRefreshController.finishLoad(IndicatorResult.noMore);
            showNoMoreSnackBar(context);
            return;
          }
          context
              .read<PointsChangelogBloc>()
              .add(PointsChangelogLoadMoreRequested(state.currentPage));
        },
        onRefresh: () {
          context
              .read<PointsChangelogBloc>()
              .add(PointsChangelogRefreshRequested());
        },
        child: ListView.separated(
          shrinkWrap: true,
          padding: edgeInsetsL12T4R12B4,
          itemCount: state.fullChangelog.length,
          itemBuilder: (_, index) =>
              PointsChangeCard(state.fullChangelog[index]),
          separatorBuilder: (_, __) => sizedBoxW4H4,
        ),
      );

      body = Expanded(child: changelogList);
    }

    _changelogRefreshController
      ..finishLoad()
      ..finishRefresh();

    return Column(
      children: [
        Padding(
          padding: edgeInsetsL12T4R12,
          child: PointsQueryForm(state.allParameters),
        ),
        sizedBoxW4H4,
        body,
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _statisticsRefreshController = EasyRefreshController(
      controlFinishRefresh: true,
    );
    _statisticsScrollController = ScrollController();
    _changelogRefreshController = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );
    _changelogScrollController = ScrollController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _statisticsRefreshController.dispose();
    _statisticsScrollController.dispose();
    _changelogRefreshController.dispose();
    _changelogScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.t.pointsPage;
    return MultiBlocProvider(
      providers: [
        RepositoryProvider(
          create: (_) => PointsRepository(),
        ),
        BlocProvider(
          create: (context) => PointsStatisticsBloc(
            pointsRepository: context.repo(),
          )..add(PointsStatisticsRefreshRequested()),
        ),
        BlocProvider(
          create: (context) => PointsChangelogBloc(
            pointsRepository: context.repo(),
          )..add(PointsChangelogRefreshRequested()),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(tr.title),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: tr.statisticsTab.title),
              Tab(text: tr.changelogTab.title),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            BlocBuilder<PointsStatisticsBloc, PointsStatisticsState>(
              builder: _buildStatisticsTab,
            ),
            BlocBuilder<PointsChangelogBloc, PointsChangelogState>(
              builder: _buildChangelogTab,
            ),
          ],
        ),
      ),
    );
  }
}
