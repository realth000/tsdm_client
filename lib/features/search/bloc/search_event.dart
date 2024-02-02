part of 'search_bloc.dart';

/// Event of search.
sealed class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

/// User requested a search action.
final class SearchRequested extends SearchEvent {
  /// Constructor.
  const SearchRequested({
    required this.keyword,
    required this.fid,
    required this.uid,
    required this.pageNumer,
  }) : super();

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

  @override
  List<Object?> get props => [keyword, fid, uid, pageNumer];
}

/// User requested to jump to another page [pageNumber].
final class SearchJumpPageRequested extends SearchEvent {
  /// Constructor.
  const SearchJumpPageRequested(this.pageNumber) : super();

  /// Page number to jump to.
  final int pageNumber;
}

/// User requested to jump to the next page.
final class SearchGotoNextPageRequested extends SearchEvent {}

/// User requested to jump to the previous page.
final class SearchGotoPreviousPageRequested extends SearchEvent {}
