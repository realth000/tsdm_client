import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/widgets/list_app_bar.dart';

import '../../../routes/screen_paths.dart';

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
    return Scaffold(
      appBar: ListAppBar(
        title: 'publish new thread',
        onSearch: () async {
          await context.pushNamed(
            ScreenPaths.search,
            queryParameters: {'fid': widget.fid},
          );
        },
      ),
      body: Center(child: Text('FID=${widget.fid}')),
    );
  }
}
