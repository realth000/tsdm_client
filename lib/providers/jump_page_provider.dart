import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '../generated/providers/jump_page_provider.g.dart';

/// State of jump page ability of current page.
@immutable
class JumpPageState {
  const JumpPageState({
    required this.currentPage,
    required this.totalPages,
    required this.canJumpPage,
  });

  final int currentPage;
  final int totalPages;
  final bool canJumpPage;
}

/// Manage ths state of jump page ability of current page.
///
/// In some pages there's a long paginated list, use this provider to save and update current page's info
/// and total pages info.
@Riverpod()
class JumpPage extends _$JumpPage {
  @override
  JumpPageState build(int key) {
    _key = key;
    return JumpPageState(
      currentPage: _currentPage,
      totalPages: _totalPages,
      canJumpPage: _canJumpPage,
    );
  }

  /// Update pagination info of current page:
  /// * Current page has is in page number [currentPage].
  /// * Current page totally has [totalPages] pages.
  void setPageState({required int currentPage, required int totalPages}) {
    _currentPage = currentPage;
    _totalPages = totalPages;
    if (_currentPage > 0 && _totalPages > 0 && _currentPage <= _totalPages) {
      _setCanJumpPage(canJumpPage: true);
    } else {
      _setCanJumpPage(canJumpPage: false);
    }
    ref.invalidateSelf();
  }

  /// Indicate whether current page is able to jump to another page.
  ///
  /// Because in some situations (e.g. page still loading) current page is temporarily unable to jump to another page
  /// or the current page info and total page info isn't ready/outdated.
  void setCanJumpPage({required bool canJumpPage}) {
    _setCanJumpPage(canJumpPage: canJumpPage);
    ref.invalidateSelf();
  }

  // ignore: use_setters_to_change_properties
  void _setCanJumpPage({required bool canJumpPage}) {
    _canJumpPage = canJumpPage;
  }

  /// Key to specify ListAppBar should associate with which widget.
  /// Because there may be multiple pages having their own [jumpPageProvider].
  int _key = 0;
  var _currentPage = 0;
  var _totalPages = 0;
  var _canJumpPage = false;
}
