import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/providers/html_parser_provider.dart';
import 'package:tsdm_client/providers/net_client_provider.dart';
import 'package:universal_html/html.dart' as uh;

/// A refreshable [ListView].
///
/// Contains an [EasyRefresh], define .
class RefreshList<T> extends ConsumerStatefulWidget {
  const RefreshList({
    required this.targetUrl,
    required this.buildDataCallback,
    required this.builder,
    this.parseNextPageUrlCallback,
    super.key,
  });

  /// Target initial url to build this list.
  final String targetUrl;

  /// How to build a list of data (type List<T>) from html [uh.Document] document.
  final FutureOr<List<T>> Function(uh.Document document) buildDataCallback;

  /// How to parse the url of next page form html [uh.Document] document.
  ///
  /// When not set, this list is set to "single page mode" which does not support load more.
  final FutureOr<String?> Function(uh.Document document)?
      parseNextPageUrlCallback;

  /// How to build a child of current list from data (type T).
  final Widget Function(T data) builder;

  @override
  ConsumerState<RefreshList<T>> createState() => _RefreshListState();
}

class _RefreshListState<T> extends ConsumerState<RefreshList<T>> {
  late final EasyRefreshController _refreshController;

  @override
  void initState() {
    super.initState();
    _refreshController = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: widget.parseNextPageUrlCallback != null,
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  final _allData = <T>[];

  /// Url of next page.
  ///
  /// This should be updated after "refresh" or "load more" every time.
  /// A null String indicates no more data.
  String? _nextPageUrl;

  @override
  Widget build(BuildContext context) {
    return EasyRefresh(
      scrollBehaviorBuilder: (physics) {
        return ERScrollBehavior(physics)
            .copyWith(physics: physics, scrollbars: false);
      },
      controller: _refreshController,
      header: const MaterialHeader(),
      refreshOnStart: true,
      onRefresh: () async {
        if (!mounted) {
          return;
        }
        setState(_allData.clear);
        final resp = await ref.read(netClientProvider()).get(widget.targetUrl);
        if (!mounted) {
          return;
        }
        final document = ref.read(htmlParserProvider.notifier).parseResp(resp);
        final data = await widget.buildDataCallback(document);
        setState(() {
          _allData.addAll(data);
        });
        _nextPageUrl = await widget.parseNextPageUrlCallback?.call(document);
        _refreshController.finishRefresh();
      },
      onLoad: () async {
        if (!mounted) {
          return;
        }
        if (_nextPageUrl == null) {
          _refreshController.finishLoad(IndicatorResult.noMore);
          return;
        }
        final resp = await ref.read(netClientProvider()).get(_nextPageUrl!);
        final document = ref.read(htmlParserProvider.notifier).parseResp(resp);
        final data = await widget.buildDataCallback(document);
        setState(() {
          _allData.addAll(data);
        });
        _nextPageUrl = await widget.parseNextPageUrlCallback?.call(document);
        _refreshController.finishLoad();
      },
      child: ListView.separated(
        itemCount: _allData.length,
        itemBuilder: (context, index) {
          return widget.builder(_allData[index]);
        },
        separatorBuilder: (context, index) => sizedBoxW5H5,
      ),
    );
  }
}
