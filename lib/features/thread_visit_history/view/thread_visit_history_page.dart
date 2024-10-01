import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tsdm_client/features/thread_visit_history/bloc/thread_visit_history_bloc.dart';
import 'package:tsdm_client/utils/retry_button.dart';

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
    return BlocProvider(
      create: (context) =>
          ThreadVisitHistoryBloc(RepositoryProvider.of(context))
            ..add(const ThreadVisitHistoryFetchAllRequested()),
      child: BlocBuilder<ThreadVisitHistoryBloc, ThreadVisitHistoryState>(
        builder: (context, state) {
          final body = switch (state.status) {
            ThreadVisitHistoryStatus.initial ||
            ThreadVisitHistoryStatus.loadingData =>
              const CircularProgressIndicator(),
            ThreadVisitHistoryStatus.savingData ||
            ThreadVisitHistoryStatus.success =>
              Column(
                children: state.history
                    .map(
                      (e) => Text('${e.username} ${e.threadId} ${e.visitTime}'),
                    )
                    .toList(),
              ),
            ThreadVisitHistoryStatus.failure => buildRetryButton(
                context,
                () => context
                    .read<ThreadVisitHistoryBloc>()
                    .add(const ThreadVisitHistoryFetchAllRequested()),
              ),
          };

          return Scaffold(
            appBar: AppBar(
              title: const Text('Thread Visit History'),
            ),
            body: body,
          );
        },
      ),
    );
  }
}
