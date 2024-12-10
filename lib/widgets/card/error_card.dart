import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/list.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_error_saver.dart';

/// Show error and retry.
class ErrorCard extends StatelessWidget {
  /// Constructor.
  const ErrorCard({required this.child, this.message, super.key});

  /// Extra optional error message.
  final String? message;

  /// Child widget to interact.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final windowWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = math.min<double>(windowWidth * 2 / 3, 500);
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: cardWidth),
        child: Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: edgeInsetsL12T12R12B12,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_outlined,
                  size: math.min(cardWidth - 12 - 12, 80),
                  color: Theme.of(context).colorScheme.error,
                ),
                Text(
                  message ??
                      getIt.get<NetErrorSaver>().error() ??
                      context.t.general.failedToLoad,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
                Center(child: child),
              ].insertBetween(sizedBoxW24H24),
            ),
          ),
        ),
      ),
    );
  }
}
