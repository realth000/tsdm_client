/// Extension on [List] that provides spacing modification.
extension Spacing<T> on List<T> {
  /// Insert [item] between every two neighbor items.
  ///
  /// Do nothing if only have one item.
  List<T> insertBetween(T item) {
    if (length < 1) {
      return this;
    }

    final ret =
        skip(1).fold([first], (acc, x) {
          acc
            ..add(item)
            ..add(x);
          return acc;
        }).toList();

    return ret;
  }

  /// Prepend [item] in front of this.
  List<T> prepend(T item) {
    return [item, ...this];
  }
}
