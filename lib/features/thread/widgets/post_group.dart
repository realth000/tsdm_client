import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';

const _headerHeight = 30.0;

/// Delegate for building a header of a post group in post list.
class PostGroupHeaderDelegate extends SliverPersistentHeaderDelegate {
  /// Constructor.
  const PostGroupHeaderDelegate({required this.groupIndex});

  /// Group index name.
  final String groupIndex;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      alignment: Alignment.centerLeft,
      color: Theme.of(context).colorScheme.outlineVariant.darken(),
      padding: const EdgeInsets.only(left: 20),
      height: _headerHeight,
      child: Text(context.t.general.pageIndex(index: groupIndex)),
    );
  }

  @override
  double get maxExtent => _headerHeight;

  @override
  double get minExtent => _headerHeight;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
