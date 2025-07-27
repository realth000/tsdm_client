import 'package:flutter/foundation.dart' show immutable;
import 'package:tsdm_client/widgets/list_app_bar/menu_actions.dart';

/// The id of each item used in menu action in list app bar.
///
/// Use this data class to act like
@immutable
final class MenuItemId {
  /// Constructor.
  const MenuItemId._(this.action, this.customId);

  /// Build a fixed one.
  factory MenuItemId.fixed(MenuActions action) => MenuItemId._(action, null);

  /// Build a custom action.
  factory MenuItemId.custom(int customId) => MenuItemId._(MenuActions.custom, customId);

  /// The action.
  final MenuActions action;

  /// Custom action id.
  ///
  /// Available when [action] is `_MenuActions.custom`.
  final int? customId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is MenuItemId && other.action == action && other.customId == customId);

  @override
  int get hashCode => Object.hashAll([action, customId]);
}
