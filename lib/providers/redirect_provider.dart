import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '../generated/providers/redirect_provider.g.dart';

class RedirectBackParameters {
  RedirectBackParameters({
    this.backRoute,
    this.parameters = const <String, String>{},
    this.extra,
  }) : assert(
            // Not specified.
            (parameters.isEmpty && extra == null) ||
                // Specified.
                ((parameters.isNotEmpty || extra != null) && backRoute != null),
            'parameters or extra used, but backRoute not set');

  String? backRoute;
  Map<String, String> parameters;
  Object? extra;
}

/// Provides info about which route and what parameters to redirect back.
/// Currently only used with `NeedLoginPage`.
@Riverpod(keepAlive: true)
class Redirect extends _$Redirect {
  final _parameters = RedirectBackParameters();

  RedirectBackParameters parameters() {
    return _parameters;
  }

  @override
  RedirectBackParameters build() {
    return _parameters;
  }

  void saveRedirectState(String screenPath, GoRouterState state) {
    _parameters
      ..backRoute = screenPath
      ..parameters = state.pathParameters
      ..extra = state.extra;
  }

  void clear() {
    _parameters
      ..backRoute = null
      ..parameters = const <String, String>{}
      ..extra = null;
  }
}
