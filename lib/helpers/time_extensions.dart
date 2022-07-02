import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:isoweek/isoweek.dart';

extension DateTimeExtension on DateTime {
  DateTime roundDown({Duration delta = const Duration(minutes: 5)}) {
    return DateTime.fromMillisecondsSinceEpoch(
        millisecondsSinceEpoch + millisecondsSinceEpoch % delta.inMilliseconds);
  }
}

extension DateTimeExtension2 on DateTime {
  DateTime roundUp(DateTime inputDate) {
    return DateTime(inputDate.year, inputDate.month, inputDate.day,
            inputDate.hour, inputDate.minute)
        .add(Duration(
            minutes: inputDate.minute % 5 == 0 ? 0 : 5 - inputDate.minute % 5));
  }
}

extension DateUtils on DateTime {
  bool get isToday {
    final now = DateTime.now();

    return now.day == day && now.month == month && now.year == year;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return tomorrow.day == day &&
        tomorrow.month == month &&
        tomorrow.year == year;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return yesterday.day == day &&
        yesterday.month == month &&
        yesterday.year == year &&
        yesterday.hour == hour &&
        yesterday.minute == minute &&
        yesterday.second == second;
  }

  bool isOnCurrentWeek(DateTime date, BuildContext context) {
    Week currentWeek = Week.current();
    var indexOfFirstDayOfTheWeek =
        DateFormat.EEEE(Platform.localeName).dateSymbols.FIRSTDAYOFWEEK;
    DateTime firstDayOfWeek(context) {
      if (indexOfFirstDayOfTheWeek == 6) {
        return currentWeek
            .day(indexOfFirstDayOfTheWeek - 6)
            .subtract(const Duration(days: 1));
      }

      return currentWeek.day(indexOfFirstDayOfTheWeek);
    }

    DateTime lastDayOfWeek(BuildContext context) {
      if (firstDayOfWeek(context).weekday == 7) {
        return DateTime(currentWeek.day(5).year, currentWeek.day(5).month,
            currentWeek.day(5).day, 23, 59, 59, 59, 59);
      }

      return DateTime(currentWeek.day(6).year, currentWeek.day(6).month,
          currentWeek.day(6).day, 23, 59, 59, 59, 59);
    }

    return (date.isAtSameMomentAs(firstDayOfWeek(context)) ||
                date.isAfter(firstDayOfWeek(context))) &&
            date.isBefore(lastDayOfWeek(context)) ||
        date.isAtSameMomentAs(lastDayOfWeek(context));
  }
}
