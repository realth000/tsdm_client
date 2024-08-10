part of 'widgets.dart';

/// Placeholder widget for the page.
class HomepagePlaceholder extends StatelessWidget {
  /// Constructor.
  const HomepagePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: edgeInsetsL12T4R12,
      children: <Widget>[
        Row(
          children: [
            Expanded(
              child: Card(
                margin: EdgeInsets.zero,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: _kahrpbaPicWidth,
                    maxHeight: _kahrpbaPicHeight,
                  ),
                  child: Container(),
                ),
              ),
            ),
          ],
        ),
        sizedBoxW4H4,
        const Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  CircleAvatar(),
                  sizedBoxW12H12,
                  Expanded(child: sizedH24Shimmer),
                ],
              ),
            ),
          ],
        ),
        const Row(children: [Expanded(child: sizedH40Shimmer)]),
        const Row(children: [Expanded(child: sizedH40Shimmer)]),
        sizedBoxW4H4,
        const Row(
          children: [
            Flexible(flex: 2, child: sizedH60Shimmer),
            Flexible(flex: 3, child: SizedBox.shrink()),
          ],
        ),
        const Row(children: [Expanded(child: sizedH40Shimmer)]),
        const Row(children: [Expanded(child: sizedH40Shimmer)]),
        const Row(children: [Expanded(child: sizedH40Shimmer)]),
        const Row(children: [Expanded(child: sizedH40Shimmer)]),
        sizedBoxW4H4,
        const Row(
          children: [
            Flexible(flex: 2, child: sizedH60Shimmer),
            Flexible(flex: 3, child: SizedBox.shrink()),
          ],
        ),
        const Row(children: [Expanded(child: sizedH40Shimmer)]),
        const Row(children: [Expanded(child: sizedH40Shimmer)]),
        const Row(children: [Expanded(child: sizedH40Shimmer)]),
        const Row(children: [Expanded(child: sizedH40Shimmer)]),
      ].insertBetween(sizedBoxW4H4),
    );
  }
}
