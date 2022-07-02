import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class TasksController extends GetxController {
  @override
  void onInit() async {
    await initializeDateFormatting(Get.locale!.languageCode);

    super.onInit();
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('todosDaily')
        .doc('dailyRequirement')
        .get()
        .then((value) {
      if (value.data() != null) {
        dailyGoal.value = value.data()!['amount'];
      }
    });
  }

  final completed = 6.obs;
  final dailyGoal = 10.obs;
  final List<int> amountOfDailyGoalToSelect = [
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    13,
    14,
    15,
    16,
    17,
    18,
    19,
    20,
    21,
    22,
    23,
    24,
    25
  ].obs;
  Rxn<DateTime> time = Rxn();

  Rxn<DateTime> date = Rxn();
  RxnBool todoOpenedFromTasksScreen = RxnBool(false);
  //final date = Rx<DateTime?>(DateTime.now());
  final todoScrollController = ScrollController().obs;
  final todosEmpty = false.obs;
  final listsEmpty = false.obs;
  final timeSelected = false.obs;
  final dateSelected = false.obs;
  final customWeekDays =
      DateFormat.EEEE(Get.locale!.languageCode).dateSymbols.SHORTWEEKDAYS;
  final formattedTime = ''.obs;
  double percentsCompleted(int completedFromFireStore) {
    return completedFromFireStore / dailyGoal.value * 100;
  }

//0 = Description, 1 = Date, 2 = Category
  final sortedByValue = 0.obs;

  final isExpanded = false.obs;
  final blurValue = 20.0.obs;

  var todoColor = 0.obs;

  //

  // update data in table

  String dailyTasksModifier(int completed, int total) {
    final finalValue = ("$completed / $total").toString();
    return finalValue;
  }

  /// Builds widgets showing abbreviated days of week. The first widget in the
  /// returned list corresponds to the first day of week for the current locale.
  ///
  /// Examples:
  ///
  /// ```
  /// ┌ Sunday is the first day of week in the US (en_US)
  /// |
  /// S M T W T F S  <-- the returned list contains these widgets
  /// _ _ _ _ _ 1 2
  /// 3 4 5 6 7 8 9
  ///
  /// ┌ But it's Monday in the UK (en_GB)
  /// |
  /// M T W T F S S  <-- the returned list contains these widgets
  /// _ _ _ _ 1 2 3
  /// 4 5 6 7 8 9 10
  /// ```
  String getDayHeaders(MaterialLocalizations localizations, double value) {
    final List<String> result = <String>[];

    for (int i = localizations.firstDayOfWeekIndex; true; i = (i + 1) % 7) {
      result.add(
        i < customWeekDays.length ? customWeekDays[i] : "",
      );
      if (i == (localizations.firstDayOfWeekIndex - 1) % 7) break;
    }

    switch (value.toInt()) {
      case 0:
        return result[0];
      case 1:
        return result[1];
      case 2:
        return result[2];
      case 3:
        return result[3];
      case 4:
        return result[4];
      case 5:
        return result[5];
      case 6:
        return result[6];
      default:
        return '';
    }
  }
}
