import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/features/thread_visit_history/bloc/thread_visit_history_bloc.dart';
import 'package:tsdm_client/features/thread_visit_history/widgets/thread_visit_history_card.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/utils/retry_button.dart';
import 'package:tsdm_client/widgets/tips.dart';

/// Page of thread visit history.
class ThreadVisitHistoryPage extends StatefulWidget {
  /// Constructor.
  const ThreadVisitHistoryPage({super.key});

  @override
  State<ThreadVisitHistoryPage> createState() => _ThreadVisitHistoryPageState();
}

class _ThreadVisitHistoryPageState extends State<ThreadVisitHistoryPage> {
  @override
  Widget build(BuildContext context) {
    final tr = context.t.threadVisitHistoryPage;
    return BlocProvider(
      create: (context) => ThreadVisitHistoryBloc(context.repo())
        ..add(const ThreadVisitHistoryFetchAllRequested()),
      child: BlocBuilder<ThreadVisitHistoryBloc, ThreadVisitHistoryState>(
        builder: (context, state) {
          final body = switch (state.status) {
            ThreadVisitHistoryStatus.initial ||
            ThreadVisitHistoryStatus.loadingData =>
              const Center(child: CircularProgressIndicator()),
            ThreadVisitHistoryStatus.savingData ||
            ThreadVisitHistoryStatus.success =>
              _Body(state.history),
            ThreadVisitHistoryStatus.failure => buildRetryButton(
                context,
                () => context
                    .read<ThreadVisitHistoryBloc>()
                    .add(const ThreadVisitHistoryFetchAllRequested()),
              ),
          };

          return Scaffold(
            appBar: AppBar(
              title: Text(tr.title),
              bottom: Tips(tr.localOnlyTip, sizePreferred: true),
            ),
            body: AnimatedSwitcher(
              duration: duration200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sizedBoxW4H4,
                  sizedBoxW4H4,
                  Expanded(child: body),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body(this.models);

  final List<ThreadVisitHistoryModel> models;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  final _refreshController = EasyRefreshController(controlFinishRefresh: true);
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EasyRefresh.builder(
      controller: _refreshController,
      scrollController: _scrollController,
      header: const MaterialHeader(),
      onRefresh: () => context
          .read<ThreadVisitHistoryBloc>()
          .add(const ThreadVisitHistoryFetchAllRequested()),
      childBuilder: (context, physics) {
        return ListView.separated(
          controller: _scrollController,
          physics: physics,
          padding: edgeInsetsL12R12,
          itemCount: widget.models.length,
          itemBuilder: (context, index) {
            return ThreadVisitHistoryCard(widget.models[index]);
          },
          separatorBuilder: (_, __) => sizedBoxW4H4,
        );
      },
    );
  }
}
