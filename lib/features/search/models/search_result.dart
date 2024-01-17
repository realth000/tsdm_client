import 'package:equatable/equatable.dart';
import 'package:tsdm_client/features/search/models/searched_thread.dart';

/// Result of a search action.
class SearchResult extends Equatable {
  const SearchResult({
    required this.currentPage,
    required this.totalPages,
    required this.count,
    required this.data,
  });

  const SearchResult.empty()
      : currentPage = 0,
        totalPages = 0,
        count = 0,
        data = null;

  /// Current search result page number.
  final int currentPage;

  /// Total search result page numbers.
  final int totalPages;

  /// Search result count;
  final int? count;

  /// Thread list.
  final List<SearchedThread>? data;

  bool isValid() {
    return currentPage > 0 && totalPages > 0 && currentPage <= totalPages;
  }

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
