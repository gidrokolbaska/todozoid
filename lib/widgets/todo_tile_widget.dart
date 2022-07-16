import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:todozoid2/controllers/notifications_controller.dart';
import 'package:todozoid2/helpers/time_extensions.dart';

import '../Database/database.dart';
import '../consts/consts.dart';
import '../controllers/categories_controller.dart';
import '../controllers/tasks_controller.dart';
import '../helpers/custom_icons_icons.dart';
import '../models/category.dart';
import '../models/todo.dart';
import 'categories_modal_fit.dart';
import 'create_tast_modal.dart';
import 'custom_slidable_action.dart';

class Item extends StatelessWidget {
  const Item({
    Key? key,
    required this.todo,
    required this.color,
    required this.tasksController,
    required this.fireStoreData,
    required this.databaseController,
    required this.categoriesController,
    this.firestoreCategoryData,
    this.categoryReferenceID,
    required this.notificationsController,
  }) : super(key: key);
  final Todo todo;
  final int? color;
  final TasksController tasksController;
  final DatabaseController databaseController;
  final CategoriesController categoriesController;
  final NotificationsController notificationsController;
  final QueryDocumentSnapshot<Todo> fireStoreData;
  final Category? firestoreCategoryData;
  final String? categoryReferenceID;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(
        Radius.circular(5),
      ),
      child: Slidable(
        groupTag: 1,
        key: const ValueKey(1),
        startActionPane: ActionPane(
          dragDismissible: false,
          dismissible: DismissiblePane(
            onDismissed: () {},
          ),
          motion: const BehindMotion(),
          extentRatio: 0.3,
          children: [
            MySlidableAction(
              spacing: 10,
              foregroundColor: Constants.kWhiteBgColor,
              label: 'category'.tr,
              labelStyle: TextStyle(
                fontSize: 10.sp,
                //color: Constants.kPrimaryTextColor,
                fontWeight: FontWeight.bold,
              ),
              backgroundColor: Colors.blue,
              icon: Icons.format_list_bulleted_rounded,
              iconSize: 30,
              onPressed: (BuildContext context) async {
                categoriesController
                    .isCategoryModalOpenedFromTasksScreen.value = true;
                await Get.bottomSheet(
                  CategoriesModalFit(
                    queryData: fireStoreData,
                  ),
                  enableDrag: false,
                  isDismissible: false,
                  backgroundColor: context.isDarkMode
                      ? Constants.kDarkThemeBGColor
                      : Constants.kGrayBgColor,
                  isScrollControlled: true,
                  ignoreSafeArea: false,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24.0),
                        topRight: Radius.circular(24.0)),
                  ),
                );
              },
            ),
            // MySlidableAction(
            //   spacing: 10,
            //   foregroundColor: Constants.kWhiteBgColor,
            //   label: 'when'.tr,
            //   labelStyle: const TextStyle(
            //     fontSize: 11,
            //     //color: Constants.kPrimaryTextColor,
            //     fontWeight: FontWeight.bold,
            //   ),
            //   backgroundColor: Colors.yellow.shade700,
            //   icon: Icons.date_range_outlined,
            //   iconSize: 30,
            //   onPressed: (context) async {
            //     Platform.isIOS
            //         ? showCupertinoModalPopup(
            //             builder: (BuildContext context) {
            //               return CupertinoActionSheet(
            //                 cancelButton: CupertinoActionSheetAction(
            //                   onPressed: () {
            //                     Get.back();
            //                   },
            //                   isDestructiveAction: true,
            //                   isDefaultAction: true,
            //                   child: Text('cancel'.tr),
            //                 ),
            //                 title: Text('dateOrTime'.tr),
            //                 actions: [
            //                   CupertinoActionSheetAction(
            //                     onPressed: () async {
            //                       categoriesController
            //                           .isDateModalOpenedFromTasksScreen
            //                           .value = true;
            //                       if (fireStoreData.data().todoDate != null) {
            //                         tasksController.dateSelected.value = true;
            //                       }
            //                       if (fireStoreData.data().todoTime != null) {
            //                         tasksController.timeSelected.value = true;
            //                         tasksController.time.value =
            //                             fireStoreData.data().todoTime!.toDate();
            //                       }
            //                       tasksController.date.value =
            //                           await showRoundedDatePicker(
            //                         context: context,
            //                         initialDate: tasksController.date.value,
            //                         listDateDisabled: helpers.getDaysInBeteween(
            //                             DateTime(DateTime.now().year,
            //                                 DateTime.now().month, 1),
            //                             DateTime.now()),
            //                         firstDate: DateTime(
            //                             DateTime.now().year,
            //                             DateTime.now().month,
            //                             DateTime.now().day,
            //                             0,
            //                             0,
            //                             0),
            //                         lastDate: DateTime(
            //                             DateTime.now().year + 2, 12, 31),
            //                         locale: Get.deviceLocale,
            //                         customWeekDays: DateFormat.EEEE(
            //                                 Get.deviceLocale!.languageCode)
            //                             .dateSymbols
            //                             .SHORTWEEKDAYS,
            //                         height: 380,
            //                         textActionButton: "DELETE DATE",
            //                         onTapActionButton: () {
            //                           Navigator.of(context).pop(null);
            //                           tasksController.dateSelected.value =
            //                               false;
            //                           tasksController.date.value = null;
            //                         },
            //                         theme: ThemeData(
            //                           primaryColor: context.isDarkMode
            //                               ? Constants.kDarkThemeBGColor
            //                               : Constants.kLightGrayColor2,
            //                         ),
            //                         styleDatePicker:
            //                             MaterialRoundedDatePickerStyle(
            //                           textStyleDayButton: TextStyle(
            //                             fontSize: 35,
            //                             color: context.isDarkMode
            //                                 ? Constants.kDarkThemeTextColor
            //                                 : Constants.kAlternativeTextColor,
            //                           ),
            //                           textStyleYearButton: TextStyle(
            //                             fontSize: 35,
            //                             color: context.isDarkMode
            //                                 ? Constants.kDarkThemeTextColor
            //                                 : Constants.kAlternativeTextColor,
            //                           ),
            //                           textStyleDayHeader: TextStyle(
            //                             fontSize: 15,
            //                             color: context.isDarkMode
            //                                 ? Constants
            //                                     .kDarkThemeTextColorAlternative
            //                                     .withOpacity(0.5)
            //                                 : Constants.kBlackTextOnWhiteBGColor
            //                                     .withOpacity(0.5),
            //                           ),
            //                           textStyleCurrentDayOnCalendar: TextStyle(
            //                               fontSize: 25,
            //                               color: context.isDarkMode
            //                                   ? Constants.kDarkThemeAccentColor
            //                                   : Constants.kAccentColor,
            //                               fontWeight: FontWeight.bold),
            //                           textStyleDayOnCalendar: TextStyle(
            //                             fontSize: 17,
            //                             color: context.isDarkMode
            //                                 ? Constants
            //                                     .kDarkThemeTextColorAlternative
            //                                 : Constants.kAlternativeTextColor,
            //                           ),
            //                           textStyleDayOnCalendarSelected:
            //                               const TextStyle(
            //                             fontSize: 26,
            //                             color: Colors.white,
            //                             fontWeight: FontWeight.bold,
            //                           ),
            //                           textStyleDayOnCalendarDisabled: TextStyle(
            //                             fontSize: 17,
            //                             color: context.isDarkMode
            //                                 ? Constants
            //                                     .kDarkThemeTextColorAlternative
            //                                     .withOpacity(0.3)
            //                                 : Constants.kAlternativeTextColor
            //                                     .withOpacity(0.3),
            //                           ),
            //                           textStyleMonthYearHeader: TextStyle(
            //                             fontSize: 21,
            //                             color: context.isDarkMode
            //                                 ? Constants
            //                                     .kDarkThemeTextColorAlternative
            //                                 : Constants
            //                                     .kBlackTextOnWhiteBGColor,
            //                             fontWeight: FontWeight.bold,
            //                           ),
            //                           paddingDatePicker:
            //                               const EdgeInsets.all(0),
            //                           paddingMonthHeader:
            //                               const EdgeInsets.all(15),
            //                           paddingActionBar: const EdgeInsets.all(0),
            //                           paddingDateYearHeader:
            //                               const EdgeInsets.all(0),
            //                           arrowIconLeft: CustomIcons.arrowLeft,
            //                           arrowIconRight: CustomIcons.arrowRight,
            //                           sizeArrow: 20,
            //                           colorArrowNext: context.isDarkMode
            //                               ? Constants
            //                                   .kDarkThemeTextColorAlternative
            //                               : Constants.kBlackTextOnWhiteBGColor,
            //                           colorArrowPrevious: context.isDarkMode
            //                               ? Constants
            //                                   .kDarkThemeTextColorAlternative
            //                               : Constants.kBlackTextOnWhiteBGColor,
            //                           marginLeftArrowPrevious: 15,
            //                           marginTopArrowPrevious: 15,
            //                           marginTopArrowNext: 15,
            //                           marginRightArrowNext: 15,
            //                           textStyleButtonAction: TextStyle(
            //                               fontSize: 15,
            //                               color: context.isDarkMode
            //                                   ? Constants
            //                                       .kDarkThemeTextColorAlternative
            //                                   : Constants
            //                                       .kBlackTextOnWhiteBGColor,
            //                               fontWeight: FontWeight.bold),
            //                           textStyleButtonPositive: TextStyle(
            //                               fontSize: 15,
            //                               color: context.isDarkMode
            //                                   ? Constants
            //                                       .kDarkThemeTextColorAlternative
            //                                   : Constants
            //                                       .kBlackTextOnWhiteBGColor,
            //                               fontWeight: FontWeight.bold),
            //                           textStyleButtonNegative: TextStyle(
            //                             fontSize: 15,
            //                             color: context.isDarkMode
            //                                 ? Constants
            //                                     .kDarkThemeTextColorAlternative
            //                                     .withOpacity(0.6)
            //                                 : Constants.kBlackTextOnWhiteBGColor
            //                                     .withOpacity(0.6),
            //                           ),
            //                           decorationDateSelected: BoxDecoration(
            //                             color: context.isDarkMode
            //                                 ? Constants.kDarkThemeAccentColor
            //                                 : Constants.kAccentColor,
            //                             shape: BoxShape.circle,
            //                           ),
            //                           backgroundPicker: context.isDarkMode
            //                               ? Constants.kDarkThemeBGLightColor
            //                               : Constants.kWhiteBgColor,
            //                           backgroundActionBar: context.isDarkMode
            //                               ? Constants.kDarkThemeBGLightColor
            //                               : Constants.kWhiteBgColor,
            //                           backgroundHeaderMonth: context.isDarkMode
            //                               ? Constants.kDarkThemeBGLightColor
            //                               : Constants.kWhiteBgColor,
            //                         ),
            //                         styleYearPicker:
            //                             MaterialRoundedYearPickerStyle(
            //                           textStyleYear: TextStyle(
            //                             fontSize: 40,
            //                             color: context.isDarkMode
            //                                 ? Constants.kDarkThemeTextColor
            //                                 : Constants.kAlternativeTextColor,
            //                           ),
            //                           textStyleYearSelected: TextStyle(
            //                               fontSize: 56,
            //                               color: context.isDarkMode
            //                                   ? Constants.kDarkThemeAccentColor
            //                                   : Constants.kAccentColor,
            //                               fontWeight: FontWeight.bold),
            //                           heightYearRow: 100,
            //                           backgroundPicker: context.isDarkMode
            //                               ? Constants.kDarkThemeBGLightColor
            //                               : Constants.kWhiteBgColor,
            //                         ),
            //                       );

            //                       categoriesController
            //                           .isDateModalOpenedFromTasksScreen
            //                           .value = false;
            //                       //Since we change only the date (without time) it would be logical to change the Date to tasksController.date.value + 23:59:59
            //                       // because otherwise we take the current time and todo becomes instantly overdue

            //                       if (tasksController.date.value != null &&
            //                           tasksController.date.value!.isToday) {
            //                         //TODO change custom hour, minute and blablabla to a variable that is the endOfTheDay which should be present in TasksController somewhere in the future

            //                         int newHour = 23;
            //                         int newMinute = 59;
            //                         int newSecond = 59;
            //                         tasksController.date.value =
            //                             tasksController.date.value!.toLocal();
            //                         tasksController.date.value = DateTime(
            //                             tasksController.date.value!.year,
            //                             tasksController.date.value!.month,
            //                             tasksController.date.value!.day,
            //                             newHour,
            //                             newMinute,
            //                             newSecond,
            //                             tasksController
            //                                 .date.value!.millisecond);
            //                       }
            //                       int? extractedID;
            //                       extractedID =
            //                           await databaseController.updateTodo(
            //                         fireStoreData,
            //                         {
            //                           'day': tasksController.date.value != null
            //                               ? Timestamp.fromDate(
            //                                   tasksController.date.value!)
            //                               : null,
            //                         },
            //                       );
            //                       notificationsController
            //                           .cancelNotification(extractedID);
            //                       //shchedule notification if date is selected and time is selected
            //                       if (tasksController.dateSelected.value &&
            //                           tasksController.date.value != null &&
            //                           tasksController.timeSelected.value &&
            //                           tasksController.time.value != null) {
            //                         notificationsController
            //                             .showScheduledNotification(
            //                           id: extractedID,
            //                           title: 'Task reminder',
            //                           body: todo.description,
            //                           scheduledTime: DateTime(
            //                               tasksController.date.value!.year,
            //                               tasksController.date.value!.month,
            //                               tasksController.date.value!.day,
            //                               tasksController.time.value!.hour,
            //                               tasksController.time.value!.minute,
            //                               0,
            //                               0,
            //                               0),
            //                         );
            //                       }
            //                       //schedule notofication if date is not selected and time is selected
            //                       if (!tasksController.dateSelected.value &&
            //                           tasksController.timeSelected.value &&
            //                           tasksController.time.value != null) {
            //                         notificationsController
            //                             .showScheduledNotification(
            //                           id: extractedID,
            //                           title: 'Task reminder',
            //                           body: todo.description,
            //                           scheduledTime: DateTime(
            //                               tasksController.time.value!.year,
            //                               tasksController.time.value!.month,
            //                               tasksController.time.value!.day,
            //                               tasksController.time.value!.hour,
            //                               tasksController.time.value!.minute,
            //                               0,
            //                               0,
            //                               0),
            //                         );
            //                       }
            //                       tasksController.date.value = null;
            //                       tasksController.dateSelected.value = false;
            //                       tasksController.time.value = null;
            //                       tasksController.timeSelected.value = false;

            //                       Get.back();
            //                     },
            //                     child: Text('changeDate'.tr),
            //                   ),
            //                   CupertinoActionSheetAction(
            //                     onPressed: () async {
            //                       categoriesController
            //                           .isTimeModalOpenedFromTasksScreen
            //                           .value = true;
            //                       if (fireStoreData.data().todoDate != null) {
            //                         tasksController.dateSelected.value = true;
            //                         tasksController.date.value =
            //                             fireStoreData.data().todoDate!.toDate();
            //                       }
            //                       if (fireStoreData.data().todoTime != null) {
            //                         tasksController.timeSelected.value = true;
            //                       }

            //                       await CupertinoRoundedDatePicker.show(
            //                         context,
            //                         minuteInterval: 5,
            //                         textColor: context.isDarkMode
            //                             ? Constants.kDarkThemeTextColor
            //                             : Constants.kBlackTextOnWhiteBGColor,
            //                         background: context.isDarkMode
            //                             ? Constants.kDarkThemeBGLightColor
            //                             : Constants.kWhiteBgColor,
            //                         use24hFormat: MediaQuery.of(context)
            //                             .alwaysUse24HourFormat,
            //                         initialDate: tasksController
            //                                     .timeSelected.value &&
            //                                 tasksController.time.value != null
            //                             ? tasksController.time.value
            //                             : DateTime.now()
            //                                 .roundUp(DateTime.now()),
            //                         initialDatePickerMode:
            //                             CupertinoDatePickerMode.time,
            //                         onDateTimeChanged: (selectedDateTime) {
            //                           tasksController.time.value =
            //                               selectedDateTime;
            //                         },
            //                       );
            //                       if (tasksController.time.value != null) {
            //                         tasksController.timeSelected.value = true;
            //                         if (tasksController.time.value!
            //                             .isBefore(DateTime.now())) {
            //                           tasksController.time.value =
            //                               tasksController.time.value!
            //                                   .add(const Duration(days: 1));
            //                         } else if (tasksController.time.value!
            //                             .isAfter(DateTime.now())) {
            //                           tasksController.time.value = DateTime(
            //                               DateTime.now().year,
            //                               DateTime.now().month,
            //                               DateTime.now().day,
            //                               tasksController.time.value!.hour,
            //                               tasksController.time.value!.minute);
            //                         }
            //                       }
            //                       int? extractedID;
            //                       extractedID =
            //                           await databaseController.updateTodo(
            //                         fireStoreData,
            //                         {
            //                           'time': tasksController.time.value != null
            //                               ? Timestamp.fromDate(
            //                                   tasksController.time.value!)
            //                               : null,
            //                         },
            //                       );
            //                       notificationsController
            //                           .cancelNotification(extractedID);
            //                       //shchedule notification if date is selected and time is selected
            //                       if (tasksController.dateSelected.value &&
            //                           tasksController.date.value != null &&
            //                           tasksController.timeSelected.value &&
            //                           tasksController.time.value != null) {
            //                         notificationsController
            //                             .showScheduledNotification(
            //                           id: extractedID,
            //                           title: 'Task reminder',
            //                           body: todo.description,
            //                           scheduledTime: DateTime(
            //                               tasksController.date.value!.year,
            //                               tasksController.date.value!.month,
            //                               tasksController.date.value!.day,
            //                               tasksController.time.value!.hour,
            //                               tasksController.time.value!.minute,
            //                               0,
            //                               0,
            //                               0),
            //                         );
            //                       }
            //                       //schedule notofication if date is not selected and time is selected
            //                       if (!tasksController.dateSelected.value &&
            //                           tasksController.timeSelected.value &&
            //                           tasksController.time.value != null) {
            //                         notificationsController
            //                             .showScheduledNotification(
            //                           id: extractedID,
            //                           title: 'Task reminder',
            //                           body: todo.description,
            //                           scheduledTime: DateTime(
            //                               tasksController.time.value!.year,
            //                               tasksController.time.value!.month,
            //                               tasksController.time.value!.day,
            //                               tasksController.time.value!.hour,
            //                               tasksController.time.value!.minute,
            //                               0,
            //                               0,
            //                               0),
            //                         );
            //                       }
            //                       tasksController.time.value = null;
            //                       tasksController.timeSelected.value = false;
            //                       tasksController.date.value = null;
            //                       tasksController.dateSelected.value = false;
            //                       Get.back();
            //                     },
            //                     child: Text('changeTime'.tr),
            //                   ),
            //                 ],
            //               );
            //             },
            //             context: context)
            //         : showDialog(
            //             context: context,
            //             barrierDismissible: true,
            //             builder: (BuildContext context) {
            //               return SimpleDialog(
            //                 titlePadding: const EdgeInsets.only(
            //                     top: 20, left: 20, right: 20),
            //                 titleTextStyle: TextStyle(
            //                     fontWeight: FontWeight.bold, fontSize: 20.sp),
            //                 title: Text('dateOrTime'.tr),
            //                 children: [
            //                   SimpleDialogOption(
            //                     onPressed: () async {
            //                       categoriesController
            //                           .isDateModalOpenedFromTasksScreen
            //                           .value = true;

            //                       if (fireStoreData.data().todoDate != null) {
            //                         tasksController.dateSelected.value = true;
            //                       }
            //                       if (fireStoreData.data().todoTime != null) {
            //                         tasksController.timeSelected.value = true;
            //                         tasksController.time.value =
            //                             fireStoreData.data().todoTime!.toDate();
            //                       }
            //                       tasksController.date.value =
            //                           await showRoundedDatePicker(
            //                         context: context,
            //                         initialDate: tasksController.date.value,
            //                         listDateDisabled: helpers.getDaysInBeteween(
            //                             DateTime(DateTime.now().year,
            //                                 DateTime.now().month, 1),
            //                             DateTime.now()),
            //                         firstDate: DateTime(
            //                             DateTime.now().year,
            //                             DateTime.now().month,
            //                             DateTime.now().day,
            //                             0,
            //                             0,
            //                             0),
            //                         lastDate: DateTime(
            //                             DateTime.now().year + 2, 12, 31),
            //                         locale: Get.deviceLocale,
            //                         customWeekDays: DateFormat.EEEE(
            //                                 Get.deviceLocale!.languageCode)
            //                             .dateSymbols
            //                             .SHORTWEEKDAYS,
            //                         height: 380,
            //                         textActionButton: "DELETE DATE",
            //                         onTapActionButton: () {
            //                           Navigator.of(context).pop(null);
            //                           tasksController.dateSelected.value =
            //                               false;
            //                           tasksController.date.value = null;
            //                         },
            //                         theme: ThemeData(
            //                           primaryColor: context.isDarkMode
            //                               ? Constants.kDarkThemeBGColor
            //                               : Constants.kLightGrayColor2,
            //                         ),
            //                         styleDatePicker:
            //                             MaterialRoundedDatePickerStyle(
            //                           textStyleDayButton: TextStyle(
            //                             fontSize: 35,
            //                             color: context.isDarkMode
            //                                 ? Constants.kDarkThemeTextColor
            //                                 : Constants.kAlternativeTextColor,
            //                           ),
            //                           textStyleYearButton: TextStyle(
            //                             fontSize: 35,
            //                             color: context.isDarkMode
            //                                 ? Constants.kDarkThemeTextColor
            //                                 : Constants.kAlternativeTextColor,
            //                           ),
            //                           textStyleDayHeader: TextStyle(
            //                             fontSize: 15,
            //                             color: context.isDarkMode
            //                                 ? Constants
            //                                     .kDarkThemeTextColorAlternative
            //                                     .withOpacity(0.5)
            //                                 : Constants.kBlackTextOnWhiteBGColor
            //                                     .withOpacity(0.5),
            //                           ),
            //                           textStyleCurrentDayOnCalendar: TextStyle(
            //                               fontSize: 25,
            //                               color: context.isDarkMode
            //                                   ? Constants.kDarkThemeAccentColor
            //                                   : Constants.kAccentColor,
            //                               fontWeight: FontWeight.bold),
            //                           textStyleDayOnCalendar: TextStyle(
            //                             fontSize: 17,
            //                             color: context.isDarkMode
            //                                 ? Constants
            //                                     .kDarkThemeTextColorAlternative
            //                                 : Constants.kAlternativeTextColor,
            //                           ),
            //                           textStyleDayOnCalendarSelected:
            //                               const TextStyle(
            //                             fontSize: 26,
            //                             color: Colors.white,
            //                             fontWeight: FontWeight.bold,
            //                           ),
            //                           textStyleDayOnCalendarDisabled: TextStyle(
            //                             fontSize: 17,
            //                             color: context.isDarkMode
            //                                 ? Constants
            //                                     .kDarkThemeTextColorAlternative
            //                                     .withOpacity(0.3)
            //                                 : Constants.kAlternativeTextColor
            //                                     .withOpacity(0.3),
            //                           ),
            //                           textStyleMonthYearHeader: TextStyle(
            //                             fontSize: 21,
            //                             color: context.isDarkMode
            //                                 ? Constants
            //                                     .kDarkThemeTextColorAlternative
            //                                 : Constants
            //                                     .kBlackTextOnWhiteBGColor,
            //                             fontWeight: FontWeight.bold,
            //                           ),
            //                           paddingDatePicker:
            //                               const EdgeInsets.all(0),
            //                           paddingMonthHeader:
            //                               const EdgeInsets.all(15),
            //                           paddingActionBar: const EdgeInsets.all(0),
            //                           paddingDateYearHeader:
            //                               const EdgeInsets.all(0),
            //                           arrowIconLeft: CustomIcons.arrowLeft,
            //                           arrowIconRight: CustomIcons.arrowRight,
            //                           sizeArrow: 20,
            //                           colorArrowNext: context.isDarkMode
            //                               ? Constants
            //                                   .kDarkThemeTextColorAlternative
            //                               : Constants.kBlackTextOnWhiteBGColor,
            //                           colorArrowPrevious: context.isDarkMode
            //                               ? Constants
            //                                   .kDarkThemeTextColorAlternative
            //                               : Constants.kBlackTextOnWhiteBGColor,
            //                           marginLeftArrowPrevious: 15,
            //                           marginTopArrowPrevious: 15,
            //                           marginTopArrowNext: 15,
            //                           marginRightArrowNext: 15,
            //                           textStyleButtonAction: TextStyle(
            //                               fontSize: 15,
            //                               color: context.isDarkMode
            //                                   ? Constants
            //                                       .kDarkThemeTextColorAlternative
            //                                   : Constants
            //                                       .kBlackTextOnWhiteBGColor,
            //                               fontWeight: FontWeight.bold),
            //                           textStyleButtonPositive: TextStyle(
            //                               fontSize: 15,
            //                               color: context.isDarkMode
            //                                   ? Constants
            //                                       .kDarkThemeTextColorAlternative
            //                                   : Constants
            //                                       .kBlackTextOnWhiteBGColor,
            //                               fontWeight: FontWeight.bold),
            //                           textStyleButtonNegative: TextStyle(
            //                             fontSize: 15,
            //                             color: context.isDarkMode
            //                                 ? Constants
            //                                     .kDarkThemeTextColorAlternative
            //                                     .withOpacity(0.6)
            //                                 : Constants.kBlackTextOnWhiteBGColor
            //                                     .withOpacity(0.6),
            //                           ),
            //                           decorationDateSelected: BoxDecoration(
            //                             color: context.isDarkMode
            //                                 ? Constants.kDarkThemeAccentColor
            //                                 : Constants.kAccentColor,
            //                             shape: BoxShape.circle,
            //                           ),
            //                           backgroundPicker: context.isDarkMode
            //                               ? Constants.kDarkThemeBGLightColor
            //                               : Constants.kWhiteBgColor,
            //                           backgroundActionBar: context.isDarkMode
            //                               ? Constants.kDarkThemeBGLightColor
            //                               : Constants.kWhiteBgColor,
            //                           backgroundHeaderMonth: context.isDarkMode
            //                               ? Constants.kDarkThemeBGLightColor
            //                               : Constants.kWhiteBgColor,
            //                         ),
            //                         styleYearPicker:
            //                             MaterialRoundedYearPickerStyle(
            //                           textStyleYear: TextStyle(
            //                             fontSize: 40,
            //                             color: context.isDarkMode
            //                                 ? Constants.kDarkThemeTextColor
            //                                 : Constants.kAlternativeTextColor,
            //                           ),
            //                           textStyleYearSelected: TextStyle(
            //                               fontSize: 56,
            //                               color: context.isDarkMode
            //                                   ? Constants.kDarkThemeAccentColor
            //                                   : Constants.kAccentColor,
            //                               fontWeight: FontWeight.bold),
            //                           heightYearRow: 100,
            //                           backgroundPicker: context.isDarkMode
            //                               ? Constants.kDarkThemeBGLightColor
            //                               : Constants.kWhiteBgColor,
            //                         ),
            //                       );

            //                       // if (tasksController.date.value != null) {
            //                       //   tasksController.dateSelected.value = true;
            //                       // }
            //                       categoriesController
            //                           .isDateModalOpenedFromTasksScreen
            //                           .value = false;
            //                       //Since we change only the date (without time) it would be logical to change to Date to tasksController.date.value + 23:59:59
            //                       // because otherwise we take the current time and todo becomes instantly overdue

            //                       if (tasksController.date.value != null &&
            //                           tasksController.date.value!.isToday) {
            //                         //TODO change custom hour, minute and blablabla to a variable that is the endOfTheDay which should be present in TasksController somewhere in the future

            //                         int newHour = 23;
            //                         int newMinute = 59;
            //                         int newSecond = 59;
            //                         tasksController.date.value =
            //                             tasksController.date.value!.toLocal();
            //                         tasksController.date.value = DateTime(
            //                             tasksController.date.value!.year,
            //                             tasksController.date.value!.month,
            //                             tasksController.date.value!.day,
            //                             newHour,
            //                             newMinute,
            //                             newSecond,
            //                             tasksController
            //                                 .date.value!.millisecond);
            //                       }
            //                       int? extractedID;
            //                       extractedID =
            //                           await databaseController.updateTodo(
            //                         fireStoreData,
            //                         {
            //                           'day': tasksController.date.value != null
            //                               ? Timestamp.fromDate(
            //                                   tasksController.date.value!)
            //                               : null,
            //                         },
            //                       );
            //                       notificationsController
            //                           .cancelNotification(extractedID);
            //                       //shchedule notification if date is selected and time is selected
            //                       if (tasksController.dateSelected.value &&
            //                           tasksController.date.value != null &&
            //                           tasksController.timeSelected.value &&
            //                           tasksController.time.value != null) {
            //                         notificationsController
            //                             .showScheduledNotification(
            //                           id: extractedID,
            //                           title: 'Task reminder',
            //                           body: todo.description,
            //                           scheduledTime: DateTime(
            //                               tasksController.date.value!.year,
            //                               tasksController.date.value!.month,
            //                               tasksController.date.value!.day,
            //                               tasksController.time.value!.hour,
            //                               tasksController.time.value!.minute,
            //                               0,
            //                               0,
            //                               0),
            //                         );
            //                       }
            //                       //schedule notofication if date is not selected and time is selected
            //                       if (!tasksController.dateSelected.value &&
            //                           tasksController.timeSelected.value &&
            //                           tasksController.time.value != null) {
            //                         notificationsController
            //                             .showScheduledNotification(
            //                           id: extractedID,
            //                           title: 'Task reminder',
            //                           body: todo.description,
            //                           scheduledTime: DateTime(
            //                               tasksController.time.value!.year,
            //                               tasksController.time.value!.month,
            //                               tasksController.time.value!.day,
            //                               tasksController.time.value!.hour,
            //                               tasksController.time.value!.minute,
            //                               0,
            //                               0,
            //                               0),
            //                         );
            //                       }
            //                       tasksController.date.value = null;
            //                       tasksController.dateSelected.value = false;
            //                       tasksController.time.value = null;
            //                       tasksController.timeSelected.value = false;
            //                       Get.back();
            //                     },
            //                     child: Row(
            //                       mainAxisAlignment: MainAxisAlignment.start,
            //                       crossAxisAlignment: CrossAxisAlignment.center,
            //                       children: [
            //                         const Icon(
            //                           Icons.calendar_today_outlined,
            //                           size: 25,
            //                         ),
            //                         Flexible(
            //                           child: Padding(
            //                             padding:
            //                                 const EdgeInsetsDirectional.only(
            //                                     start: 16),
            //                             child: Text(
            //                               'changeDate'.tr,
            //                               style: TextStyle(fontSize: 14.sp),
            //                             ),
            //                           ),
            //                         ),
            //                       ],
            //                     ),
            //                   ),
            //                   SimpleDialogOption(
            //                     onPressed: () async {
            //                       categoriesController
            //                           .isTimeModalOpenedFromTasksScreen
            //                           .value = true;
            //                       if (fireStoreData.data().todoDate != null) {
            //                         tasksController.dateSelected.value = true;
            //                         tasksController.date.value =
            //                             fireStoreData.data().todoDate!.toDate();
            //                       }
            //                       if (fireStoreData.data().todoTime != null) {
            //                         tasksController.timeSelected.value = true;
            //                       }
            //                       tasksController.time.value =
            //                           await CupertinoRoundedDatePicker.show(
            //                         context,
            //                         minuteInterval: 5,
            //                         textColor: context.isDarkMode
            //                             ? Constants.kDarkThemeTextColor
            //                             : Constants.kBlackTextOnWhiteBGColor,
            //                         background: context.isDarkMode
            //                             ? Constants.kDarkThemeBGLightColor
            //                             : Constants.kWhiteBgColor,
            //                         use24hFormat: MediaQuery.of(context)
            //                             .alwaysUse24HourFormat,
            //                         initialDate: tasksController
            //                                     .timeSelected.value &&
            //                                 tasksController.time.value != null
            //                             ? tasksController.time.value
            //                             : DateTime.now()
            //                                 .roundUp(DateTime.now()),
            //                         initialDatePickerMode:
            //                             CupertinoDatePickerMode.time,
            //                         onDateTimeChanged: (selectedDateTime) {
            //                           tasksController.time.value =
            //                               selectedDateTime;
            //                         },
            //                       );
            //                       int? extractedID;
            //                       extractedID =
            //                           await databaseController.updateTodo(
            //                         fireStoreData,
            //                         {
            //                           'time': tasksController.time.value != null
            //                               ? Timestamp.fromDate(
            //                                   tasksController.time.value!)
            //                               : null,
            //                         },
            //                       );
            //                       notificationsController
            //                           .cancelNotification(extractedID);
            //                       //shchedule notification if date is selected and time is selected
            //                       if (tasksController.dateSelected.value &&
            //                           tasksController.date.value != null &&
            //                           tasksController.timeSelected.value &&
            //                           tasksController.time.value != null) {
            //                         notificationsController
            //                             .showScheduledNotification(
            //                           id: extractedID,
            //                           title: 'Task reminder',
            //                           body: todo.description,
            //                           scheduledTime: DateTime(
            //                               tasksController.date.value!.year,
            //                               tasksController.date.value!.month,
            //                               tasksController.date.value!.day,
            //                               tasksController.time.value!.hour,
            //                               tasksController.time.value!.minute,
            //                               0,
            //                               0,
            //                               0),
            //                         );
            //                       }
            //                       //schedule notofication if date is not selected and time is selected
            //                       if (!tasksController.dateSelected.value &&
            //                           tasksController.timeSelected.value &&
            //                           tasksController.time.value != null) {
            //                         notificationsController
            //                             .showScheduledNotification(
            //                           id: extractedID,
            //                           title: 'Task reminder',
            //                           body: todo.description,
            //                           scheduledTime: DateTime(
            //                               tasksController.time.value!.year,
            //                               tasksController.time.value!.month,
            //                               tasksController.time.value!.day,
            //                               tasksController.time.value!.hour,
            //                               tasksController.time.value!.minute,
            //                               0,
            //                               0,
            //                               0),
            //                         );
            //                       }
            //                       tasksController.time.value = null;
            //                       tasksController.timeSelected.value = false;
            //                       tasksController.date.value = null;
            //                       tasksController.dateSelected.value = false;
            //                       Get.back();
            //                     },
            //                     child: Row(
            //                       mainAxisAlignment: MainAxisAlignment.start,
            //                       crossAxisAlignment: CrossAxisAlignment.center,
            //                       children: [
            //                         const Icon(
            //                           Icons.timer_outlined,
            //                           size: 25,
            //                         ),
            //                         Flexible(
            //                           child: Padding(
            //                             padding:
            //                                 const EdgeInsetsDirectional.only(
            //                                     start: 16),
            //                             child: Text(
            //                               'changeTime'.tr,
            //                               style: TextStyle(fontSize: 14.sp),
            //                             ),
            //                           ),
            //                         ),
            //                       ],
            //                     ),
            //                   ),
            //                 ],
            //               );
            //             },
            //           );
            //   },
            // ),
          ],
        ),
        endActionPane: ActionPane(
          dragDismissible: false,
          dismissible: DismissiblePane(
            onDismissed: () {},
          ),
          extentRatio: 0.5,
          motion: const BehindMotion(),
          children: [
            MySlidableAction(
              spacing: 10,
              foregroundColor: Constants.kWhiteBgColor,
              label: 'edit'.tr,
              labelStyle: const TextStyle(
                fontSize: 11,
                //color: Constants.kPrimaryTextColor,
                fontWeight: FontWeight.bold,
              ),
              backgroundColor: Constants.kLightGrayColor,
              icon: Icons.edit_outlined,
              iconSize: 25,
              onPressed: (context) {
                tasksController.todoOpenedFromTasksScreen.value = true;
                showBarModalBottomSheet(
                  isDismissible: false,
                  enableDrag: false,
                  expand: true,
                  context: context,
                  topControl: Material(
                    color: Colors.transparent,
                    child: IconButton(
                      splashRadius: 1,
                      visualDensity: VisualDensity.compact,
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.keyboard_arrow_down),
                      iconSize: 30.0,
                    ),
                  ),
                  backgroundColor: Colors.transparent,
                  builder: (context) => TaskModalView(
                    fireStoreData: fireStoreData,
                    category: firestoreCategoryData,
                    categoryReferenceID: categoryReferenceID,
                  ),
                );
              },
            ),
            MySlidableAction(
              spacing: 10,
              label: 'delete'.tr,
              backgroundColor: Colors.red,
              labelStyle: const TextStyle(
                fontSize: 11,
                //color: Constants.kPrimaryTextColor,
                fontWeight: FontWeight.bold,
              ),
              icon: CustomIcons.trashCan,
              iconSize: 25,
              onPressed: (context) async {
                databaseController.deleteTodo(fireStoreData);
              },
            ),
          ],
        ),
        child: Material(
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(stops: const [
                0.015,
                0.015
              ], colors: [
                color == null
                    ? context.isDarkMode
                        ? Constants.kDarkThemeWhiteAccentColor
                        : Constants.kAlternativeTextColor
                    : Color(color!),
                context.isDarkMode
                    ? todo.isDone == true
                        ? Constants.kDarkThemeTodoIsDoneColor
                        : Constants.kDarkThemeBGLightColor
                    : todo.isDone == true
                        ? Constants.kLightThemeTodoIsDoneColor
                        : Constants.kWhiteBgColor,
              ]),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.only(right: 20.0),
              horizontalTitleGap: 0,
              minVerticalPadding: 0,
              onTap: () {
                tasksController.todoOpenedFromTasksScreen.value = true;
                showBarModalBottomSheet(
                  isDismissible: false,
                  enableDrag: false,
                  expand: true,
                  context: context,
                  topControl: Material(
                    color: Colors.transparent,
                    child: IconButton(
                      splashRadius: 1,
                      visualDensity: VisualDensity.compact,
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.keyboard_arrow_down),
                      iconSize: 30.0,
                    ),
                  ),
                  backgroundColor: Colors.transparent,
                  builder: (context) => TaskModalView(
                    fireStoreData: fireStoreData,
                    category: firestoreCategoryData,
                    categoryReferenceID: categoryReferenceID,
                  ),
                );
              },
              leading: Checkbox(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
                fillColor: MaterialStateProperty.all(context.isDarkMode
                    ? Constants.kDarkThemeAccentColor
                    : Constants.kAccentColor),
                value: todo.isDone,
                onChanged: (value) async {
                  todo.isDone = value;

                  int? todoID;
                  todoID = await databaseController.updateTodo(fireStoreData, {
                    'isDone': value,
                    'whenCompleted': Timestamp.fromDate(
                      DateTime(
                        DateTime.now().year,
                        DateTime.now().month,
                        DateTime.now().day,
                      ),
                    ),
                  });
                  if (value == true) {
                    notificationsController.cancelNotification(todoID);
                  }
                },
              ),
              title: Text(
                todo.description!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: todo.subTodos != null && todo.subTodos!.isNotEmpty
                  ? const Icon(Icons.list_outlined)
                  : null,
              subtitle: todo.todoDate == null && todo.todoTime == null
                  ? null
                  : (() {
                      DateTime? parsedDate;
                      DateTime? parsedTime;
                      String? formattedDate;
                      if (todo.todoDate != null) {
                        parsedDate = todo.todoDate!.toDate();
                        formattedDate = DateFormat.MMMd(Platform.localeName)
                            .format(parsedDate);
                      }
                      if (todo.todoTime != null) {
                        parsedTime = todo.todoTime?.toDate();
                      }

                      if (parsedDate != null && parsedTime == null) {
                        if (parsedDate.isOnCurrentWeek(parsedDate, context)) {
                          if (parsedDate.isToday &&
                              parsedDate.isAfter(DateTime.now())) {
                            return Text('today'.tr);
                          } else if (parsedDate.isTomorrow) {
                            return Text('tomorrow'.tr);
                          } else {
                            return Text(formattedDate!);
                          }
                        } else if (parsedDate.isAfter(DateTime.now())) {
                          return Text(formattedDate!);
                        } else {
                          return Text('overdue'.tr);
                        }
                      } else if (parsedDate != null && parsedTime != null) {
                        var datePlusTime = DateTime(
                            parsedDate.year,
                            parsedDate.month,
                            parsedDate.day,
                            parsedTime.hour,
                            parsedTime.minute);

                        if (datePlusTime.isBefore(DateTime.now())) {
                          return Text('overdue'.tr);
                        } else {
                          return Row(
                            children: [
                              const Icon(
                                CustomIcons.bell,
                                size: 12.0,
                              ),
                              const SizedBox(
                                width: 10.0,
                              ),
                              MediaQuery.of(context).alwaysUse24HourFormat
                                  ? Text(
                                      '$formattedDate ${'at'.tr} ${DateFormat.Hm().format(parsedTime)}')
                                  : Text(
                                      '$formattedDate ${'at'.tr} ${DateFormat.jm().format(parsedTime)}'),
                            ],
                          );
                        }
                      } else {
                        var timeString = DateFormat.Hm().format(parsedTime!);

                        if (parsedTime.isToday &&
                            !parsedTime.isBefore(DateTime.now())) {
                          return Row(
                            children: [
                              const Icon(
                                CustomIcons.bell,
                                size: 12.0,
                              ),
                              const SizedBox(
                                width: 10.0,
                              ),
                              Text('${'remindToday'.tr} $timeString'),
                            ],
                          );
                        } else if (parsedTime.isTomorrow) {
                          return Row(
                            children: [
                              const Icon(
                                CustomIcons.bell,
                                size: 12.0,
                              ),
                              const SizedBox(
                                width: 10.0,
                              ),
                              Text('${'remindTomorrow'.tr} $timeString'),
                            ],
                          );
                        } else {
                          return Text('overdue'.tr);
                        }
                      }
                    }()),
            ),
          ),
        ),
      ),
    );
  }
}
