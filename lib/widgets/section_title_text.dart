import 'package:flutter/material.dart';
import 'package:tsdm_client/constants/layout.dart';

/// Text used as a title of section.
class SectionTitleText extends StatelessWidget {
  /// Constructor.
  const SectionTitleText(
    this.data, {
    super.key,
  });

  /// Title text.
  final String data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: edgeInsetsL18R18,
      child: Text(
        data,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
