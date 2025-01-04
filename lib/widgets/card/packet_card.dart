import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/features/packet/cubit/packet_cubit.dart';
import 'package:tsdm_client/features/packet/repository/packet_repository.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/routes/screen_paths.dart';

/// 红包
class PacketCard extends StatelessWidget {
  /// Constructor.
  const PacketCard(
    this.packetUrl, {
    required this.allTaken,
    super.key,
  });

  /// Regexp to parse thread id from [packetUrl].
  ///
  /// Because here we are deeply inside a thread where we do not have direct
  /// access to current thread.
  static final _re = RegExp(r'tid=(?<tid>\d+)');

  /// Url to fetch/receive the packet.
  final String packetUrl;

  /// Are all packet taken away.
  final bool allTaken;

  @override
  Widget build(BuildContext context) {
    final tid = _re.firstMatch(packetUrl)?.namedGroup('tid')?.parseToInt();

    final primaryColor = Theme.of(context).colorScheme.primary;
    final tr = context.t.packetCard;

    return MultiBlocProvider(
      providers: [
        RepositoryProvider(
          create: (_) => PacketRepository(),
        ),
        BlocProvider<PacketCubit>(
          create: (context) => PacketCubit(
            packetRepository: context.repo(),
            allTaken: allTaken,
          ),
        ),
      ],
      child: BlocListener<PacketCubit, PacketState>(
        listener: (context, state) {
          if (state.status == PacketStatus.failed) {
            if (state.reason != null) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.reason!)));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(tr.failedToOpen)),
              );
            }
          } else if (state.status == PacketStatus.success) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.reason!)));
          } else if (state.status == PacketStatus.takenAway) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(tr.allTakenAway)),
            );
          }
        },
        child: BlocBuilder<PacketCubit, PacketState>(
          builder: (context, state) {
            final body = switch (state.status) {
              PacketStatus.loading =>
                const Center(child: sizedCircularProgressIndicator),
              PacketStatus.initial ||
              PacketStatus.success ||
              PacketStatus.failed ||
              PacketStatus.takenAway =>
                const Icon(FontAwesomeIcons.solidEnvelopeOpen),
            };

            final label = switch (state.status) {
              PacketStatus.loading => const Text(''),
              PacketStatus.initial ||
              PacketStatus.success ||
              PacketStatus.failed =>
                Text(tr.open),
              PacketStatus.takenAway => Text(tr.allTakenAway),
            };

            final callback = switch (state.status) {
              PacketStatus.loading ||
              PacketStatus.success ||
              PacketStatus.takenAway =>
                null,
              PacketStatus.initial || PacketStatus.failed => () async =>
                  context.read<PacketCubit>().receivePacket(packetUrl),
            };

            return Card(
              child: Padding(
                padding: edgeInsetsL16T16R16B16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(FontAwesomeIcons.coins, color: primaryColor),
                        sizedBoxW8H8,
                        Text(
                          tr.title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: primaryColor,
                                  ),
                        ),
                        // Some spacing.
                        sizedBoxW32H32,
                        sizedBoxW32H32,
                        sizedBoxW32H32,
                        IconButton(
                          icon: Icon(
                            Icons.bar_chart_outlined,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          onPressed: tid == null
                              ? null
                              : () async => context.pushNamed(
                                    ScreenPaths.packetDetail,
                                    pathParameters: {'tid': '$tid'},
                                  ),
                        ),
                      ],
                    ),
                    sizedBoxW12H12,
                    Text(tr.detail),
                    sizedBoxW12H12,
                    SizedBox(
                      width: sizeButtonInCardMinWidth,
                      child: OutlinedButton.icon(
                        icon: body,
                        label: label,
                        onPressed: callback,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
