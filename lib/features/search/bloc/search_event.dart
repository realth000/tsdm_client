part of 'search_bloc.dart';

/// Event of search.
@MappableClass()
sealed class SearchEvent with SearchEventMappable {
  const SearchEvent();
}

/// User requested a search action.
@MappableClass()
final class SearchRequested extends SearchEvent with SearchRequestedMappable {
  /// Constructor.
  const SearchRequested({required this.keyword, required this.fid, required this.uid, required this.pageNumer})
    : super();

  /// Keyword to search.
  final String keyword;

  /// Forum id to search.
  ///
  /// '0' represents any forum.
  final String fid;

  /// Author's uid to search.
  ///
  /// '0' represents any published by user.
  final String uid;

  /// Page number of search result.
  final int pageNumer;
}

/// User requested to jump to another page [pageNumber].
@MappableClass()
final class SearchJumpPageRequested extends SearchEvent with SearchJumpPageRequestedMappable {
  /// Constructor.
  const SearchJumpPageRequested(this.pageNumber) : super();

  /// Page number to jump to.
  final int pageNumber;
}

/// User requested to jump to the next page.
@MappableClass()
final class SearchGotoNextPageRequested extends SearchEvent with SearchGotoNextPageRequestedMappable {}

/// User requested to jump to the previous page.
@MappableClass()
final class SearchGotoPreviousPageRequested extends SearchEvent with SearchGotoPreviousPageRequestedMappable {}
