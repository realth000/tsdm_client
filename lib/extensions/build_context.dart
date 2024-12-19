import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/extensions/map.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/instance.dart';
import 'package:url_launcher/url_launcher.dart';

/// Extension on [BuildContext] that provides ability to dispatch a [String]
/// as an url.
extension DispatchUrl<T> on BuildContext {
  /// If [url] is an valid url:
  /// * Try parse route and push route to the corresponding page.
  /// * If is unrecognized route, launch url in external browser.
  ///
  /// If current string is not an valid url:
  /// * Do nothing.
  Future<T?> dispatchAsUrl(
    String url, {
    bool external = false,
    Map<String, String>? extraPathParameters,
    Map<String, String>? extraQueryParameters,
  }) async {
    talker.debug('dispatch url: $url');
    final u = Uri.tryParse(url);
    if (u == null) {
      // Do nothing if is invalid url.
      talker.error('failed to dispatch invalid url: $url ');
      return null;
    }
    if (external) {
      await launchUrl(u, mode: LaunchMode.externalApplication);
      return null;
    }
    final route = url.parseUrlToRoute();
    if (route != null) {
      // Push route to the page if is recognized route.
      return pushNamed<T>(
        route.screenPath,
        pathParameters: route.pathParameters.copyWith(
          extraPathParameters ?? {},
        ),
        queryParameters: route.queryParameters.copyWith(
          extraPathParameters ?? {},
        ),
      );
    }
    // Launch in external browser if is unsupported url.
    await launchUrl(u, mode: LaunchMode.externalApplication);
    return null;
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
      // This catch clause intends to be a safe accessor on providers.
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      return null;
    }
  }

  /// Get the repository on current context.
  T repo<T>() => RepositoryProvider.of<T>(this);
}
