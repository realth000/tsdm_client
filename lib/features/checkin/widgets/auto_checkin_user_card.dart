import 'package:flutter/material.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/shared/models/models.dart';

/// Card to show auto checkin info.
class AutoCheckinUserCard extends StatelessWidget {
  /// Constructor.
  const AutoCheckinUserCard(this.userInfo, this.message, {this.failure, super.key});

  /// User info to display.
  final UserLoginInfo userInfo;

  /// Optional message describes checkin result.
  final String? message;

  /// Flag indicating a success login or not.
  final bool? failure;

  @override
  Widget build(BuildContext context) {
    Color? backgroundColor;
    Color? foregroundColor;

    switch (failure) {
      case true:
        backgroundColor = Theme.of(context).colorScheme.errorContainer;
        foregroundColor = Theme.of(context).colorScheme.onErrorContainer;
      default:
        break;
    }

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.hardEdge,
      child: DecoratedBox(
        decoration: BoxDecoration(color: backgroundColor),
        child: Padding(
          padding: edgeInsetsL12T12R12B12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: CircleAvatar(child: Text(userInfo.username![0])),
                title: Text(userInfo.username!),
                subtitle: Text('${userInfo.uid!}'),
                contentPadding: EdgeInsets.zero,
                minVerticalPadding: 0,
                minTileHeight: 0,
              ),
              if (message != null) ...[
                sizedBoxW8H8,
                Text(message!, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: foregroundColor)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
