import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'era_mode.dart';
import 'flutter_cupertino_rounded_date_picker_widget.dart';

class CupertinoRoundedDatePicker {
  static show(
    BuildContext context, {
    Locale? locale,
    DateTime? initialDate,
    DateTime? minimumDate,
    DateTime? maximumDate,
    int? minimumYear,
    int? maximumYear,
    Function(DateTime)? onDateTimeChanged,
    int minuteInterval = 1,
    bool use24hFormat = false,
    CupertinoDatePickerMode initialDatePickerMode =
        CupertinoDatePickerMode.date,
    EraMode era = EraMode.christYear,
    double borderRadius = 16,
    String? fontFamily,
    Color background = Colors.white,
    Color textColor = Colors.black54,
  }) async {
    initialDate ??= DateTime.now();
    minimumDate ??= DateTime.now().subtract(const Duration(days: 7));
    maximumDate ??= DateTime.now().add(const Duration(days: 7));
    minimumYear ??= DateTime.now().year - 1;
    maximumYear ??= DateTime.now().year + 1;
    return await showModalBottomSheet(
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        enableDrag: false,
        context: context,
        builder: (context) {
          return FlutterRoundedCupertinoDatePickerWidget(
            use24hFormat: use24hFormat,
            onDateTimeChanged: (dateTime) {
              if (onDateTimeChanged != null) {
                onDateTimeChanged(dateTime);
              }
            },
            era: era,
            background: background,
            textColor: textColor,
            borderRadius: borderRadius,
            fontFamily: fontFamily,
            initialDateTime: initialDate,
            mode: initialDatePickerMode,
            minuteInterval: minuteInterval,
            minimumDate: minimumDate,
            maximumDate: maximumDate,
            maximumYear: maximumYear,
            minimumYear: minimumYear!,
          );
        });
  }
}
