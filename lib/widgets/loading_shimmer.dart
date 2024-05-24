import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Widget to show a shimmer as data loading state.
class LoadingShimmer extends StatelessWidget {
  /// Constructor.
  const LoadingShimmer({required this.child, super.key});

  /// Shimmer shape widget.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
      highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      child: child,
    );
  }
}
