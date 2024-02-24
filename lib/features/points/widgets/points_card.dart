import 'package:flutter/material.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/features/points/models/models.dart';

/// A card to a change event of user's points.
class PointsChangeCard extends StatelessWidget {
  /// Constructor.
  const PointsChangeCard(this.pointsChange, {super.key});

  /// Model of points change event.
  final PointsChange pointsChange;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: pointsChange.redirectUrl == null
            ? null
            : () async {
                await context.dispatchAsUrl(pointsChange.redirectUrl!);
              },
        child: Padding(
          padding: edgeInsetsL10R10B10,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: switch (pointsChange.pointsChangeType) {
                  PointsChangeType.more => const Icon(
                      Icons.trending_up_outlined,
                      color: Color(0xF26C4F00),
                    ),
                  PointsChangeType.less => const Icon(
                      Icons.trending_down_outlined,
                      color: Color(0x99999999),
                    ),
                  PointsChangeType.unlimited =>
                    const Icon(Icons.trending_flat_outlined),
                },
                title: Text(pointsChange.operation),
                subtitle: Text(pointsChange.changeMapString),
              ),
              Text(pointsChange.detail),
            ],
          ),
        ),
      ),
    );
  }
}
