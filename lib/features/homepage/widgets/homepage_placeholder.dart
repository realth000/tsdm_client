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
        Align(
          child: Card(
            margin: EdgeInsets.zero,
            child: ConstrainedBox(constraints: const BoxConstraints(maxHeight: _kahrpbaPicHeight), child: Container()),
          ),
        ),
        sizedBoxW4H4,
        const Row(children: [Flexible(flex: 2, child: sizedH60Shimmer), Flexible(flex: 3, child: SizedBox.shrink())]),
        const Align(child: sizedH40Shimmer),
        const Align(child: sizedH40Shimmer),
        const Align(child: sizedH40Shimmer),
        const Align(child: sizedH40Shimmer),
        sizedBoxW4H4,
        const Row(children: [Flexible(flex: 2, child: sizedH60Shimmer), Flexible(flex: 3, child: SizedBox.shrink())]),
        const Align(child: sizedH40Shimmer),
        const Align(child: sizedH40Shimmer),
        const Align(child: sizedH40Shimmer),
        const Align(child: sizedH40Shimmer),
      ].insertBetween(sizedBoxW4H4),
    );
  }
}
