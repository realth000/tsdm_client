import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/features/packet/cubit/packet_cubit.dart';
import 'package:tsdm_client/features/packet/repository/packet_repository.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';

/// 红包
class PacketCard extends StatelessWidget {
  /// Constructor.
  const PacketCard(this.packetUrl, {super.key});

  /// Url to fetch/receive the packet.
  final String packetUrl;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        RepositoryProvider(
          create: (_) => PacketRepository(),
        ),
        BlocProvider<PacketCubit>(
          create: (context) =>
              PacketCubit(packetRepository: RepositoryProvider.of(context)),
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
                SnackBar(content: Text(context.t.packetCard.failedToOpen)),
              );
            }
          } else if (state.status == PacketStatus.success) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.reason!)));
          } else if (state.status == PacketStatus.takenAway) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.t.packetCard.allTakenAway)),
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
              PacketStatus.failed ||
              PacketStatus.takenAway =>
                Text(context.t.packetCard.open),
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
                  children: [
                    Text(
                      context.t.packetCard.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    sizedBoxW12H12,
                    SizedBox(
                      width: sizeButtonInCardMinWidth,
                      child: FilledButton.icon(
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
