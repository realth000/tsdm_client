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
                sizedBoxW10H10,
                sizedW80H40Shimmer,
              ],
            ),
          ),
        ],
      ),
      sizedBoxW20H20,
      const Row(children: [Expanded(child: sizedH40Shimmer)]),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: edgeInsetsL10T5R10,
      children: <Widget>[
        sizedH40Shimmer,
        sizedBoxW20H20,
        ..._buildThreadPlaceholder(context),
        sizedBoxW10H10,
        ..._buildThreadPlaceholder(context),
        sizedBoxW10H10,
        ..._buildThreadPlaceholder(context),
        sizedBoxW10H10,
        ..._buildThreadPlaceholder(context),
      ],
    );
  }
}
