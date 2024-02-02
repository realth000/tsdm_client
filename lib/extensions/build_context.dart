import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:url_launcher/url_launcher.dart';

/// Extension on [BuildContext] that provides ability to dispatch a [String]
/// as an url.
extension DispatchUrl on BuildContext {
  /// If [url] is an valid url:
  /// * Try parse route and push route to the corresponding page.
  /// * If is unrecognized route, launch url in external browser.
  ///
  /// If current string is not an valid url:
  /// * Do nothing.
  Future<void> dispatchAsUrl(String url, {bool external = false}) async {
    final u = Uri.tryParse(url);
    if (u == null) {
      // Do nothing if is invalid url.
      return;
    }
    if (external) {
      await launchUrl(u, mode: LaunchMode.externalApplication);
      return;
    }
    final route = url.parseUrlToRoute();
    if (route != null) {
      // Push route to the page if is recognized route.
      await pushNamed(
        route.screenPath,
        pathParameters: route.pathParameters,
        queryParameters: route.queryParameters,
      );
      return;
    }
    // Launch in external browser if is unsupported url.
    await launchUrl(u, mode: LaunchMode.externalApplication);
  }
}

/// Extension on [BuildContext] provides methods to access the widget tree.
extension AccessContext on BuildContext {
  /// Try to read the bloc type [T] on context.
  ///
  /// * Return [T] if bloc found.
  /// * Return null if bloc not found.
  T? readOrNull<T>() {
    try {
      return read<T>();
    } catch (e) {
      return null;
    }
  }
}
