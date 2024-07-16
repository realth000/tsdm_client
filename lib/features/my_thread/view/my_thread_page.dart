import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/features/my_thread/bloc/my_thread_bloc.dart';
import 'package:tsdm_client/features/my_thread/repository/my_thread_repository.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/widgets/card/thread_card/thread_card.dart';

/// Page to show the threads and replies published by current logged user.
class MyThreadPage extends StatefulWidget {
  /// Constructor.
  const MyThreadPage({super.key});

  @override
  State<MyThreadPage> createState() => _MyThreadPageState();
}

class _MyThreadPageState extends State<MyThreadPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  late final EasyRefreshController _threadRefreshController;
  late final EasyRefreshController _replyRefreshController;

  Widget _buildThreadTab(BuildContext context, MyThreadState state) {
    if (state.status == MyThreadStatus.loading || state.refreshingThread) {
      return const Center(child: CircularProgressIndicator());
    }
    _threadRefreshController
      ..finishRefresh()
      ..finishLoad();
    return Padding(
      padding: edgeInsetsL10T5R10B20,
      child: EasyRefresh(
        controller: _threadRefreshController,
        header: const MaterialHeader(),
        footer: const MaterialFooter(),
        onRefresh: () async {
          context.read<MyThreadBloc>().add(MyThreadRefreshThreadRequested());
        },
        onLoad: () async {
          if (state.nextThreadPageUrl == null) {
            _threadRefreshController.finishLoad(IndicatorResult.noMore);
            return;
          }
          context
              .read<MyThreadBloc>()
              .add(const MyThreadLoadMoreThreadRequested());
        },
        child: ListView.separated(
          itemCount: state.threadList.length,
          itemBuilder: (context, index) {
            return MyThreadCard(state.threadList[index]);
          },
          separatorBuilder: (context, index) => sizedBoxW5H5,
        ),
      ),
    );
  }

  Widget _buildReplyTab(BuildContext context, MyThreadState state) {
    if (state.status == MyThreadStatus.loading || state.refreshingReply) {
      return const Center(child: CircularProgressIndicator());
    }
    _replyRefreshController
      ..finishRefresh()
      ..finishLoad();
    return Padding(
      padding: edgeInsetsL10T5R10B20,
      child: EasyRefresh(
        controller: _replyRefreshController,
        header: const MaterialHeader(),
        footer: const MaterialFooter(),
        onRefresh: () async {
          context.read<MyThreadBloc>().add(MyThreadRefreshReplyRequested());
        },
        onLoad: () async {
          if (state.nextReplyPageUrl == null) {
            _replyRefreshController.finishLoad(IndicatorResult.noMore);
            return;
          }
          context
              .read<MyThreadBloc>()
              .add(const MyThreadLoadMoreReplyRequested());
        },
        child: ListView.separated(
          itemCount: state.replyList.length,
          itemBuilder: (context, index) {
            return MyThreadCard(state.replyList[index]);
          },
          separatorBuilder: (context, index) => sizedBoxW5H5,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _threadRefreshController = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );
    _replyRefreshController = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _threadRefreshController.dispose();
    _replyRefreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        RepositoryProvider(
          create: (_) => MyThreadRepository(),
        ),
        BlocProvider(
          create: (context) =>
              MyThreadBloc(myThreadRepository: RepositoryProvider.of(context))
                ..add(MyThreadLoadInitialDataRequested()),
        ),
      ],
      child: BlocBuilder<MyThreadBloc, MyThreadState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(context.t.myThreadPage.title),
              bottom: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(child: Text(context.t.myThreadPage.threadTab.title)),
                  Tab(child: Text(context.t.myThreadPage.replyTab.title)),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildThreadTab(context, state),
                _buildReplyTab(context, state),
              ],
            ),
          );
        },
      ),
    );
  }
}
