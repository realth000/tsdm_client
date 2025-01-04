import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/extensions/date_time.dart';
import 'package:tsdm_client/features/packet/cubit/packet_detail_cubit.dart';
import 'package:tsdm_client/features/packet/models/models.dart';
import 'package:tsdm_client/features/packet/repository/packet_repository.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/utils/retry_button.dart';
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

class _PacketDetailPageState extends State<PacketDetailPage> {
  Widget _buildContent(BuildContext context, List<PacketDetailModel> data) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) => InkWell(
        onTap: () async => context.pushNamed(
          ScreenPaths.profile,
          queryParameters: {'username': data[index].username},
        ),
        child: Padding(
          padding: edgeInsetsL12T4R12,
          child: Row(
            children: [
              Text(
                '${data[index].id}',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: secondaryColor),
              ),
              Expanded(
                child: ListTile(
                  leading: HeroUserAvatar(
                    username: data[index].username,
                    avatarUrl: null,
                  ),
                  title: Text(
                    data[index].username,
                    style: TextStyle(color: primaryColor),
                  ),
                  subtitle: Text(data[index].time.yyyyMMDDHHMMSS()),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${data[index].coins}',
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(color: secondaryColor),
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

    // final table = Table(
    //   defaultColumnWidth: const IntrinsicColumnWidth(),
    //   columnWidths: const <int, TableColumnWidth>{
    //     0: FixedColumnWidth(50),
    //     1: FixedColumnWidth(200),
    //     2: FixedColumnWidth(60),
    //     3: FixedColumnWidth(150),
    //   },
    //   defaultVerticalAlignment: TableCellVerticalAlignment.middle,
    //   children: [
    //     // Table header.
    //     TableRow(
    //       children: ['序号', '用户', '天使币', '时间']
    //           .map(
    //             (e) => Text(
    //               e,
    //               style: Theme.of(context)
    //                   .textTheme
    //                   .titleSmall
    //                   ?.copyWith(color: secondaryColor),
    //             ),
    //           )
    //           .toList(),
    //     ),

    //     // Table body.
    //     ...data.mapIndexed(
    //       (idx, e) => TableRow(
    //         decoration: BoxDecoration(
    //           color: idx.isOdd
    //               ? Theme.of(context).colorScheme.surfaceContainerHigh
    //               : null,
    //         ),
    //         children: [
    //           // Column 0
    //           // id
    //           Text('${e.id}'),
    //           // Column 1
    //           // User info
    //           Row(
    //             children: [
    //               SizedBox(
    //                 height: 50,
    //                 child: Center(
    //                   child: GestureDetector(
    //                     onTap: () async => context.pushNamed(
    //                       ScreenPaths.profile,
    //                       queryParameters: {'username': e.username},
    //                     ),
    //                     // TODO: Add hero here.
    //                     child: HeroUserAvatar(
    //                       username: e.username,
    //                       avatarUrl: null,
    //                     ),
    //                   ),
    //                 ),
    //               ),
    //               sizedBoxW4H4,
    //               Expanded(
    //                 child: GestureDetector(
    //                   onTap: () async => context.pushNamed(
    //                     ScreenPaths.profile,
    //                     queryParameters: {'username': e.username},
    //                   ),
    //                   child: Row(
    //                     children: [
    //                       Text(
    //                         e.username,
    //                         textAlign: TextAlign.left,
    //                       ),
    //                     ],
    //                   ),
    //                 ),
    //               ),
    //             ],
    //           ),
    //           // Column 2
    //           // coins
    //           Text('${e.coins}', style: TextStyle(color: primaryColor)),

    //           // Column 3
    //           // time
    //           Text(e.time.yyyyMMDDHHMMSS()),
    //         ],
    //       ),
    //     ),
    //   ],
    // );

    // return Padding(
    //   padding: edgeInsetsL4R4,
    //   child: SingleChildScrollView(
    //     child: SingleChildScrollView(
    //       scrollDirection: Axis.horizontal,
    //       child: table,
    //     ),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        RepositoryProvider(create: (_) => PacketRepository()),
        BlocProvider(
          create: (context) =>
              PacketDetailCubit(context.repo())..fetchDetail(widget.tid),
        ),
      ],
      child: BlocBuilder<PacketDetailCubit, PacketDetailState>(
        builder: (context, state) {
          final tr = context.t.packetDetailPage;

          final body = switch (state) {
            PacketDetailInitial() ||
            PacketDetailLoading() =>
              const Center(child: CircularProgressIndicator()),
            PacketDetailFailure() => Center(
                child: buildRetryButton(
                  context,
                  () async =>
                      context.read<PacketDetailCubit>().fetchDetail(widget.tid),
                ),
              ),
            PacketDetailSuccess(:final data) => _buildContent(context, data),
          };

          return Scaffold(
            appBar: AppBar(
              title: Text(tr.title),
            ),
            body: body,
          );
        },
      ),
    );
  }
}
