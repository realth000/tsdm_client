import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/features/profile/models/birthday_info.dart';
import 'package:tsdm_client/features/root/view/root_page.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/widgets/custom_alert_dialog.dart';
import 'package:wheel_choice/wheel_choice.dart';

/// Use [String] to show choices as empty value is valid.
typedef _BirthdayComponent = String;

/// Show a dialog to let user select birthday date.
Future<BirthdayInfo?> showSelectBirthdayDialog(
  BuildContext context,
  BirthdayInfo initialDate,
  List<int> availableYears,
) async => showDialog<BirthdayInfo>(
  context: context,
  builder: (_) => RootPage(
    DialogPaths.editUserProfile,
    _SelectBirthdayDialog(
      initialDate,
      availableYears,
    ),
  ),
);

/// Dialog to show a flexible birthday selector.
///
/// The dialog produces a date time consists of:
///
/// 1. Year: Available years only, or null.
/// 2. Month: 1-12, or null.
/// 3. Day: Available values decided by year and month, or null.
class _SelectBirthdayDialog extends StatefulWidget {
  const _SelectBirthdayDialog(this.initialDate, this.availableYears);

  /// Initial birthday date value.
  final BirthdayInfo initialDate;

  /// All available year choices received from server side.
  final List<int> availableYears;

  @override
  State<_SelectBirthdayDialog> createState() => _SelectBirthdayDialogState();
}

class _SelectBirthdayDialogState extends State<_SelectBirthdayDialog> {
  late BirthdayInfo date;

  late final WheelController<_BirthdayComponent> yearController;
  late final WheelController<_BirthdayComponent> monthController;
  late final WheelController<_BirthdayComponent> dayController;

  /// Produce legal days for specified [year] and [month].
  ///
  /// This function does the same work as `showBirthday()` of original `home.js`.
  List<String> _produceAvailableDays({required int? year, required int? month}) {
    final days = List.generate(28, (v) => v == 0 ? '-' : v.toString());
    if (month == null) {
      // Note that when month is not specified, the original js code does not update available days.
      // But we do it here as it's general to have 31 days in a month when no exact month specified.
      days.addAll(['29', '30', '31']);
    } else if (month == 2) {
      // February.
      if (year != null && (year % 400 == 0 || (year % 4 == 0 && year % 100 != 0))) {
        days.add('29');
      }
    } else {
      // Not February.
      days.addAll(['29', '30']);
      if ([1, 3, 5, 7, 8, 10, 12].contains(month)) {
        days.add('31');
      }
    }
    return days;
  }

  @override
  void initState() {
    super.initState();
    date = widget.initialDate;
    yearController = WheelController<_BirthdayComponent>(
      options: ['-', ...widget.availableYears.map((v) => v.toString())],
      value: date.year == null ? '-' : date.year.toString(),
      onChanged: (v) => setState(() => date = date.copyWith(year: v.parseToInt())),
    );
    monthController = WheelController<_BirthdayComponent>(
      options: const ['-', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'],
      value: date.month == null ? '-' : date.month.toString(),
      onChanged: (v) => setState(() {
        date = date.copyWith(month: v.parseToInt());
        final availableDays = _produceAvailableDays(year: date.year, month: date.month);
        final oldDay = dayController.value;
        dayController.setOptions(availableDays);
        // If the month switched to a month with less days and current [oldDay] is invalid in the new month,
        // set the day value to biggest value (the one most close to [oldDay]).
        if (!availableDays.contains(oldDay)) {
          unawaited(dayController.setValue(availableDays.last));
        }
      }),
    );
    dayController = WheelController<_BirthdayComponent>(
      options: _produceAvailableDays(year: date.year, month: date.month),
      value: date.day == null ? '-' : date.day.toString(),
      onChanged: (v) => setState(() => date = date.copyWith(day: v.parseToInt())),
    );
  }

  @override
  void dispose() {
    yearController.dispose();
    monthController.dispose();
    dayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.t.editUserProfilePage.birthday;
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {.touch, .mouse, .stylus, .trackpad}),
      child: CustomAlertDialog.sync(
        clipBehavior: .hardEdge,
        contentPadding: .zero,
        title: Text(tr.title),
        content: Row(
          children: [(yearController, tr.year), (monthController, tr.month), (dayController, tr.day)]
              .map(
                (v) => Expanded(
                  child: WheelChoice<_BirthdayComponent>.raw(
                    controller: v.$1,
                    header: WheelHeader(child: Text(v.$2)),
                    overlay: WheelOverlay.outlined(inset: 12),
                    effect: const WheelEffect(useMagnifier: true, magnification: 1.1),
                  ),
                ),
              )
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(context.t.general.cancel),
          ),
          TextButton(
            onPressed: () => context.pop(date),
            child: Text(context.t.general.ok),
          ),
        ],
      ),
    );
  }
}
