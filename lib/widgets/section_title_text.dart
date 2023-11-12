import 'package:flutter/material.dart';
import 'package:tsdm_client/constants/layout.dart';

class SectionTitleText extends StatelessWidget {
  const SectionTitleText(
    this.data, {
    super.key,
  });

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
