part of 'models.dart';

/// Result of a search action.
@MappableClass()
class SearchResult with SearchResultMappable {
  /// Constructor.
  const SearchResult({
    required this.currentPage,
    required this.totalPages,
    required this.count,
    required this.data,
  });

  /// Current search result page number.
  final int currentPage;

  /// Total search result page numbers.
  final int totalPages;

  /// Search result count;
  final int? count;

  /// Thread list.
  final List<SearchedThread>? data;
}
