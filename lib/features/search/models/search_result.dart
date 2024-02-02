import 'package:equatable/equatable.dart';
import 'package:tsdm_client/features/search/models/searched_thread.dart';

/// Result of a search action.
class SearchResult extends Equatable {
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

  @override
  String toString() {
    final dataString = data?.map((e) => e.toString()).join('\n    ');
    return '''
SearchResult{
  currentPage=$currentPage,
  totalPage=$totalPages,
  count=$count,
  data=
    $dataString
}
''';
  }

  @override
  List<Object?> get props => [currentPage, totalPages, count, data];
}
