import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/screens/homepage/pin_section.dart';
import 'package:tsdm_client/screens/homepage/welcome_section.dart';

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
    return Scrollbar(
      controller: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: const Padding(
          padding: EdgeInsets.all(5),
          child: Column(
            children: [
              WelcomeSection(),
              PinSection(),
            ],
          ),
        ),
      ),
    );
  }
}
