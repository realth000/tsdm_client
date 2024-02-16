import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/list.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';

/// Widget showing a bounty info in thread.
class BountyCard extends StatelessWidget {
  /// Constructor.
  const BountyCard({required this.resolved, required this.price, super.key});

  /// Flag indicating the bounty state.
  ///
  /// Is resolved or not.
  final bool resolved;

  /// Price of this bounty.
  final String price;

  @override
  Widget build(BuildContext context) {
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final tertiaryColor = Theme.of(context).colorScheme.tertiary;
    final bountyStatusTextStyle =
        Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: tertiaryColor,
            );
    final bountyStatusTextResolvedStyle =
        Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: secondaryColor,
            );

    // Bounty status.
    late final Widget bountyStatusWidget;
    if (resolved) {
      bountyStatusWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.done, color: secondaryColor),
          sizedBoxW5H5,
          Text(
            context.t.bountyCard.resolved,
            style: bountyStatusTextResolvedStyle,
          ),
        ],
      );
    } else {
      bountyStatusWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.pending, color: tertiaryColor),
          sizedBoxW5H5,
          Text(context.t.bountyCard.processing, style: bountyStatusTextStyle),
        ],
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: edgeInsetsL15T15R15B15,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 100),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.t.bountyCard.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: secondaryColor,
                        ),
                  ),
                  sizedBoxW20H20,
                  bountyStatusWidget,
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    FontAwesomeIcons.coins,
                    size: 20,
                  ),
                  sizedBoxW5H5,
                  Text(
                    context.t.bountyCard.price(price: price),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ].insertBetween(sizedBoxW10H10),
          ),
        ),
      ),
    );
  }
}
