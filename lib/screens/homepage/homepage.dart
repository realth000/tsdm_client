import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/providers/auth_provider.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/screens/homepage/pin_section.dart';
import 'package:tsdm_client/screens/homepage/welcome_section.dart';
import 'package:tsdm_client/screens/need_login/need_login_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.read(authProvider);
    if (authState != AuthState.authorized) {
      // Embed NeedLoginPage with redirect back route.
      return const NeedLoginPage(backRoute: ScreenPaths.homepage);
    }

    return Scaffold(
      appBar: AppBar(title: Text(context.t.navigation.homepage)),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: const Padding(
          padding: edgeInsetsL10T5R10B20,
          child: Column(
            children: [
              // TODO: Optimize layout build jank.
              // TODO: Optimize page when not login (no cookie or cookie invalid).
              WelcomeSection(),
              sizedBoxW20H20,
              PinSection(),
            ],
          ),
        ),
      ),
    );
  }
}
