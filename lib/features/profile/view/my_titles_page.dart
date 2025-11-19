import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/features/profile/bloc/my_titles_cubit.dart';
import 'package:tsdm_client/features/profile/repository/my_titles_repository.dart';
import 'package:tsdm_client/features/profile/widgets/secondary_title_card.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/utils/retry_button.dart';
import 'package:tsdm_client/utils/show_toast.dart';
import 'package:tsdm_client/widgets/indicator.dart';
import 'package:tsdm_client/widgets/single_line_text.dart';

/// Page showing current user's titles.
///
/// With link to visit title shop.
class MyTitlesPage extends StatefulWidget {
  /// Constructor.
  const MyTitlesPage({super.key});

  @override
  State<MyTitlesPage> createState() => _MyTitlesPageState();
}

class _MyTitlesPageState extends State<MyTitlesPage> {
  @override
  Widget build(BuildContext context) {
    final tr = context.t.myTitlesPage;
    return MultiBlocProvider(
      providers: [
        RepositoryProvider(
          create: (_) => MyTitlesRepository(),
        ),
        BlocProvider(
          create: (context) {
            final cubit = MyTitlesCubit(context.repo());
            unawaited(cubit.fetchAvailableSecondaryTitles());
            return cubit;
          },
        ),
      ],
      child: BlocConsumer<MyTitlesCubit, MyTitlesState>(
        listener: (context, state) {
          if (state.status == MyTitlesStatus.failure) {
            showSnackBar(context: context, message: context.t.general.failedToLoad);
          }
        },
        builder: (context, state) {
          final currentTitleName = state.titles.firstWhereOrNull((v) => v.activated)?.name;
          final body = switch (state.status) {
            MyTitlesStatus.initial || MyTitlesStatus.loadingTitles => const CenteredCircularIndicator(),
            MyTitlesStatus.failure when state.titles.isEmpty => buildRetryButton(
              context,
              () async => context.read<MyTitlesCubit>().fetchAvailableSecondaryTitles(),
            ),
            MyTitlesStatus.switchingTitle || MyTitlesStatus.success || MyTitlesStatus.failure => ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48),
                      child: Row(
                        children: [
                          sizedBoxW12H12,
                          Icon(
                            Icons.lightbulb_outline,
                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                          ),
                          sizedBoxW4H4,
                          Expanded(
                            child: SingleLineText(
                              currentTitleName == null ? tr.noneActivated : tr.activated(name: currentTitleName),
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                          if (currentTitleName != null) ...[
                            sizedBoxW8H8,
                            TextButton(
                              child: Text(tr.unset),
                              onPressed: () async => context.read<MyTitlesCubit>().unsetSecondaryTitle(),
                            ),
                          ],
                        ],
                      ),
                    ),
                    ...state.titles.map(SecondaryTitleCard.new),
                  ],
                ),
              ),
            ),
          };

          return Scaffold(
            appBar: AppBar(
              title: Text(tr.title),
              actions: [
                IconButton(
                  icon: const Icon(Icons.shopping_bag_outlined),
                  tooltip: tr.openTitleShop,
                  onPressed: () async =>
                      context.dispatchAsUrl('$baseUrl/plugin.php?id=tsdmtitle:tsdmtitle&action=shop'),
                ),
              ],
            ),
            body: body,
          );
        },
      ),
    );
  }
}
