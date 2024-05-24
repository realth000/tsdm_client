part of 'widgets.dart';

/// Placeholder widget for the page.
class HomepagePlaceholder extends StatelessWidget {
  /// Constructor.
  const HomepagePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: edgeInsetsL10T5R10,
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
        sizedBoxW5H5,
        const Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  CircleAvatar(),
                  sizedBoxW10H10,
                  Expanded(child: sizedH20Shimmer),
                ],
              ),
            ),
          ],
        ),
        const Row(children: [Expanded(child: sizedH40Shimmer)]),
        const Row(children: [Expanded(child: sizedH40Shimmer)]),
        sizedBoxW5H5,
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
        sizedBoxW5H5,
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
      ].insertBetween(sizedBoxW5H5),
    );
  }
}
