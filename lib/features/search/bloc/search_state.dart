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
class SearchState extends Equatable {
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

  /// Copy with.
  SearchState copyWith({
    SearchStatus? status,
    String? keyword,
    String? fid,
    String? uid,
    int? pageNumber,
    bool? hasPreviousPage,
    bool? hasNextPage,
    SearchResult? searchResult,
  }) {
    return SearchState(
      status: status ?? this.status,
      keyword: keyword ?? this.keyword,
      fid: fid ?? this.fid,
      uid: uid ?? this.uid,
      searchResult: searchResult ?? this.searchResult,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      hasPreviousPage: hasPreviousPage ?? this.hasPreviousPage,
      pageNumber: pageNumber ?? this.pageNumber,
    );
  }

  @override
  List<Object?> get props => [
        status,
        keyword,
        fid,
        uid,
        searchResult,
        hasNextPage,
        hasPreviousPage,
        pageNumber,
      ];
}
