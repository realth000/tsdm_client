import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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
          child: const Center(
            child: Text('Init finished'),
          ),
          callback: () => context.go(ScreenPaths.homepage),
        );
      },
      error: (err, _) {
        return Center(
          child: Text('init failed: $err'),
        );
      },
      loading: () {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 500,
              maxHeight: 500,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(
                  width: 20,
                  height: 20,
                ),
                Text('Initializing data'),
              ],
            ),
          ),
        );
      },
    );
  }
}
