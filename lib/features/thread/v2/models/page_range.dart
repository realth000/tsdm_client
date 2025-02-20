part of 'models.dart';

/// Describe a continuous range of page.
@MappableClass()
final class PageRange with PageRangeMappable {
  /// Constructor.
  const PageRange({required this.start, required this.end});

  /// Start page number of the range.
  final int start;

  /// End page number of the range.
  final int end;

  /// Check if current [start] less than [start] in [other].
  ///
  /// A safety check on whether [other] can expand on the left side if current
  /// [start] is the boundary.
  bool startLessThan(PageRange other) => start < other.start;

  /// Check if current [end] greater than [end] in [other].
  ///
  /// A safety check on whether [other] can expand on the right side if current
  /// [end] is the boundary.
  bool endGreaterThan(PageRange other) => end > other.end;

  /// Check if has previous pages.
  bool hasPrevious() => start > 1;

  /// Check if has next pages.
  bool hasNext(PageRange other) => other.endGreaterThan(this);
}
