import 'package:flutter/material.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:tsdm_client/constants/layout.dart';

/// Card to show tips with icon and text.
class TipsCard extends StatelessWidget {
  /// Constructor.
  const TipsCard({
    required this.tips,
    required this.color,
    required this.backgroundColor,
    this.height = 50,
    this.iconData = Icons.tips_and_updates_outlined,
    super.key,
  });

  /// Card height.
  final double height;

  /// Icon content.
  final IconData iconData;

  /// Tips text.
  final String tips;

  /// Color of tips text and icon.
  final Color color;

  /// The background card color.
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Card(
        margin: .zero,
        color: backgroundColor,
        child: Align(
          alignment: .centerLeft,
          child: Row(
            children: [
              sizedBoxW8H8,
              Icon(iconData, color: color),
              sizedBoxW4H4,
              Expanded(
                child: TextScroll(
                  delayBefore: const Duration(seconds: 2),
                  pauseBetween: const Duration(seconds: 2),
                  velocity: const Velocity(pixelsPerSecond: Offset(60, 0)),
                  tips,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: color),
                ),
              ),
              sizedBoxW8H8,
            ],
          ),
        ),
      ),
    );
  }
}
