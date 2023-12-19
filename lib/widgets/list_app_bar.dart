import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/providers/jump_page_provider.dart';
import 'package:tsdm_client/widgets/jump_page_dialog.dart';

enum MenuActions {
  refresh,
  copyUrl,
  openInBrowser,
  backToTop,
}

class ListAppBar<T> extends ConsumerWidget implements PreferredSizeWidget {
  const ListAppBar({
    required this.onSearch,
    this.title,
    this.bottom,
    this.onSelected,
    this.jumpPageKey,
    this.onJumpPage,
    super.key,
  }) : assert(
            (jumpPageKey == null && onJumpPage == null) ||
                (jumpPageKey != null && onJumpPage != null),
            'jumpPageKey should used with onJumpPage');

  final FutureOr<void> Function() onSearch;

  /// Key to specify current [ListAppBar] should associate with which widget or [jumpPageProvider].
  final int? jumpPageKey;
  final FutureOr<void> Function(int)? onJumpPage;
  final String? title;

  final PopupMenuItemSelected<MenuActions>? onSelected;
  final PreferredSizeWidget? bottom;

  Future<void> _jumpPage(
    BuildContext context,
    int currentPage,
    int totalPages,
  ) async {
    if (currentPage <= 0 && currentPage > totalPages) {
      return;
    }
    final page = await showDialog<int>(
      context: context,
      builder: (context) => JumpPageDialog(
        min: 1,
        current: currentPage,
        max: totalPages,
      ),
    );
    if (page == null || page == currentPage) {
      return;
    }
    await onJumpPage?.call(page);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var currentPage = 0;
    var totalPages = 0;
    var canJumpPage = false;
    if (onJumpPage != null) {
      final jumpPageState = ref.watch(jumpPageProvider(jumpPageKey!));
      currentPage = jumpPageState.currentPage;
      totalPages = jumpPageState.totalPages;
      canJumpPage = jumpPageState.canJumpPage;
    }
    return AppBar(
      title: title == null ? null : Text(title!),
      bottom: bottom,
      actions: [
        IconButton(
          icon: const Icon(Icons.search_outlined),
          onPressed: onSearch,
        ),
        if (onJumpPage != null)
          TextButton(
            child: Text('${canJumpPage ? currentPage : "-"}'),
            onPressed: canJumpPage
                ? () async => _jumpPage(context, currentPage, totalPages)
                : null,
          ),
        PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              value: MenuActions.refresh,
              child: Row(children: [
                const Icon(Icons.refresh_outlined),
                Text(context.t.networkList.actionRefresh),
              ]),
            ),
            PopupMenuItem(
              value: MenuActions.copyUrl,
              child: Row(children: [
                const Icon(Icons.copy_outlined),
                Text(context.t.networkList.actionCopyUrl),
              ]),
            ),
            PopupMenuItem(
              value: MenuActions.openInBrowser,
              child: Row(children: [
                const Icon(Icons.launch_outlined),
                Text(context.t.networkList.actionOpenInBrowser),
              ]),
            ),
            PopupMenuItem(
              value: MenuActions.backToTop,
              child: Row(children: [
                const Icon(Icons.vertical_align_top_outlined),
                Text(context.t.networkList.actionBackToTop),
              ]),
            ),
          ],
          onSelected: onSelected,
        ),
      ],
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));
}
