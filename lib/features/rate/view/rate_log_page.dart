import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart' show FpdartOnIterableOfIterable;
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/extensions/date_time.dart';
import 'package:tsdm_client/features/rate/bloc/rate_log_cubit.dart';
import 'package:tsdm_client/features/rate/models/models.dart';
import 'package:tsdm_client/features/rate/repository/rate_repository.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/utils/retry_button.dart';
import 'package:tsdm_client/widgets/heroes.dart';
import 'package:tsdm_client/widgets/quoted_text.dart';

/// Page to view all rate log for a post.
class RateLogPage extends StatefulWidget {
  /// Constructor.
  const RateLogPage({required this.tid, required this.pid, this.threadTitle, super.key});

  /// Thread id.
  final String tid;

  /// Post id.
  final String pid;

  /// Optional thread title.
  final String? threadTitle;

  @override
  State<RateLogPage> createState() => _RateLogPageState();
}

class _RateLogPageState extends State<RateLogPage> with SingleTickerProviderStateMixin {
  late final TabController tabController;

  Widget _buildAccumulatedCard(RateLogAccumulatedItem logItem) => Card(
    margin: EdgeInsets.zero,
    clipBehavior: Clip.hardEdge,
    child: InkWell(
      onTap: () async => context.pushNamed(ScreenPaths.profile, queryParameters: {'uid': logItem.uid}),
      child: Padding(
        padding: edgeInsetsL12T12R12B12,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              minTileHeight: 0,
              minVerticalPadding: 0,
              leading: HeroUserAvatar(username: logItem.username, avatarUrl: null, disableHero: true),
              title: Text(logItem.username),
              subtitle: DefaultTextStyle(
                style: Theme.of(context).textTheme.labelSmall!.copyWith(color: Theme.of(context).colorScheme.outline),
                child: Wrap(
                  children: logItem.firstRateTime != logItem.lastRateTime
                      ? [
                          Text(logItem.firstRateTime.yyyyMMDDHHMMSS()),
                          const Text(' ~ '),
                          Text(logItem.lastRateTime.yyyyMMDDHHMMSS()),
                        ]
                      : [Text(logItem.firstRateTime.yyyyMMDDHHMMSS())],
                ),
              ),
            ),
            sizedBoxW8H8,
            if (logItem.reason.isNotEmpty) ...[
              Flexible(
                child: QuotedText(
                  logItem.reason,
                  //style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
              ),
              sizedBoxW12H12,
            ],
            DefaultTextStyle(
              style: Theme.of(context).textTheme.bodyMedium!,
              child: Wrap(
                children: logItem.attrMap.entries
                    .map(
                      (attr) => [
                        Text(attr.key),
                        sizedBoxW8H8,
                        Text(
                          '${attr.value > 0 ? "+" : "-"}${attr.value}',
                          style: TextStyle(
                            color: attr.value > 0
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        sizedBoxW12H12,
                      ],
                    )
                    .flatten
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildSimpleCard(RateLogItem logItem) => Card(
    margin: EdgeInsets.zero,
    clipBehavior: Clip.hardEdge,
    child: InkWell(
      onTap: () async => context.pushNamed(ScreenPaths.profile, queryParameters: {'uid': logItem.uid}),
      child: Padding(
        padding: edgeInsetsL12T12R12B12,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              minTileHeight: 0,
              minVerticalPadding: 0,
              leading: HeroUserAvatar(username: logItem.username, avatarUrl: null, disableHero: true),
              title: Text(logItem.username),
              subtitle: Text(
                logItem.time.yyyyMMDDHHMMSS(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.outline),
              ),
            ),
            sizedBoxW8H8,
            if (logItem.reason.isNotEmpty) ...[
              Flexible(
                child: QuotedText(
                  logItem.reason,
                  //style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
              ),
              sizedBoxW12H12,
            ],
            DefaultTextStyle(
              style: Theme.of(context).textTheme.bodyMedium!,
              child: Wrap(
                children: [
                  Text(logItem.attrName),
                  sizedBoxW8H8,
                  Text(
                    '${logItem.attrValue > 0 ? "+" : "-"}${logItem.attrValue}',
                    style: TextStyle(
                      color: logItem.attrValue > 0
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.t.rateLogPage;

    return MultiBlocProvider(
      providers: [
        RepositoryProvider(create: (_) => RateRepository()),
        BlocProvider(
          create: (context) => RateLogCubit(context.repo())..fetchLog(tid: widget.tid, pid: widget.pid),
        ),
      ],
      child: BlocBuilder<RateLogCubit, RateLogState>(
        builder: (context, state) {
          final body = switch (state.status) {
            RateLogStatus.initial || RateLogStatus.loading => const Center(child: CircularProgressIndicator()),
            RateLogStatus.failure => buildRetryButton(
              context,
              () => context.read<RateLogCubit>().fetchLog(tid: widget.tid, pid: widget.pid),
            ),
            RateLogStatus.success => TabBarView(
              controller: tabController,
              children: [
                ListView.separated(
                  padding: edgeInsetsL12T4R12B4,
                  separatorBuilder: (_, _) => sizedBoxW4H4,
                  itemCount: state.accumulatedLogItems.length,
                  itemBuilder: (_, idx) => _buildAccumulatedCard(state.accumulatedLogItems[idx]),
                ),
                ListView.separated(
                  padding: edgeInsetsL12T4R12B4,
                  separatorBuilder: (_, _) => sizedBoxW4H4,
                  itemCount: state.logItems.length,
                  itemBuilder: (_, idx) => _buildSimpleCard(state.logItems[idx]),
                ),
              ],
            ),
          };

          return Scaffold(
            appBar: AppBar(
              title: Text(tr.title),
              bottom: state.status != RateLogStatus.success
                  ? null
                  : TabBar(
                      controller: tabController,
                      tabs: [
                        Tab(text: tr.tabs.accumulated),
                        Tab(text: tr.tabs.original),
                      ],
                    ),
            ),
            body: body,
          );
        },
      ),
    );
  }
}
