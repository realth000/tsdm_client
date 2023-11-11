import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/providers/auth_provider.dart';
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
      return const NeedLoginPage();
    }

    return Scaffold(
      appBar: AppBar(title: Text(context.t.navigation.homepage)),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: const Padding(
          padding: EdgeInsets.only(left: 15, right: 15, bottom: 20),
          child: Column(
            children: [
              // TODO: Optimize layout build jank.
              // TODO: Optimize page when not login (no cookie or cookie invalid).
              WelcomeSection(),
              SizedBox(
                width: 20,
                height: 20,
              ),
              PinSection(),
            ],
          ),
        ),
      ),
    );
  }
}
