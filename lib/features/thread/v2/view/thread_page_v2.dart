import 'package:flutter/material.dart';

/// V2 page for each thread.
///
///
/// Find post is not supported yet.
class ThreadPageV2 extends StatefulWidget {
  /// Constructor.
  const ThreadPageV2({
    required this.id,
    required this.pageNumber,
    this.onlyVisibleUid,
    this.overrideReverseOrder = true,
    this.overrideWithExactOrder,
    this.pid,
    super.key,
  });

  /// Thread id.
  final String id;

  /// Initial page number.
  final String pageNumber;

  /// Override the original post order in thread.
  ///
  /// * If `true`, force add a `ordertype` query parameter when fetching page.
  /// * If `false`, do NOT add such param so that use the original post order.
  ///
  /// This flag is used in situation that user is heading to a certain page
  /// contains a target post. If set to `true`, override order may cause going
  /// to a wrong page.
  ///
  /// Additionally, the effect has less priority compared to
  /// [overrideWithExactOrder] where the latter one is specifying the exact
  /// order type and current field only determines using the order specified by
  /// app if has.
  final bool overrideReverseOrder;

  /// Carries the exact order required by external reasons.
  ///
  /// If value is not null, the final thread order is override by the value no
  /// matter [overrideReverseOrder] is true or false.
  ///
  /// Actually this field is a patch on is the following situation:
  ///
  /// ```console
  /// ${HOST}/...&ordertype=N
  /// ```
  ///
  /// where order type is directly specified in url before dispatching, and
  /// should override any order in app settings.
  final int? overrideWithExactOrder;

  /// Only watch the floors posted by the user with uid [onlyVisibleUid].
  final String? onlyVisibleUid;

  /// Post id as an anchor to scroll to when page loaded successfully.
  final int? pid;

  @override
  State<ThreadPageV2> createState() => _ThreadPageV2State();
}

class _ThreadPageV2State extends State<ThreadPageV2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('THREAD PAGE V2')),
      body: Center(child: Text('id=${widget.id}, page=${widget.pageNumber}')),
    );
  }
}
