import 'package:flutter/material.dart';
import 'package:tsdm_client/features/root/models/models.dart';
import 'package:tsdm_client/features/root/stream/root_location_stream.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:tsdm_client/widgets/shutdown.dart';

/// A top-level wrapper page for showing messages or provide functionalities to
/// all pages across the app.
class RootPage extends StatefulWidget {
  /// Constructor.
  const RootPage(this.path, this.child, {super.key});

  /// Current screen path.
  final String path;

  /// Content widget.
  final Widget child;

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> with LoggerMixin {
  @override
  void initState() {
    super.initState();
    rootLocationStream.add(RootLocationEventEnter(widget.path));
  }

  @override
  Widget build(BuildContext context) {
    return BackButtonListener(
      onBackButtonPressed: () async {
        // App wide popping events interceptor, handles all popping events and notify the listener above.
        rootLocationStream.add(const RootLocationEventLeavingLast());
        if (!context.mounted) {
          // Well, leave it here.
          await exitApp();
          return true;
        }
        return true;
      },
      child: widget.child,
    );
  }
}
