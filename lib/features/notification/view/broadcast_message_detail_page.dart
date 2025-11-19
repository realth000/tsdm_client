import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/extensions/date_time.dart';
import 'package:tsdm_client/features/notification/bloc/broadcast_message_detail_cubit.dart';
import 'package:tsdm_client/features/notification/repository/notification_repository.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/utils/html/html_muncher.dart';
import 'package:tsdm_client/utils/retry_button.dart';
import 'package:tsdm_client/widgets/indicator.dart';
import 'package:tsdm_client/widgets/single_line_text.dart';

/// Detail page of a `BroadcastMessage`.
final class BroadcastMessageDetailPage extends StatelessWidget {
  /// Constructor.
  const BroadcastMessageDetailPage({required this.pmid, super.key});

  /// Url to fetch the broadcast message detail data.
  final String pmid;

  Widget _buildBody(BuildContext context, BroadcastMessageDetailState state) {
    return SingleChildScrollView(
      child: Padding(
        padding: edgeInsetsL12R12B12.add(context.safePadding()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.campaign_outlined)),
              title: SingleLineText(context.t.noticePage.broadcastMessageTab.system),
              subtitle: Text(state.dateTime?.yyyyMMDD() ?? ''),
            ),
            sizedBoxW4H4,
            Padding(padding: edgeInsetsL16R16, child: munchElement(context, state.messageNode!)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        RepositoryProvider(create: (_) => NotificationRepository()),
        BlocProvider(
          create: (context) {
            final cubit = BroadcastMessageDetailCubit(context.repo());
            unawaited(cubit.fetchDetail(pmid));
            return cubit;
          },
        ),
      ],
      child: BlocBuilder<BroadcastMessageDetailCubit, BroadcastMessageDetailState>(
        builder: (context, state) {
          final body = switch (state.status) {
            BroadcastMessageDetailStatus.initial ||
            BroadcastMessageDetailStatus.loading => const CenteredCircularIndicator(),
            BroadcastMessageDetailStatus.success => _buildBody(context, state),
            BroadcastMessageDetailStatus.failed => buildRetryButton(context, () async {
              await context.read<BroadcastMessageDetailCubit>().fetchDetail(pmid);
            }),
          };

          return Scaffold(
            appBar: AppBar(
              title: Text(context.t.noticePage.broadcastMessageTab.title),
              actions: [
                IconButton(
                  icon: const Icon(Icons.open_in_new_outlined),
                  tooltip: context.t.general.openInBrowser,
                  onPressed: () async => context.dispatchAsUrl('$broadcastMessageDetailUrl$pmid', external: true),
                ),
              ],
            ),
            body: SafeArea(top: false, bottom: false, child: body),
          );
        },
      ),
    );
  }
}
