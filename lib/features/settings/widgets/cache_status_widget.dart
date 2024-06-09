import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/features/settings/bloc/settings_cache_bloc.dart';
import 'package:tsdm_client/features/settings/repositories/settings_cache_repository.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/utils/show_dialog.dart';
import 'package:tsdm_client/widgets/section_list_tile.dart';

/// Widget to the cache size.
class CacheStatusWidget extends StatelessWidget {
  /// Constructor.
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
    context.read<SettingsCacheBloc>().add(SettingsCacheClearCacheRequested());
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
      create: (context) => SettingsCacheBloc(
        cacheRepository:
            RepositoryProvider.of<SettingsCacheRepository>(context),
      )..add(SettingsCacheCalculateRequested()),
      child: BlocBuilder<SettingsCacheBloc, SettingsCacheState>(
        builder: (context, state) {
          final subtitle = switch (state.status) {
            SettingsCacheStatus.initial ||
            SettingsCacheStatus.calculating ||
            SettingsCacheStatus.clearing =>
              const Row(children: [sizedCircularProgressIndicator]),
            SettingsCacheStatus.success =>
              _buildCacheHint(context, state.cacheSize),
          };

          return SectionListTile(
            leading: const Icon(Icons.cleaning_services_outlined),
            title: Text(context.t.settingsPage.storageSection.clearCache),
            subtitle: subtitle,
            onTap: state.status == SettingsCacheStatus.success
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
