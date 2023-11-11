import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';

enum MenuActions {
  refresh,
  copyUrl,
  openInBrowser,
  backToTop,
}

class ListSliverAppBar<T> extends ConsumerWidget
    implements PreferredSizeWidget {
  const ListSliverAppBar({this.title, this.bottom, this.onSelected, super.key});

  final String? title;

  final PopupMenuItemSelected<MenuActions>? onSelected;
  final PreferredSizeWidget? bottom;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: title == null ? null : Text(title!),
      bottom: bottom,
      actions: [
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
