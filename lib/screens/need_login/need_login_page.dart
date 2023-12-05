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
    required this.backUri,
    this.showAppBar = false,
    this.needPop = false,
    super.key,
  });

  /// Only show app bar when using this page as an entire screen, not embedded.
  final bool showAppBar;

  /// When redirect back, use `push` or `pushReplacement`.
  final bool needPop;

  /// Router uri to redirect back after login.
  final Uri backUri;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: showAppBar ? AppBar(title: Text(context.t.appName)) : null,
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
                if (needPop) {
                  context.pushReplacement(
                    backUri.toString(),
                  );
                } else {
                  await context.push(
                    backUri.toString(),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
