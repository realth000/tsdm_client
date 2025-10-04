import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/extensions/date_time.dart';
import 'package:tsdm_client/extensions/duration.dart';
import 'package:tsdm_client/features/packet/cubit/packet_detail_cubit.dart';
import 'package:tsdm_client/features/packet/models/models.dart';
import 'package:tsdm_client/features/packet/repository/packet_repository.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/utils/retry_button.dart';
import 'package:tsdm_client/utils/show_dialog.dart';
import 'package:tsdm_client/widgets/heroes.dart';

/// Page showing packet statistics detail data for a given thread.
class PacketDetailPage extends StatefulWidget {
  /// Constructor.
  const PacketDetailPage(this.tid, {super.key});

  /// Thread id.
  final int tid;

  @override
  State<PacketDetailPage> createState() => _PacketDetailPageState();
}

enum _SortBy { time, coinsLeast, coinsMost }

extension _LoopExt on _SortBy {
  _SortBy loopNext() => this == _SortBy.values.last ? _SortBy.values.first : _SortBy.values[index + 1];

  String loopNextTip(BuildContext context) => loopNext().tip(context);

  String tip(BuildContext context) => switch (this) {
    _SortBy.time => context.t.packetDetailPage.sort.sortByTime,
    _SortBy.coinsLeast => context.t.packetDetailPage.sort.sortByLeastCoins,
    _SortBy.coinsMost => context.t.packetDetailPage.sort.sortByMostCoins,
  };
}

class _PacketDetailPageState extends State<PacketDetailPage> {
  _SortBy _sortByCoins = _SortBy.time;

  String _nextSortTip = '';

  Widget _buildInfoRow(BuildContext context, List<PacketDetailModel> data) {
    final tr = context.t.packetDetailPage;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final textStyle = Theme.of(context).textTheme.labelLarge?.copyWith(color: secondaryColor);

    final timeElapsed = data.first.time.difference(data.last.time).readable(context);
    final userCount = data.length;
    final coinsCount = data.fold(0, (prev, e) => prev + e.coins);

    return InkWell(
      onTap: () async => showMessageSingleButtonDialog(
        context: context,
        title: tr.title,
        message: tr.statistics(users: userCount, coins: coinsCount, time: timeElapsed),
      ),
      child: Column(
        children: [
          sizedBoxW4H4,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.timelapse_outlined, color: secondaryColor, size: 16),
              sizedBoxW4H4,
              Text(timeElapsed, style: textStyle),
              sizedBoxW12H12,
              Icon(Icons.person_outline, color: secondaryColor, size: 16),
              sizedBoxW4H4,
              Text('$userCount', style: textStyle),
              sizedBoxW12H12,
              Icon(FontAwesomeIcons.coins, color: secondaryColor, size: 16),
              sizedBoxW4H4,
              Text('$coinsCount', style: textStyle),
              sizedBoxW12H12,
            ],
          ),
          sizedBoxW4H4,
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<PacketDetailModel> data) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    final dataSorted = switch (_sortByCoins) {
      _SortBy.time => data.toList(),
      _SortBy.coinsLeast => data.sortedByCompare((e) => e.coins, (lhs, rhs) => lhs - rhs).toList(),
      _SortBy.coinsMost => data.sortedByCompare((e) => e.coins, (lhs, rhs) => rhs - lhs).toList(),
    };

    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) => InkWell(
        onTap: () async =>
            context.pushNamed(ScreenPaths.profile, queryParameters: {'username': dataSorted[index].username}),
        child: Padding(
          key: ValueKey(dataSorted[index].id),
          padding: edgeInsetsL12T4R12.add(context.safePadding()),
          child: Row(
            children: [
              SizedBox(
                width: 30,
                child: Text(
                  '${dataSorted[index].id}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: secondaryColor),
                ),
              ),
              Expanded(
                child: ListTile(
                  leading: HeroUserAvatar(username: dataSorted[index].username, avatarUrl: null),
                  title: Text(dataSorted[index].username, style: TextStyle(color: primaryColor)),
                  subtitle: Text(dataSorted[index].time.yyyyMMDDHHMMSS()),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${dataSorted[index].coins}',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: secondaryColor),
                      ),
                      sizedBoxW4H4,
                      const Icon(FontAwesomeIcons.coins, size: 12),
                    ],
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _nextSortTip = _sortByCoins.loopNextTip(context);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        RepositoryProvider(create: (_) => PacketRepository()),
        BlocProvider(create: (context) => PacketDetailCubit(context.repo())..fetchDetail(widget.tid)),
      ],
      child: BlocBuilder<PacketDetailCubit, PacketDetailState>(
        builder: (context, state) {
          final tr = context.t.packetDetailPage;

          final (body, infoRow) = switch (state) {
            PacketDetailInitial() || PacketDetailLoading() => (const Center(child: CircularProgressIndicator()), null),
            PacketDetailFailure() => (
              Center(
                child: buildRetryButton(context, () async => context.read<PacketDetailCubit>().fetchDetail(widget.tid)),
              ),
              null,
            ),
            PacketDetailSuccess(:final data) when data.isEmpty => (
              Center(
                child: Text(
                  context.t.general.noData,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.outline),
                ),
              ),
              null,
            ),
            PacketDetailSuccess(:final data) => (_buildContent(context, data), _buildInfoRow(context, data)),
          };

          return Scaffold(
            appBar: AppBar(
              title: Text(tr.title),
              actions: [
                IconButton(
                  icon: const Icon(Icons.sort_outlined),
                  tooltip: _nextSortTip,
                  onPressed: state is PacketDetailSuccess
                      ? () => setState(() {
                          _sortByCoins = _sortByCoins.loopNext();
                          _nextSortTip = _sortByCoins.loopNextTip(context);
                        })
                      : null,
                ),
              ],
              bottom: infoRow == null ? null : PreferredSize(preferredSize: const Size.fromHeight(24), child: infoRow),
            ),
            body: SafeArea(bottom: false, child: body),
          );
        },
      ),
    );
  }
}
