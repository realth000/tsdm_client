

extension Spacing<T> on List<T> {
  List<T> insertBetween(T item) {
    if (length < 1) {
      return this;
    }

    final ret = skip(1).fold([first], (acc, x) {
      acc
        ..add(item)
        ..add(x);
      return acc;
    }).toList();

    return ret;
  }
}
