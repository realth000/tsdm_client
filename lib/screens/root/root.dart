import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/providers/root_content_provider.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/screens/root/auto_redirect_dialog.dart';

class RootPage extends ConsumerWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rootContent = ref.watch(rootContentProvider);
    return rootContent.when(
      data: (_) {
        return AutoRedirectDialog(
          duration: const Duration(milliseconds: 500),
          child: Center(
            child: Text(t.rootPage.initFinished),
          ),
          callback: () => context.go(ScreenPaths.homepage),
        );
      },
      error: (err, _) {
        return Center(
          child: Text(t.rootPage.initFailed(err: err)),
        );
      },
      loading: () {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 500,
              maxHeight: 500,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(
                  width: 20,
                  height: 20,
                ),
                Text(t.rootPage.initializingData),
              ],
            ),
          ),
        );
      },
    );
  }
}
