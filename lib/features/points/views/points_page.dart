import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/features/points/bloc/points_bloc.dart';
import 'package:tsdm_client/features/points/repository/points_repository.dart';

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
      return const Center(child: sizedCircularProgressIndicator);
    }
    _statisticsRefreshController.finishRefresh();
    return Padding(
      padding: edgeInsetsL10T5R10B20,
      child: EasyRefresh(
        controller: _statisticsRefreshController,
        scrollController: _statisticsScrollController,
        header: const MaterialHeader(),
        onRefresh: () {
          context
              .read<PointsStatisticsBloc>()
              .add(PointsStatisticsRefreshRequired());
        },
        child: SingleChildScrollView(
          controller: _statisticsScrollController,
          child: Column(
            children: [
              ...state.pointsMap.entries.map(
                (e) => ListTile(title: Text('${e.key} ${e.value}')),
              ),
              ...state.pointsRecentChangelog.map(
                (e) => Card(
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                    onTap: e.redirectUrl == null
                        ? null
                        : () async {
                            // TODO: Handle find post type url.
                            await context.dispatchAsUrl(e.redirectUrl!);
                          },
                    child: Padding(
                      padding: edgeInsetsL15T15R15B15,
                      child: Column(
                        children: [
                          Text(e.operation),
                          Text(e.changeMapString),
                          Text(e.detail),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
    return MultiBlocProvider(
      providers: [
        RepositoryProvider(
          create: (_) => PointsRepository(),
        ),
        BlocProvider(
          create: (context) => PointsStatisticsBloc(
            pointsRepository: RepositoryProvider.of(context),
          )..add(PointsStatisticsRefreshRequired()),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<PointsStatisticsBloc, PointsStatisticsState>(
            listener: (context, state) {
              //
            },
          ),
        ],
        child: Scaffold(
          appBar: AppBar(),
          body: TabBarView(
            controller: _tabController,
            children: [
              BlocBuilder<PointsStatisticsBloc, PointsStatisticsState>(
                builder: _buildStatisticsTab,
              ),
              // TODO: Changelog tab.
              Text('changelog page'),
            ],
          ),
        ),
      ),
    );
  }
}
