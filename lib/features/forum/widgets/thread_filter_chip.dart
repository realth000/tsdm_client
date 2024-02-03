import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/features/forum/bloc/forum_bloc.dart';
import 'package:tsdm_client/features/forum/models/thread_filter.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';

/// Construct a chip that controlling and mutating thread filter state.
class ThreadChip extends StatelessWidget {
  /// Constructor.
  const ThreadChip({
    required this.chipLabel,
    required this.chipSelected,
    required this.sheetTitle,
    required this.sheetItemBuilder,
    super.key,
  });

  /// Label on chip
  final String chipLabel;

  /// Chip is selected or not.
  final bool chipSelected;

  /// Title in the bottom modal sheet.
  final String sheetTitle;

  /// Build to provide a list of widgets as bottom sheet content.
  final List<Widget> Function(BuildContext context, ForumState state)
      sheetItemBuilder;

  Widget _buildContent(BuildContext context, ForumState state) {
    return Scaffold(
      body: Padding(
        padding: edgeInsetsL15T15R15B15,
        child: Column(
          children: [
            SizedBox(height: 50, child: Center(child: Text(sheetTitle))),
            sizedBoxW10H10,
            Expanded(
              child: SingleChildScrollView(
                child: Column(children: sheetItemBuilder(context, state)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ForumBloc, ForumState>(
      builder: (context, state) {
        return FilterChip(
          label: Text(chipLabel),
          selected: chipSelected,
          onSelected: state.status.isLoading()
              ? null
              : (v) async {
                  // bottom sheet.
                  await showModalBottomSheet<void>(
                    context: context,
                    builder: (_) => BlocProvider.value(
                      value: context.read<ForumBloc>(),
                      child: BlocBuilder<ForumBloc, ForumState>(
                        builder: _buildContent,
                      ),
                    ),
                  );
                },
        );
      },
    );
  }
}

/// Chip shows and triggers filter on thread types.
class ThreadTypeChip extends StatelessWidget {
  /// Constructor.
  const ThreadTypeChip({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ForumBloc, ForumState>(
      builder: (context, state) {
        return ThreadChip(
          chipLabel: state.filterState.filterType?.name ??
              state.filterTypeList
                  .firstWhereOrNull((e) => e.typeID == null)
                  ?.name ??
              '',
          chipSelected: state.filterState.filterType?.typeID != null,
          sheetTitle: context.t.forumPage.threadTab.threadType,
          sheetItemBuilder: (context, state) => state.filterTypeList
              .map(
                (e) => ListTile(
                  title: Text(e.name),
                  onTap: () {
                    context.read<ForumBloc>().add(
                          ForumChangeThreadFilterStateRequested(
                            state.filterState.copyWith(
                              filter: e.filterName,
                              filterType: e,
                            ),
                          ),
                        );
                    context.pop();
                  },
                ),
              )
              .toList(),
        );
      },
    );
  }
}

/// Chip shows and triggers filter on thread special types.
class ThreadSpecialTypeChip extends StatelessWidget {
  /// Constructor.
  const ThreadSpecialTypeChip({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ForumBloc, ForumState>(
      builder: (context, state) {
        return ThreadChip(
          chipLabel: state.filterState.filterSpecialType?.name ??
              state.filterSpecialTypeList
                  .firstWhereOrNull((e) => e.specialType == null)
                  ?.name ??
              '',
          chipSelected:
              state.filterState.filterSpecialType?.specialType != null,
          sheetTitle: context.t.forumPage.threadTab.threadSpecialType,
          sheetItemBuilder: (context, state) => state.filterSpecialTypeList
              .map(
                (e) => ListTile(
                  title: Text(e.name),
                  onTap: () {
                    context.read<ForumBloc>().add(
                          ForumChangeThreadFilterStateRequested(
                            state.filterState.copyWith(
                              filter: e.filterName,
                              filterSpecialType: e,
                            ),
                          ),
                        );
                    context.pop();
                  },
                ),
              )
              .toList(),
        );
      },
    );
  }
}

/// Chip shows and triggers filter on thread publish date.
class ThreadDatelineChip extends StatelessWidget {
  /// Constructor.
  const ThreadDatelineChip({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ForumBloc, ForumState>(
      builder: (context, state) {
        return ThreadChip(
          chipLabel: state.filterState.filterDateline?.name ??
              state.filterDatelineList
                  .firstWhereOrNull((e) => e.dateline == null)
                  ?.name ??
              '',
          chipSelected: state.filterState.filterDateline?.dateline != null,
          sheetTitle: context.t.forumPage.threadTab.threadDateline,
          sheetItemBuilder: (context, state) => state.filterDatelineList
              .map(
                (e) => ListTile(
                  title: Text(e.name),
                  onTap: () {
                    context.read<ForumBloc>().add(
                          ForumChangeThreadFilterStateRequested(
                            state.filterState.copyWith(
                              filter: e.filterName,
                              filterDateline: e,
                            ),
                          ),
                        );
                    context.pop();
                  },
                ),
              )
              .toList(),
        );
      },
    );
  }
}

/// Chip shows and triggers filter on thread sort order.
class ThreadOrderChip extends StatelessWidget {
  /// Constructor.
  const ThreadOrderChip({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ForumBloc, ForumState>(
      builder: (context, state) {
        return ThreadChip(
          chipLabel: state.filterState.filterOrder?.name ??
              state.filterOrderList
                  .firstWhereOrNull((e) => e.orderBy == null)
                  ?.name ??
              '',
          chipSelected: state.filterState.filterOrder?.orderBy != null,
          sheetTitle: context.t.forumPage.threadTab.threadOrder,
          sheetItemBuilder: (context, state) => state.filterOrderList
              .map(
                (e) => ListTile(
                  title: Text(e.name),
                  onTap: () {
                    context.read<ForumBloc>().add(
                          ForumChangeThreadFilterStateRequested(
                            state.filterState.copyWith(
                              filter: e.filterName,
                              filterOrder: e,
                            ),
                          ),
                        );
                    context.pop();
                  },
                ),
              )
              .toList(),
        );
      },
    );
  }
}

/// Chip shows and triggers filter on thread digested mark.
class ThreadDigestChip extends StatelessWidget {
  /// Constructor.
  const ThreadDigestChip({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ForumBloc, ForumState>(
      builder: (context, state) {
        return FilterChip(
          label: Text(context.t.forumPage.threadTab.threadDigested),
          selected: state.filterState.filterDigest.digest,
          onSelected: state.status.isLoading()
              ? null
              : (v) async {
                  context.read<ForumBloc>().add(
                        ForumChangeThreadFilterStateRequested(
                          state.filterState.copyWith(
                            filter: state.filterState.filterDigest.filterName,
                            filterDigest: FilterDigest(digest: v),
                          ),
                        ),
                      );
                },
        );
      },
    );
  }
}

/// Chip shows and triggers filter on thread recommended mark.
class ThreadRecommendedChip extends StatelessWidget {
  /// Constructor.
  const ThreadRecommendedChip({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ForumBloc, ForumState>(
      builder: (context, state) {
        return FilterChip(
          label: Text(context.t.forumPage.threadTab.threadRecommended),
          selected: state.filterState.filterRecommend.recommend,
          onSelected: state.status.isLoading()
              ? null
              : state.status.isLoading()
                  ? null
                  : (v) async {
                      context.read<ForumBloc>().add(
                            ForumChangeThreadFilterStateRequested(
                              state.filterState.copyWith(
                                filter: state
                                    .filterState.filterRecommend.filterName,
                                filterRecommend: FilterRecommend(recommend: v),
                              ),
                            ),
                          );
                    },
        );
      },
    );
  }
}
