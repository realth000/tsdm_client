import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/features/latest_thread/bloc/latest_thread_bloc.dart';
import 'package:tsdm_client/features/latest_thread/repository/latest_thread_repository.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/utils/retry_snackbar_button.dart';
import 'package:tsdm_client/widgets/card/thread_card.dart';

class LatestThreadPage extends StatefulWidget {
  const LatestThreadPage({required this.url, super.key});

  final String url;

  @override
  State<LatestThreadPage> createState() => _LatestThreadPageState();
}

class _LatestThreadPageState extends State<LatestThreadPage> {
  late final EasyRefreshController _refreshController;

  Widget _buildBody(BuildContext context, LatestThreadState state) {
    _refreshController
      ..finishRefresh()
      ..finishLoad();

    return Padding(
      padding: edgeInsetsL10T5R10B20,
      child: EasyRefresh(
        controller: _refreshController,
        header: const MaterialHeader(),
        footer: const MaterialFooter(),
        onRefresh: () async {
          context
              .read<LatestThreadBloc>()
              .add(LatestThreadRefreshRequested(widget.url));
        },
        onLoad: () async {
          if (state.nextPageUrl == null) {
            _refreshController.finishLoad(IndicatorResult.noMore);
            return;
          }
          context.read<LatestThreadBloc>().add(LatestThreadLoadMoreRequested());
        },
        child: ListView.separated(
          itemCount: state.threadList.length,
          itemBuilder: (context, index) {
            return LatestThreadCard(state.threadList[index]);
          },
          separatorBuilder: (context, index) => sizedBoxW5H5,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _refreshController = EasyRefreshController(
        controlFinishLoad: true, controlFinishRefresh: true);
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        RepositoryProvider(
          create: (_) => LatestThreadRepository(),
        ),
        BlocProvider(
          create: (context) => LatestThreadBloc(
              latestThreadRepository: RepositoryProvider.of(context))
            ..add(LatestThreadRefreshRequested(widget.url)),
        )
      ],
      child: BlocBuilder<LatestThreadBloc, LatestThreadState>(
        builder: (context, state) {
          final body = switch (state.status) {
            LatestThreadStatus.initial ||
            LatestThreadStatus.loading =>
              const Center(child: CircularProgressIndicator()),
            LatestThreadStatus.failed => buildRetrySnackbarButton(context, () {
                context
                    .read<LatestThreadBloc>()
                    .add(LatestThreadRefreshRequested(widget.url));
              }),
            LatestThreadStatus.success => _buildBody(context, state),
          };

          return Scaffold(
            appBar: AppBar(title: Text(context.t.latestThreadPage.title)),
            body: body,
          );
        },
      ),
    );
  }
}
