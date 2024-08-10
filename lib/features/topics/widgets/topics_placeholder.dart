import 'package:flutter/material.dart';
import 'package:tsdm_client/constants/layout.dart';

/// Placeholder widget for topics page.
class TopicsPlaceholder extends StatelessWidget {
  /// Constructor.
  const TopicsPlaceholder({super.key});

  List<Widget> _buildThreadPlaceholder(BuildContext context) {
    return [
      const Row(
        children: [
          Expanded(
            child: Row(
              children: [
                sizedW120H40Shimmer,
                sizedBoxW12H12,
                sizedW80H40Shimmer,
              ],
            ),
          ),
        ],
      ),
      sizedBoxW24H24,
      const Row(children: [Expanded(child: sizedH40Shimmer)]),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: edgeInsetsL12T4R12,
      children: <Widget>[
        sizedH40Shimmer,
        sizedBoxW24H24,
        ..._buildThreadPlaceholder(context),
        sizedBoxW12H12,
        ..._buildThreadPlaceholder(context),
        sizedBoxW12H12,
        ..._buildThreadPlaceholder(context),
        sizedBoxW12H12,
        ..._buildThreadPlaceholder(context),
      ],
    );
  }
}
