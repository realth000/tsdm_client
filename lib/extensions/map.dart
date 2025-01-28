/// Extension on [Map] that provides methods about modification.
extension ModifyMap<K, V> on Map<K, V> {
  /// Return a new map that copies current map and [other] together.
  Map<K, V> copyWith(Map<K, V> other) {
    final ret = Map<K, V>.from(this);
    for (final i in other.entries) {
      ret[i.key] = i.value;
    }
    return ret;
  }
}
