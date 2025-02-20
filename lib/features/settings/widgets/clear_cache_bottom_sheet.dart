import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/features/settings/bloc/settings_cache_bloc.dart';
import 'package:tsdm_client/features/settings/repositories/settings_cache_repository.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/utils/show_bottom_sheet.dart';
import 'package:tsdm_client/utils/show_toast.dart';

/// Show a bottom sheet provides clear cache functionality with clear cache
/// options.
Future<void> showClearCacheBottomSheet({required BuildContext context}) async {
  await showCustomBottomSheet<void>(
    title: context.t.settingsPage.storageSection.clearCache,
    context: context,
    constraints: const BoxConstraints(maxHeight: 300),
    builder: (context) => const _ClearCacheBottomSheet(),
  );
}

class _ClearCacheBottomSheet extends StatefulWidget {
  const _ClearCacheBottomSheet();

  @override
  State<_ClearCacheBottomSheet> createState() => _ClearCacheBottomSheetState();
}

class _ClearCacheBottomSheetState extends State<_ClearCacheBottomSheet> {
  Widget _buildCacheHint(BuildContext context, int v) {
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    if (v == 0) {
      return Text('0 ${suffixes[0]}');
    }
    final i = (log(v) / log(1024)).floor();
    return Text('${(v / pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}');
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.t.settingsPage.storageSection;

    // Default clear options.
    return MultiBlocProvider(
      providers: [
        RepositoryProvider(create: (_) => const SettingsCacheRepository()),
        BlocProvider(
          create:
              (context) => SettingsCacheBloc(cacheRepository: context.repo())..add(SettingsCacheCalculateRequested()),
        ),
      ],
      child: BlocConsumer<SettingsCacheBloc, SettingsCacheState>(
        listenWhen: (_, curr) => curr.status == SettingsCacheStatus.cleared,
        listener: (context, state) {
          showSnackBar(context: context, message: tr.clearSuccess);
          context.pop();
        },
        builder: (context, state) {
          final body = switch (state.status) {
            SettingsCacheStatus.loaded || SettingsCacheStatus.cleared => SingleChildScrollView(
              child: Column(
                children: [
                  CheckboxListTile(
                    secondary: const Icon(Icons.image_outlined),
                    title: Text(tr.images),
                    subtitle: _buildCacheHint(context, state.storageInfo!.imageSize),
                    value: state.clearInfo.clearImage,
                    onChanged:
                        (v) => context.read<SettingsCacheBloc>().add(
                          SettingsCacheUpdateClearInfoRequested(state.clearInfo.copyWith(clearImage: v)),
                        ),
                  ),
                  CheckboxListTile(
                    secondary: const Icon(Icons.emoji_emotions_outlined),
                    title: Text(tr.emoji),
                    subtitle: _buildCacheHint(context, state.storageInfo!.emojiSize),
                    value: state.clearInfo.clearEmoji,
                    onChanged:
                        (v) => context.read<SettingsCacheBloc>().add(
                          SettingsCacheUpdateClearInfoRequested(state.clearInfo.copyWith(clearEmoji: v)),
                        ),
                  ),
                ],
              ),
            ),
            _ => const Center(child: CircularProgressIndicator()),
          };

          return Column(
            children: [
              Expanded(child: body),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: edgeInsetsL12T12R12B12,
                      child: FilledButton(
                        onPressed:
                            state.status == SettingsCacheStatus.loaded
                                ? () {
                                  if (state.clearInfo.hasSelected) {
                                    context.read<SettingsCacheBloc>().add(
                                      SettingsCacheClearCacheRequested(state.clearInfo),
                                    );
                                  } else {
                                    showSnackBar(context: context, message: tr.selectOneCache);
                                  }
                                }
                                : null,
                        child: Text(context.t.general.ok),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
