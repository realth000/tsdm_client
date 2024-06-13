import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/features/settings/bloc/settings_cache_bloc.dart';
import 'package:tsdm_client/features/settings/repositories/settings_cache_repository.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';

/// Show a bottom sheet provides clear cache functionality with clear cache
/// options.
Future<void> showClearCacheBottomSheet({
  required BuildContext context,
}) async {
  await showModalBottomSheet<void>(
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
        RepositoryProvider(create: (context) => SettingsCacheRepository()),
        BlocProvider(
          create: (context) => SettingsCacheBloc(
            cacheRepository: RepositoryProvider.of(context),
          )..add(SettingsCacheCalculateRequested()),
        ),
      ],
      child: BlocConsumer<SettingsCacheBloc, SettingsCacheState>(
        listenWhen: (_, curr) => curr.status == SettingsCacheStatus.cleared,
        listener: (context, state) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(tr.clearSuccess)));
          context.pop();
        },
        builder: (context, state) {
          final body = switch (state.status) {
            SettingsCacheStatus.loaded ||
            SettingsCacheStatus.cleared =>
              SingleChildScrollView(
                child: Column(
                  children: [
                    CheckboxListTile(
                      secondary: const Icon(Icons.image_outlined),
                      title: Text(tr.images),
                      subtitle: _buildCacheHint(
                        context,
                        state.storageInfo!.imageSize,
                      ),
                      value: state.clearInfo.clearImage,
                      onChanged: (v) => context.read<SettingsCacheBloc>().add(
                            SettingsCacheUpdateClearInfoRequested(
                              state.clearInfo.copyWith(clearImage: v),
                            ),
                          ),
                    ),
                    CheckboxListTile(
                      secondary: const Icon(Icons.emoji_emotions_outlined),
                      title: Text(tr.emoji),
                      subtitle: _buildCacheHint(
                        context,
                        state.storageInfo!.emojiSize,
                      ),
                      value: state.clearInfo.clearEmoji,
                      onChanged: (v) => context.read<SettingsCacheBloc>().add(
                            SettingsCacheUpdateClearInfoRequested(
                              state.clearInfo.copyWith(clearEmoji: v),
                            ),
                          ),
                    ),
                  ],
                ),
              ),
            _ => const Center(child: CircularProgressIndicator()),
          };

          return Scaffold(
            appBar: AppBar(
              title: Text(
                tr.clearCache,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              automaticallyImplyLeading: false,
              centerTitle: true,
            ),
            body: body,
            bottomNavigationBar: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: edgeInsetsL10T10R10B10,
                    child: FilledButton(
                      onPressed: state.status == SettingsCacheStatus.loaded
                          ? () {
                              if (state.clearInfo.hasSelected) {
                                context.read<SettingsCacheBloc>().add(
                                      SettingsCacheClearCacheRequested(
                                        state.clearInfo,
                                      ),
                                    );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(tr.selectOneCache)),
                                );
                              }
                            }
                          : null,
                      child: Text(context.t.general.ok),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
