import 'package:flutter/material.dart';

Widget buildImage(String assetName) {
  return Image.asset(
    'assets/images/$assetName',
  );
}

List<DateTime> getDaysInBeteween(DateTime startDate, DateTime endDate) {
  List<DateTime> days = [];
  for (int i = 0; i <= endDate.difference(startDate).inDays - 1; i++) {
    days.add(DateTime(
        startDate.year,
        startDate.month,
        // In Dart you can set more than. 30 days, DateTime will do the trick
        startDate.day + i));
  }

  return days;
}
