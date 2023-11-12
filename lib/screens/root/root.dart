import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/providers/root_content_provider.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/screens/root/auto_redirect_dialog.dart';
import 'package:tsdm_client/widgets/root_scaffold.dart';

class RootPage extends ConsumerWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rootContent = ref.watch(rootContentProvider);
    return rootContent.when(
      data: (_) {
        return AutoRedirectDialog(
          duration: const Duration(milliseconds: 500),
          child: RootScaffold(
            child: Center(
              child: Text(context.t.rootPage.initFinished),
            ),
          ),
          callback: () => context.go(ScreenPaths.homepage),
        );
      },
      error: (err, _) {
        return RootScaffold(
          child: Center(
            child: Text(context.t.rootPage.initFailed(err: err)),
          ),
        );
      },
      loading: () {
        return RootScaffold(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 500,
                maxHeight: 500,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  sizedBoxW20H20,
                  Text(context.t.rootPage.initializingData),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
