import 'package:flutter/material.dart';
import 'package:tsdm_client/i18n/strings.g.dart';

/// Show a snack bar contains message show no more contents.
void showNoMoreSnackBar(
  BuildContext context, {
  bool floating = true,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: floating ? SnackBarBehavior.floating : null,
      content: Text(context.t.general.noMoreData),
    ),
  );
}

/// Show a snack bar contains message of failed to load event.
void showFailedToLoadSnackBar(
  BuildContext context, {
  bool floating = true,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: floating ? SnackBarBehavior.floating : null,
      content: Text(context.t.general.failedToLoad),
    ),
  );
}

/// Show a snack bar with given [message].
///
/// Set [avoidKeyboard] to true if want to act like resizeToAvoidBottomInset
/// which is useful in places where the snack bar is covered by keyboard such as
/// chat_bottom_container.
void showSnackBar({
  required BuildContext context,
  required String message,
  bool floating = true,
  SnackBarAction? action,
  bool avoidKeyboard = false,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: floating ? SnackBarBehavior.floating : null,
      content: Text(message),
      action: action,
      margin: avoidKeyboard
          // Merge a default edge insets of (15, 5, 15, 10) in LTRB, it is the
          // default insets padding of M3 snack bar theme that can be found in
          // snack_bar.dart in flutter source code.
          // Make a copy instead of referencing it because it's internal in pkg
          // and also generated code.
          ? EdgeInsets.fromLTRB(
              15,
              5,
              15,
              10 + MediaQuery.viewInsetsOf(context).bottom,
            )
          : null,
    ),
  );
}
