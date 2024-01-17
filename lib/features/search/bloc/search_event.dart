part of 'search_bloc.dart';

sealed class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

/// User requested a search action.
final class SearchRequested extends SearchEvent {
  const SearchRequested({
    required this.keyword,
    required this.fid,
    required this.uid,
    required this.pageNumer,
  }) : super();

  final String keyword;
  final String fid;
  final String uid;
  final int pageNumer;

  @override
  List<Object?> get props => [keyword, fid, uid, pageNumer];
}

/// User requested to jump to another page [pageNumber].
final class SearchJumpPageRequested extends SearchEvent {
  const SearchJumpPageRequested(this.pageNumber) : super();
  final int pageNumber;
}

/// User requested to jump to the next page.
final class SearchGotoNextPageRequested extends SearchEvent {}

/// User requested to jump to the previous page.
final class SearchGotoPreviousPageRequested extends SearchEvent {}
