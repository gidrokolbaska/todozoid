
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'era_mode.dart';
import 'flutter_cupertino_rounded_date_picker_widget.dart';

class CupertinoRoundedDurationPicker {
  static show(
    BuildContext context, {
    Function(Duration)? onDurationChanged,
    int minuteInterval = 1,
    Duration? initialTimerDuration,
    CupertinoTimerPickerMode initialDurationPickerMode =
        CupertinoTimerPickerMode.hm,
    EraMode era = EraMode.christYear,
    double borderRadius = 16,
    String? fontFamily,
    Color background = Colors.white,
    Color textColor = Colors.black54,
  }) async {
    initialTimerDuration ??= const Duration(minutes: 10);

    return await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return FlutterRoundedCupertinoDurationPickerWidget(
          onTimerDurationChanged: (duration) {
            if (onDurationChanged != null) {
              onDurationChanged(duration);
            }
          },
          background: background,
          textColor: textColor,
          borderRadius: borderRadius,
          fontFamily: fontFamily,
          initialTimerDuration: initialTimerDuration!,
          mode: initialDurationPickerMode,
          minuteInterval: minuteInterval,
        );
      },
    );
  }
}
