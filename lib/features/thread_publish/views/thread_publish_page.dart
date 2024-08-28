import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/features/thread_publish/bloc/thread_publish_bloc.dart';
import 'package:tsdm_client/features/thread_publish/repository/thread_pub_repository.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/utils/show_toast.dart';
import 'package:tsdm_client/widgets/list_app_bar.dart';

/// Page to publish new thread.
///
/// Similar to post edit page, especially when editing the first floor, but
/// only for posting thread. Also contains some options that can only set before
/// thread published, though not supported yet due to permission requirements
/// - not useful as other options.
///
/// Content in this page can be finished in four states:
///
/// * Publish as new thread.
/// * Save as draft. Send data to server and thread content will save in user
///   draft box, where can be found or edit later.
/// * Discard changes. All content will be lost and no longer restore.
class ThreadPublishPage extends StatefulWidget {
  /// Constructor.
  const ThreadPublishPage({required this.fid, super.key});

  /// Id of forum to post thread at.
  final String fid;

  @override
  State<ThreadPublishPage> createState() => _ThreadPublishPageState();
}

class _ThreadPublishPageState extends State<ThreadPublishPage> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        RepositoryProvider(create: (_) => const ThreadPubRepository()),
        BlocProvider(
          create: (context) => ThreadPubBloc(RepositoryProvider.of(context)),
        ),
      ],
      child: BlocListener<ThreadPubBloc, ThreadPubState>(
        listener: (context, state) {
          if (state.status == ThreadPubStatus.failure) {
            showFailedToLoadSnackBar(context);
          }
        },
        child: BlocBuilder(
          builder: (context, state) {
            // TODO: Page body.
            return Scaffold(
              appBar: ListAppBar(
                title: context.t.threadPublishPage.title,
                onSearch: () async {
                  await context.pushNamed(
                    ScreenPaths.search,
                    queryParameters: {'fid': widget.fid},
                  );
                },
              ),
              body: Center(child: Text('FID=${widget.fid}')),
            );
          },
        ),
      ),
    );
  }
}
