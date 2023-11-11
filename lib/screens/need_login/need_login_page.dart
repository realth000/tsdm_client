import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/routes/screen_paths.dart';

class NeedLoginPage extends ConsumerWidget {
  const NeedLoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(context.t.general.needLoginToSeeThisPage),
            const SizedBox(width: 10, height: 10),
            ElevatedButton(
              child: Text(t.loginPage.login),
              onPressed: () async {
                await context.pushNamed(ScreenPaths.login);
              },
            ),
          ],
        ),
      ),
    );
  }
}
