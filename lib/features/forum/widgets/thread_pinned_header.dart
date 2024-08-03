import 'package:flutter/material.dart';

/// Sliver delegate for thread filter row.
///
/// Pinned in sliver list.
class ThreadPinnedHeader extends SliverPersistentHeaderDelegate {
  /// Constructor.
  ThreadPinnedHeader({
    required this.height,
    required this.child,
  });

  /// Inner pinned child widget.
  final Widget child;

  /// Max height.
  final double height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: child,
    );
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
