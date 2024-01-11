import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/features/settings/bloc/cache_bloc.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/shared/repositories/cache_repository/cache_repository.dart';
import 'package:tsdm_client/utils/show_dialog.dart';
import 'package:tsdm_client/widgets/section_list_tile.dart';

class CacheStatusWidget extends StatelessWidget {
  const CacheStatusWidget({super.key});

  Future<void> _showClearCacheDialog(BuildContext context) async {
    final result = await showQuestionDialog(
      title: context.t.settingsPage.storageSection.sureToClear,
      message: context.t.settingsPage.storageSection.downloadAgainInfo,
      context: context,
    );
    if (result != true || !context.mounted) {
      return;
    }
    context.read<CacheBloc>().add(CacheClearCacheRequested());
  }

  Widget _buildCacheHint(BuildContext context, int v) {
    const suffixes = ['b', 'kb', 'mb', 'gb', 'tb'];
    if (v == 0) {
      return Text('0${suffixes[0]}');
    }
    final i = (log(v) / log(1024)).floor();
    return Text(((v / pow(1024, i)).toStringAsFixed(2)) + suffixes[i]);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CacheBloc(
          cacheRepository: RepositoryProvider.of<CacheRepository>(context))
        ..add(CacheCalculateRequested()),
      child: BlocBuilder<CacheBloc, CacheState>(
        builder: (context, state) {
          final subtitle = switch (state.status) {
            CacheStatus.initial ||
            CacheStatus.calculating ||
            CacheStatus.clearing =>
              const Row(children: [sizedCircularProgressIndicator]),
            CacheStatus.success => _buildCacheHint(context, state.cacheSize),
          };

          return SectionListTile(
            leading: const Icon(Icons.cleaning_services_outlined),
            title: Text(context.t.settingsPage.storageSection.clearCache),
            subtitle: subtitle,
            onTap: state.status == CacheStatus.success
                ? () async {
                    await _showClearCacheDialog(context);
                  }
                : null,
          );
        },
      ),
    );
  }
}
