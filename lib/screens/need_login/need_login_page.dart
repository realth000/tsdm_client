import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/providers/redirect_provider.dart';
import 'package:tsdm_client/routes/screen_paths.dart';

/// A page to show need to login hint.
///
/// This page can be used by:
/// 1. Pushing route to [ScreenPaths.needLogin], with redirect back, route,
/// parameters and extra info saved in [redirectProvider].
/// 2. Embedded in another page, pass the redirect back route, parameters and
/// extra info to constructor.
///
/// When using like 1., will `pushNamed` back.
/// When using like 2., will `pushReplacementNamed` back.
class NeedLoginPage extends ConsumerWidget {
  const NeedLoginPage({
    this.backRoute,
    this.parameters = const <String, String>{},
    this.extra,
    super.key,
  });

  final String? backRoute;
  final Map<String, String> parameters;
  final Object? extra;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(context.t.general.needLoginToSeeThisPage),
            sizedBoxW10H10,
            ElevatedButton(
              child: Text(t.loginPage.login),
              onPressed: () async {
                await context.pushNamed(ScreenPaths.login);
                if (!context.mounted) {
                  return;
                }
                if (backRoute != null) {
                  // Embedded in another page, push to that.
                  // NOTE: Because this page is embedded, do not use
                  // `pushReplacementNamed`, it will throw an error, maybe it is
                  // a bug in go_router, though `pushNamed` may cause duplicate
                  // routes in stack.
                  await context.pushNamed(
                    backRoute!,
                    pathParameters: parameters,
                    extra: extra,
                  );
                  return;
                }

                // Use as an entire page.
                // Redirect back according to info in `redirectProvider`.
                final r = ref.read(redirectProvider);
                if (r.backRoute != null) {
                  await context.pushNamed(
                    r.backRoute!,
                    pathParameters: r.parameters,
                    extra: r.extra,
                  );
                  return;
                }
                context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
