import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:my_wit_wallet/util/get_localization.dart';

bool isDaySelectable(DateTime day) {
  // prevent any day before today being selected
  return day.isAfter(DateTime.now().subtract(Duration(days: 1)));
}

int dateTimeToTimelock(DateTime? dateTime) {
  if (dateTime != null) {
    return dateTime.millisecondsSinceEpoch ~/ 1000;
  }
  return 0;
}

String formatTimelock(DateTime time) {
  return DateFormat('h:mm a E, MMM dd yyyy').format(time);
}

Future<DateTime?> showTimelockDayPicker(BuildContext context,
    DateTime? initialDate, DateTime firstDate, DateTime lastDate) async {
  final DateTime? selectedDate = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
    currentDate: null,
    initialEntryMode: DatePickerEntryMode.calendar,
    selectableDayPredicate: isDaySelectable,
    helpText: localization.datePickerHintText,
    cancelText: localization.cancel,
    confirmText: localization.okLabel,
    locale: Locale(localization.localeName),
    barrierDismissible: true,
    barrierColor: Colors.black54,
    useRootNavigator: true,
    builder: (BuildContext context, Widget? child) {
      return Container(child: child);
    },
    initialDatePickerMode: DatePickerMode.day,
    errorFormatText: localization.datePickerFormatError,
    errorInvalidText: localization.datePickerInvalid,
    fieldHintText: 'MM/DD/YYY',
    keyboardType: TextInputType.datetime,
    switchToCalendarEntryModeIcon: Icon(FontAwesomeIcons.calendar),
    switchToInputEntryModeIcon: Icon(FontAwesomeIcons.pen),
  );
  return selectedDate;
}

Future<TimeOfDay?> showTimelockTimePicker(
    BuildContext context, DateTime selectedDate) async {
  final TimeOfDay? selectedTime = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(selectedDate),
    initialEntryMode: TimePickerEntryMode.input,
    helpText: localization.timePickerHintText,
    errorInvalidText: localization.timePickerInvalid,
    hourLabelText: localization.hour,
    minuteLabelText: localization.minutes,
    cancelText: localization.cancel,
    confirmText: localization.okLabel,
  );
  return selectedTime;
}

Future<DateTime?> showTimelockPicker({
  required BuildContext context,
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) async {
  initialDate ??= DateTime.now();
  firstDate ??= initialDate.subtract(const Duration(days: 365 * 100));
  lastDate ??= firstDate.add(const Duration(days: 365 * 200));
  final DateTime? selectedDate = await showTimelockDayPicker(
    context,
    initialDate,
    firstDate,
    lastDate,
  );

  if (selectedDate == null) return null;
  if (!context.mounted) return selectedDate;

  final TimeOfDay? selectedTime =
      await showTimelockTimePicker(context, selectedDate);

  return selectedTime == null
      ? selectedDate
      : DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
}
