part of 'search_bloc.dart';

/// Status of search.
enum SearchStatus {
  /// Initial.
  initial,

  /// Loading.
  loading,

  /// Load succeed.
  success,

  /// Load failed.
  failed;

  /// Is in searching.
  bool isSearching() => this == SearchStatus.loading;
}

/// State of search page.
@MappableClass()
class SearchState with SearchStateMappable {
  /// Constructor.
  const SearchState({
    this.status = SearchStatus.initial,
    this.keyword,
    this.fid = '0',
    this.uid = '0',
    this.searchResult,
    this.pageNumber = 1,
    this.hasNextPage = false,
    this.hasPreviousPage = false,
  });

  /// Status.
  final SearchStatus status;

  /// Search keyword;
  final String? keyword;

  /// Search in which forum;
  final String fid;

  /// Search for which user.
  final String uid;

  /// Current search page number.
  final int pageNumber;

  /// Flag indicating have a previous page to jump to or not.
  final bool hasPreviousPage;

  /// Flag indicating have a next page to jump to or not.
  final bool hasNextPage;

  /// Search result.
  final SearchResult? searchResult;
}
