import 'package:flutter/material.dart';
import 'package:tsdm_client/features/root/models/models.dart';
import 'package:tsdm_client/features/root/stream/root_location_stream.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:tsdm_client/utils/method_channel.dart';
import 'package:tsdm_client/utils/platform.dart';
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
    if ([ScreenPaths.homepage, ScreenPaths.topic, ScreenPaths.settings.fullPath].contains(widget.path)) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (isAndroid) {
            final exitResult = await androidExitApp();
            debug('exit android app, result=$exitResult');
            return;
          }

          await exitApp();
          // Unreachable
          return;
        },

        child: widget.child,
      );
    }

    return widget.child;
  }
}
