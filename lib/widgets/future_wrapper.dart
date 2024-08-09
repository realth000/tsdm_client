import 'package:flutter/material.dart';
import 'package:tsdm_client/constants/layout.dart';

/// Wrapper async widget builder into widget.
class FutureWrapper extends StatelessWidget {
  /// Constructor.
  const FutureWrapper(this.builder, {this.loadingBuilder, super.key});

  /// Future that build a widget and need to warp.
  final Future<Widget> builder;

  /// Optional widget builder used in loading.
  final Widget Function(BuildContext)? loadingBuilder;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: builder,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return loadingBuilder?.call(context) ?? sizedBoxEmpty;
        }
        return snapshot.data!;
      },
    );
  }
}

/// Wrapper async widget builder into sliver.
class SliverFutureWrapper extends StatelessWidget {
  /// Constructor.
  const SliverFutureWrapper(this.builder, {this.loadingBuilder, super.key});

  /// Future that build a widget and need to warp.
  final Future<Widget> builder;

  /// Optional widget builder used in loading.
  final Widget Function(BuildContext)? loadingBuilder;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
        child: FutureBuilder(
      future: builder,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return loadingBuilder?.call(context) ?? sizedBoxEmpty;
        }
        return snapshot.data!;
      },
    ));
  }
}
