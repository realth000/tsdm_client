import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:tsdm_client/features/search/models/models.dart';
import 'package:tsdm_client/features/search/repository/search_repository.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:universal_html/html.dart' as uh;

part 'search_bloc.mapper.dart';
part 'search_event.dart';

part 'search_state.dart';

/// Emitter
typedef SearchEmitter = Emitter<SearchState>;

/// Bloc of search page of the app.
class SearchBloc extends Bloc<SearchEvent, SearchState> with LoggerMixin {
  /// Constructor.
  SearchBloc({required SearchRepository searchRepository})
      : _searchRepository = searchRepository,
        super(const SearchState()) {
    on<SearchRequested>(_onSearchRequested);
    on<SearchJumpPageRequested>(_onSearchJumpPageRequested);
    on<SearchGotoNextPageRequested>(_onSearchGotoNextPageRequested);
    on<SearchGotoPreviousPageRequested>(_onSearchGotoPreviousPageRequested);
  }

  final SearchRepository _searchRepository;

  Future<void> _onSearchRequested(
    SearchRequested event,
    SearchEmitter emit,
  ) async {
    emit(
      state.copyWith(
        status: SearchStatus.loading,
        hasPreviousPage: false,
        hasNextPage: false,
      ),
    );
    try {
      final document = await _searchRepository.searchWithParameters(
        keyword: event.keyword,
        fid: event.fid,
        uid: event.uid,
        pageNumber: event.pageNumer,
      );
      final searchResult = await _parseSearchResult(document);
      emit(
        state.copyWith(
          status: SearchStatus.success,
          keyword: event.keyword,
          fid: event.fid,
          uid: event.uid,
          searchResult: searchResult,
          pageNumber: event.pageNumer,
          hasPreviousPage: searchResult.currentPage > 1,
          hasNextPage: searchResult.currentPage < searchResult.totalPages,
        ),
      );
    } on HttpRequestFailedException catch (e) {
      error('failed to search: $e');
      emit(
        state.copyWith(
          status: SearchStatus.failed,
          hasPreviousPage: false,
          hasNextPage: false,
        ),
      );
    }
  }

  Future<void> _onSearchJumpPageRequested(
    SearchJumpPageRequested event,
    SearchEmitter emit,
  ) async {
    if (state.keyword == null) {
      emit(
        state.copyWith(
          status: SearchStatus.failed,
          hasPreviousPage: false,
          hasNextPage: false,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: SearchStatus.loading,
        hasPreviousPage: false,
        hasNextPage: false,
      ),
    );
    try {
      final document = await _searchRepository.searchWithParameters(
        keyword: state.keyword!,
        fid: state.fid,
        uid: state.uid,
        pageNumber: event.pageNumber,
      );
      final searchResult = await _parseSearchResult(document);
      emit(
        state.copyWith(
          status: SearchStatus.success,
          pageNumber: event.pageNumber,
          searchResult: searchResult,
          hasPreviousPage: searchResult.currentPage > 1,
          hasNextPage: searchResult.currentPage < searchResult.totalPages,
        ),
      );
    } on HttpRequestFailedException catch (e) {
      error('failed to search: $e');
      emit(
        state.copyWith(
          status: SearchStatus.failed,
          hasPreviousPage: false,
          hasNextPage: false,
        ),
      );
    }
  }

  Future<void> _onSearchGotoNextPageRequested(
    SearchGotoNextPageRequested event,
    SearchEmitter emit,
  ) async {
    emit(
      state.copyWith(
        status: SearchStatus.loading,
        hasPreviousPage: false,
        hasNextPage: false,
      ),
    );
    try {
      final document = await _searchRepository.searchWithParameters(
        keyword: state.keyword!,
        fid: state.fid,
        uid: state.uid,
        pageNumber: state.pageNumber + 1,
      );
      final searchResult = await _parseSearchResult(document);
      emit(
        state.copyWith(
          status: SearchStatus.success,
          pageNumber: state.pageNumber + 1,
          searchResult: searchResult,
          hasPreviousPage: searchResult.currentPage > 1,
          hasNextPage: searchResult.currentPage < searchResult.totalPages,
        ),
      );
    } on HttpRequestFailedException catch (e) {
      error('failed to search: $e');
      emit(
        state.copyWith(
          status: SearchStatus.failed,
          hasPreviousPage: false,
          hasNextPage: false,
        ),
      );
    }
  }

  Future<void> _onSearchGotoPreviousPageRequested(
    SearchGotoPreviousPageRequested event,
    SearchEmitter emit,
  ) async {
    if (state.pageNumber <= 1) {
      emit(
        state.copyWith(
          status: SearchStatus.failed,
          hasPreviousPage: false,
          hasNextPage: false,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: SearchStatus.loading,
        hasPreviousPage: false,
        hasNextPage: false,
      ),
    );
    try {
      final document = await _searchRepository.searchWithParameters(
        keyword: state.keyword!,
        fid: state.fid,
        uid: state.uid,
        pageNumber: state.pageNumber - 1,
      );
      final searchResult = await _parseSearchResult(document);
      emit(
        state.copyWith(
          status: SearchStatus.success,
          pageNumber: state.pageNumber - 1,
          searchResult: searchResult,
          hasPreviousPage: searchResult.currentPage > 1,
          hasNextPage: searchResult.currentPage < searchResult.totalPages,
        ),
      );
    } on HttpRequestFailedException catch (e) {
      error('failed to search: $e');
      emit(
        state.copyWith(
          status: SearchStatus.failed,
          hasPreviousPage: false,
          hasNextPage: false,
        ),
      );
    }
  }

  Future<SearchResult> _parseSearchResult(uh.Document document) async {
    final threadList = document
        .querySelectorAll('div#ct > div#ct_shell > div#left_s > div.ts_se_rs')
        .map(SearchedThread.fromDivNode)
        .whereType<SearchedThread>()
        .toList();

    /// Filter out "Results about: ".
    final count = document
        .querySelector('h3')
        ?.firstEndDeepText()
        ?.split(' ')
        .firstOrNull
        ?.parseToInt();

    final currentPage = document.currentPage() ?? 1;
    final totalPages = document.totalPages() ?? currentPage;

    return SearchResult(
      currentPage: currentPage,
      totalPages: totalPages,
      count: count,
      data: threadList,
    );
  }
}
