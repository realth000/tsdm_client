import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tsdm_client/constants/constants.dart';
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
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: min(
            MediaQuery.of(context).size.width * 2 / 3,
            500,
          ),
        ),
        child: Card(
          child: Padding(
            padding: edgeInsetsL12T12R12B12,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: Image.asset(assetErrorImagePath),
                ),
                Text(
                  message ??
                      getIt.get<NetErrorSaver>().error() ??
                      context.t.general.failedToLoad,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
                Row(
                  children: [
                    sizedBoxW24H24,
                    Expanded(child: child),
                    sizedBoxW24H24,
                  ],
                ),
              ].insertBetween(sizedBoxW24H24),
            ),
          ),
        ),
      ),
    );
  }
}
