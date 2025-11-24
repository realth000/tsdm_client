import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/features/authentication/repository/authentication_repository.dart';
import 'package:tsdm_client/features/jump_page/cubit/jump_page_cubit.dart';
import 'package:tsdm_client/features/jump_page/widgets/jump_page_dialog.dart';
import 'package:tsdm_client/features/root/view/root_page.dart';
import 'package:tsdm_client/features/settings/bloc/settings_bloc.dart';
import 'package:tsdm_client/features/thread/v1/bloc/thread_bloc.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/widgets/list_app_bar/menu_actions.dart';
import 'package:tsdm_client/widgets/list_app_bar/menu_item_id.dart';
import 'package:tsdm_client/widgets/notice_button.dart';

/// Custom item in popup menu for list app bar.
@immutable
class MenuCustomItem {
  /// Constructor.
  const MenuCustomItem({required this.icon, required this.description, required this.onSelected});

  /// Icon to show in item of menu.
  final IconData icon;

  /// Menu description text.
  final String description;

  /// The callback to run when item is selected.
  final FutureOr<void> Function() onSelected;
}

/// A app bar contains list and provides features including:
///
/// * Jump to the global search page.
/// * Specified title.
/// * Jump page.
class ListAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Constructor.
  const ListAppBar({
    required this.onRefresh,
    required this.onCopyUrl,
    required this.onOpenInBrowser,
    this.title,
    this.bottom,
    this.showReverseOrderAction = false,
    this.onSearch,
    this.onJumpPage,
    this.onBackToTop,
    this.onReverseOrder,
    this.customMenuItems = const [],
    super.key,
  });

  /// Callback that should navigate to global search page.
  final FutureOr<void> Function()? onSearch;

  /// Jump to another page in the list.
  ///
  /// Parameter is the page number.
  final FutureOr<void> Function(int)? onJumpPage;

  /// Widget title.
  final String? title;

  /// Callback to refresh current page.
  final FutureOr<void> Function() onRefresh;

  /// Callback to copy current page's url.
  final FutureOr<void> Function() onCopyUrl;

  /// Callback to open current page in browser.
  final FutureOr<void> Function() onOpenInBrowser;

  /// Callback to scroll current page to top.
  ///
  /// Do it if possible.
  final FutureOr<void> Function()? onBackToTop;

  /// Callback to view the page in reverse order.
  ///
  /// Trigger it on and off.
  ///
  /// Do it if possible.
  final FutureOr<void> Function()? onReverseOrder;

  /// Custom menu icons.
  ///
  /// Optional.
  final List<MenuCustomItem> customMenuItems;

  /// Extra bottom widget.
  final PreferredSizeWidget? bottom;

  /// Show the action to change "view order" between forward order and reverse
  /// order.
  final bool showReverseOrderAction;

  Future<void> _jumpPage(BuildContext context, int currentPage, int totalPages) async {
    if (currentPage <= 0 && currentPage > totalPages) {
      return;
    }
    final page = await showDialog<int>(
      context: context,
      builder: (context) =>
          RootPage(DialogPaths.jumpPage, JumpPageDialog(min: 1, current: currentPage, max: totalPages)),
    );
    if (page == null || page == currentPage) {
      return;
    }
    await onJumpPage?.call(page);
  }

  @override
  Widget build(BuildContext context) {
    var currentPage = 0;
    var totalPages = 0;
    var canJumpPage = false;
    if (onJumpPage != null) {
      final jumpPageState = context.watch<JumpPageCubit>().state;
      currentPage = jumpPageState.currentPage;
      totalPages = jumpPageState.totalPages;
      canJumpPage = jumpPageState.canJumpPage;
    }

    final threadBloc = context.readOrNull<ThreadBloc>();
    // Default is not reversed.
    // FIXME: Some threads may set reversed order, detect that in page
    //  (though impossible if only one page).
    final reverseOrder = threadBloc?.state.reverseOrder ?? false;

    final isLogin = context.select<AuthenticationRepository, bool>((repo) => repo.currentUser != null);

    return AppBar(
      title: title == null ? null : Text(title!),
      // TODO: Currently we always use a compact layout in list app bar for larger main content space.
      // If going to implement responsive layout, remember to wrap list app bar in `PreferredSize` in ALL places using
      // it, this is an issue or usage defined by Flutter, seems the AppBar checks if it's direct `bottom` widget is
      // preferred size or not, to determine the height of app bar, DISGUSTING.
      bottom: bottom,
      // bottom: PreferredSize(
      //   preferredSize: Size.fromHeight((bottom?.preferredSize.height ?? 0) + (isMobile ? 52 : 42)),
      //   child: Column(
      //     children: [
      //       Row(
      //         children: [
      //           Expanded(
      //             child: Padding(
      //               padding: edgeInsetsL4R4,
      //               child: SingleChildScrollView(
      //                 scrollDirection: Axis.horizontal,
      //                 reverse: true,
      //                 child: Row(
      //                   children: [
      //                     const OpenInAppPageButton(),
      //                     IconButton(
      //                       icon: const Icon(Icons.search_outlined),
      //                       tooltip: context.t.searchPage.title,
      //                       onPressed: onSearch,
      //                     ),
      //                     const OpenProfilePageButton(),
      //                     const NoticeButton(),
      //                     IconButton(
      //                       icon: const Icon(Icons.settings_outlined),
      //                       tooltip: context.t.general.openSettings,
      //                       onPressed: () async => context.pushNamed(ScreenPaths.rootSettings),
      //                     ),
      //                   ],
      //                 ),
      //               ),
      //             ),
      //           ),
      //         ],
      //       ),
      //       ?bottom,
      //     ],
      //   ),
      // ),
      actions: [
        /**
         * Actions available in current page.
         */

        // Using three or more actions violates material design spec, but just do it.
        const NoticeButton(),
        if (onJumpPage != null)
          TextButton(
            onPressed: canJumpPage ? () async => _jumpPage(context, currentPage, totalPages) : null,
            child: Text('${canJumpPage ? currentPage : "-"}'),
          ),
        PopupMenuButton<MenuItemId>(
          itemBuilder: (context) => [
            PopupMenuItem(
              value: MenuItemId.fixed(MenuActions.refresh),
              child: Row(
                children: [
                  const Icon(Icons.refresh_outlined),
                  sizedBoxPopupMenuItemIconSpacing,
                  Text(context.t.networkList.actionRefresh),
                ],
              ),
            ),
            PopupMenuItem(
              value: MenuItemId.fixed(MenuActions.copyUrl),
              child: Row(
                children: [
                  const Icon(Icons.copy_outlined),
                  sizedBoxPopupMenuItemIconSpacing,
                  Text(context.t.networkList.actionCopyUrl),
                ],
              ),
            ),
            PopupMenuItem(
              value: MenuItemId.fixed(MenuActions.openInBrowser),
              child: Row(
                children: [
                  const Icon(Icons.open_in_browser),
                  sizedBoxPopupMenuItemIconSpacing,
                  Text(context.t.networkList.actionOpenInBrowser),
                ],
              ),
            ),
            PopupMenuItem(
              value: MenuItemId.fixed(MenuActions.backToTop),
              child: Row(
                children: [
                  const Icon(Icons.vertical_align_top_outlined),
                  sizedBoxPopupMenuItemIconSpacing,
                  Text(context.t.networkList.actionBackToTop),
                ],
              ),
            ),
            if (showReverseOrderAction)
              PopupMenuItem(
                value: MenuItemId.fixed(MenuActions.reverseOrder),
                child: Row(
                  children: [
                    Icon(reverseOrder ? Icons.align_vertical_bottom_outlined : Icons.align_vertical_top_outlined),
                    sizedBoxPopupMenuItemIconSpacing,
                    Text(
                      reverseOrder
                          ? context.t.networkList.actionForwardOrder
                          : context.t.networkList.actionReverseOrder,
                    ),
                  ],
                ),
              ),

            // Custom items.
            ...customMenuItems.mapIndexed(
              (idx, e) => PopupMenuItem(
                value: MenuItemId.custom(idx),
                child: Row(children: [Icon(e.icon), sizedBoxPopupMenuItemIconSpacing, Text(e.description)]),
              ),
            ),

            const PopupMenuDivider(),

            /**
             * Global actions
             */
            PopupMenuItem(
              value: MenuItemId.fixed(MenuActions.openInApp),
              child: Row(
                children: [
                  const Icon(Symbols.open_in_phone),
                  sizedBoxPopupMenuItemIconSpacing,
                  Text(context.t.openInAppPage.entryTooltip),
                ],
              ),
            ),
            PopupMenuItem(
              value: MenuItemId.fixed(MenuActions.openSearchPage),
              child: Row(
                children: [
                  const Icon(Icons.search_outlined),
                  sizedBoxPopupMenuItemIconSpacing,
                  Text(context.t.searchPage.title),
                ],
              ),
            ),
            PopupMenuItem(
              enabled: isLogin,
              value: MenuItemId.fixed(MenuActions.profile),
              child: Row(
                children: [
                  const Icon(Icons.person_outline),
                  sizedBoxPopupMenuItemIconSpacing,
                  Text(context.t.profilePage.title),
                ],
              ),
            ),
            PopupMenuItem(
              enabled: isLogin,
              value: MenuItemId.fixed(MenuActions.openNoticePage),
              child: Row(
                children: [
                  const Icon(Icons.notifications_outlined),
                  sizedBoxPopupMenuItemIconSpacing,
                  Text(context.t.noticePage.title),
                ],
              ),
            ),
            PopupMenuItem(
              value: MenuItemId.fixed(MenuActions.openSettingsPage),
              child: Row(
                children: [
                  const Icon(Icons.settings_outlined),
                  sizedBoxPopupMenuItemIconSpacing,
                  Text(context.t.general.settings),
                ],
              ),
            ),

            if (context.read<SettingsBloc>().state.settingsMap.enableDebugOperations) ...<PopupMenuEntry<MenuItemId>>[
              const PopupMenuDivider(),
              PopupMenuItem(
                value: MenuItemId.fixed(MenuActions.debugViewLog),
                child: Text(context.t.settingsPage.debugSection.viewLog.title),
              ),
            ],
          ],
          onSelected: (item) async {
            switch (item.action) {
              case MenuActions.refresh:
                await onRefresh.call();
              case MenuActions.copyUrl:
                await onCopyUrl.call();
              case MenuActions.openInBrowser:
                await onOpenInBrowser.call();
              case MenuActions.backToTop:
                await onBackToTop?.call();
              case MenuActions.reverseOrder:
                await onReverseOrder?.call();
              case MenuActions.openInApp:
                await context.pushNamed(ScreenPaths.openInApp);
              case MenuActions.openSearchPage:
                onSearch != null ? await onSearch?.call() : context.pushNamed(ScreenPaths.search);
              case MenuActions.profile:
                await context.pushNamed(ScreenPaths.profile);
              case MenuActions.openNoticePage:
                await context.pushNamed(ScreenPaths.notice);
              case MenuActions.openSettingsPage:
                await context.pushNamed(ScreenPaths.rootSettings);
              case MenuActions.debugViewLog:
                await context.pushNamed(ScreenPaths.debugLog);
              case MenuActions.custom:
                // Custom actions.
                await customMenuItems.elementAt(item.customId!).onSelected.call();
            }
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));
}
