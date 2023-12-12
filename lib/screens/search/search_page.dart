import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/list.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/providers/search_provider.dart';
import 'package:tsdm_client/screens/search/jump_page_dialog.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:tsdm_client/widgets/debounce_buttons.dart';
import 'package:tsdm_client/widgets/thread_card.dart';

/// Page of search, including a form to fill search parameters and search results.
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({
    this.keyword,
    this.authorUid,
    this.fid,
    this.page,
    super.key,
  });

  final String? keyword;
  final String? authorUid;
  final String? fid;
  final String? page;

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final formKey = GlobalKey<FormState>();
  final keywordController = TextEditingController();
  final authorUidController = TextEditingController(text: '0');
  final fidController = TextEditingController(text: '0');
  final scrollController = ScrollController();

  /// Flags on limiting author uid or fid.
  bool unlimitedAuthorUid = true;
  bool unlimitedFid = true;

  /// Flag on expand search form.
  ///
  /// true: Form is expanded.
  /// false: Form is collapsed.
  bool expandForm = true;

  /// Parameters used last time.
  /// Use these when search form is collapsed and get no state.
  String lastKeyword = '';
  String lastAuthorUid = '0';
  String lastFid = '0';

  SearchResult _result = const SearchResult.empty();

  @override
  void initState() {
    super.initState();
    // Set to the fid passed from outside.
    // This may by opening the search page from a forum page.
    if (widget.fid != null) {
      setState(() {
        fidController.text = widget.fid!;
        unlimitedFid = false;
      });
    }
  }

  /// Do the search action.
  ///
  /// This is the last internal action so there is no parameter checking.
  /// MUST ensure parameters are checked before calling.
  Future<void> _doSearch({
    required String keyword,
    required String authorUid,
    required String fid,
    required int page,
  }) async {
    debug(
        'search with args: keyword=$keyword, authorUid=$authorUid, fid=$fid, page=$page');

    final searchResult = await ref.read(searchProvider.notifier).search(
          keyword: keyword,
          authorUid: authorUid,
          fid: fid,
          page: page,
        );

    setState(() {
      _result = searchResult;
      // Only return to top when attached (not the first search).
      if (scrollController.hasClients) {
        scrollController.animateTo(
          0,
          curve: Curves.ease,
          duration: const Duration(microseconds: 500),
        );
      }
    });
  }

  /// Search with given keyword, authorUid and fid, return the [page] index in result pages.
  /// Always validate search parameters.
  Future<void> _search([int page = 0]) async {
    if (formKey.currentState == null) {
      // Collapsed.
      // If lastKeyword is not empty, indicates there is a valid last search.
      // User want to jump to another page so use the last used parameters and parameter page.
      if (lastKeyword.isNotEmpty) {
        await _doSearch(
          keyword: lastKeyword,
          authorUid: lastAuthorUid,
          fid: lastFid,
          page: page,
        );
      }
      return;
    }

    if (!(formKey.currentState!).validate()) {
      // Invalid parameters.
      return;
    }

    final keyword = keywordController.text;

    final authorUid = switch (authorUidController.text) {
      '' => '0',
      _ => authorUidController.text,
    };

    final fid = switch (fidController.text) {
      '' => '0',
      _ => fidController.text,
    };

    await _doSearch(
        keyword: keyword, authorUid: authorUid, fid: fid, page: page);
    lastKeyword = keyword;
    lastAuthorUid = authorUid;
    lastFid = fid;
  }

  /// Whether has previous pages in [_result].
  bool _hasPreviousPage() {
    return _result.isValid() && _result.currentPage > 1;
  }

  /// Whether has next pages in [_result].
  bool _hasNextPage() {
    return _result.isValid() &&
        _result.currentPage > 0 &&
        _result.currentPage < _result.totalPages;
  }

  /// show a dialog and jump to the specified page.
  Future<void> _gotoSpecifiedPage(BuildContext context) async {
    final page = await showDialog<int>(
      context: context,
      builder: (context) => JumpPageDialog(
        min: 1,
        current: _result.currentPage,
        max: _result.totalPages,
      ),
    );
    if (page == null || page == _result.currentPage) {
      return;
    }
    await _search(page);
  }

  Future<void> _searchPreviousPage() async {
    if (!_hasPreviousPage()) {
      return;
    }

    final page = _result.currentPage;
    await _search(page - 1);
  }

  Future<void> _searchNextPage() async {
    if (!_hasNextPage()) {
      return;
    }
    final page = _result.currentPage;
    await _search(page + 1);
  }

  Widget _buildSearchButton(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 50,
            child: DebounceElevatedButton(
              shouldDebounce:
                  ref.watch(searchProvider) == SearchState.searching,
              onPressed: _search,
              child: Text(context.t.searchPage.form.search),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildSearchForm(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            autofocus: true,
            controller: keywordController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.abc_outlined),
              labelText: context.t.searchPage.form.keyword,
            ),
            validator: (v) {
              if (v!.isEmpty) {
                return context.t.searchPage.form.keywordEmpty;
              }
              if (v.contains('%')) {
                return context.t.searchPage.form.keywordInvalid;
              }
              return null;
            },
          ),
          TextFormField(
            controller: authorUidController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.person_outline),
              labelText: context.t.searchPage.form.authorUid,
              suffixText:
                  unlimitedAuthorUid ? context.t.searchPage.form.any : null,
            ),
            onChanged: (v) {
              setState(() {
                unlimitedAuthorUid = v == '0';
              });
            },
            validator: (v) {
              // Allow empty value because the default parameter in searching is zero.
              if (v!.isEmpty) {
                setState(() {
                  authorUidController.text = '0';
                  unlimitedAuthorUid = true;
                });
                return null;
              }
              final i = int.tryParse(v);
              if (i == null || i < 0) {
                return context.t.searchPage.form.authorUidInvalid;
              }
              return null;
            },
          ),
          TextFormField(
            controller: fidController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.forum_outlined),
              labelText: context.t.searchPage.form.fid,
              suffixText: unlimitedFid ? context.t.searchPage.form.any : null,
            ),
            onChanged: (v) {
              setState(() {
                unlimitedFid = fidController.text == '0';
              });
            },
            validator: (v) {
              // Allow empty value because the default parameter in searching is zero.
              if (v!.isEmpty) {
                setState(() {
                  fidController.text = '0';
                  unlimitedFid = true;
                });
                return null;
              }
              final i = int.tryParse(v);
              if (i == null || i < 0) {
                return context.t.searchPage.form.fidInvalid;
              }
              return null;
            },
          ),
          _buildSearchButton(context),
        ].insertBetween(sizedBoxW10H10),
      ),
    );
  }

  Widget _buildResultInfoRow(BuildContext context) {
    final searching = ref.watch(searchProvider) == SearchState.searching;
    return Row(
      children: [
        Text(context.t.searchPage.result.title,
            style: Theme.of(context).textTheme.titleMedium),
        sizedBoxW10H10,
        Text(context.t.searchPage.result
            .totalThreadCount(count: '${_result.count ?? "-"}')),
        sizedBoxW10H10,
        Text(context.t.searchPage.result.pageInfo(total: _result.totalPages)),
        Expanded(child: Container()),
        IconButton(
          icon: const Icon(Icons.arrow_left_outlined),
          onPressed:
              !searching && _hasPreviousPage() ? _searchPreviousPage : null,
        ),
        TextButton(
          child: Text('${_result.currentPage}'),
          onPressed: !searching && (_hasPreviousPage() || _hasNextPage())
              ? () async {
                  await _gotoSpecifiedPage(context);
                }
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.arrow_right_outlined),
          onPressed: !searching && _hasNextPage() ? _searchNextPage : null,
        ),
      ],
    );
  }

  Widget _buildSearchResult(BuildContext context) {
    if (!_result.isValid() || _result.data == null || _result.data!.isEmpty) {
      return Expanded(
        child: Center(child: Text(context.t.searchPage.result.noData)),
      );
    }

    return Expanded(
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: ListView.separated(
          controller: scrollController,
          shrinkWrap: true,
          itemCount: _result.data!.length,
          itemBuilder: (context, index) {
            final d = _result.data![index];
            return SearchedThreadCard(d);
          },
          separatorBuilder: (context, index) => sizedBoxW5H5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.searchPage.title),
        actions: [
          IconButton(
            icon: Icon(expandForm ? Icons.expand_less : Icons.expand_more),
            onPressed: () {
              setState(() {
                expandForm = !expandForm;
              });
            },
          )
        ],
      ),
      body: Padding(
        padding: edgeInsetsL10T5R10B20,
        child: Column(
          children: [
            if (expandForm) _buildSearchForm(context),
            _buildResultInfoRow(context),
            _buildSearchResult(context),
          ].insertBetween(sizedBoxW10H10),
        ),
      ),
    );
  }
}
