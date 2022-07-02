import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:todozoid2/controllers/notifications_controller.dart';
import 'package:todozoid2/helpers/time_extensions.dart';
import 'package:todozoid2/helpers/helpers.dart' as helpers;
import '../Database/database.dart';
import '../consts/consts.dart';
import '../controllers/categories_controller.dart';
import '../controllers/tasks_controller.dart';
import '../helpers/custom_icons_icons.dart';
import '../models/category.dart';
import '../models/todo.dart';
import 'calendar picker/src/cupertino_rounded_date_picker.dart';
import 'calendar picker/src/flutter_rounded_date_picker_widget.dart';
import 'calendar picker/src/material_rounded_date_picker_style.dart';
import 'calendar picker/src/material_rounded_year_picker_style.dart';
import 'categories_modal_fit.dart';
import 'create_tast_modal.dart';
import 'custom_fadeout_particle/src/fade_out_particle.dart';
import 'custom_slidable_action.dart';

class Item extends StatefulWidget {
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
  State<Item> createState() => _ItemState();
}

class _ItemState extends State<Item> {
  bool isPressed = false;

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
          extentRatio: 0.5,
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
                widget.categoriesController.isCategoryModalOpenedFromTasksScreen
                    .value = true;
                await Get.bottomSheet(
                  CategoriesModalFit(
                    queryData: widget.fireStoreData,
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
            MySlidableAction(
              spacing: 10,
              foregroundColor: Constants.kWhiteBgColor,
              label: 'when'.tr,
              labelStyle: const TextStyle(
                fontSize: 11,
                //color: Constants.kPrimaryTextColor,
                fontWeight: FontWeight.bold,
              ),
              backgroundColor: Colors.yellow.shade700,
              icon: Icons.date_range_outlined,
              iconSize: 30,
              onPressed: (context) async {
                Platform.isIOS
                    ? showCupertinoModalPopup(
                        builder: (BuildContext context) {
                          return CupertinoActionSheet(
                            cancelButton: CupertinoActionSheetAction(
                              onPressed: () {
                                Get.back();
                              },
                              isDestructiveAction: true,
                              isDefaultAction: true,
                              child: Text('cancel'.tr),
                            ),
                            title: Text('dateOrTime'.tr),
                            actions: [
                              CupertinoActionSheetAction(
                                onPressed: () async {
                                  widget
                                      .categoriesController
                                      .isDateModalOpenedFromTasksScreen
                                      .value = true;
                                  if (widget.fireStoreData.data().todoDate !=
                                      null) {
                                    widget.tasksController.dateSelected.value =
                                        true;
                                  }
                                  if (widget.fireStoreData.data().todoTime !=
                                      null) {
                                    widget.tasksController.timeSelected.value =
                                        true;
                                    widget.tasksController.time.value = widget
                                        .fireStoreData
                                        .data()
                                        .todoTime!
                                        .toDate();
                                  }
                                  widget.tasksController.date.value =
                                      await showRoundedDatePicker(
                                    context: context,
                                    initialDate:
                                        widget.tasksController.date.value,
                                    listDateDisabled: helpers.getDaysInBeteween(
                                        DateTime(DateTime.now().year,
                                            DateTime.now().month, 1),
                                        DateTime.now()),
                                    firstDate: DateTime(
                                        DateTime.now().year,
                                        DateTime.now().month,
                                        DateTime.now().day,
                                        0,
                                        0,
                                        0),
                                    lastDate: DateTime(
                                        DateTime.now().year + 2, 12, 31),
                                    locale: Get.deviceLocale,
                                    customWeekDays: DateFormat.EEEE(
                                            Get.deviceLocale!.languageCode)
                                        .dateSymbols
                                        .SHORTWEEKDAYS,
                                    height: 380,
                                    textActionButton: "DELETE DATE",
                                    onTapActionButton: () {
                                      Navigator.of(context).pop(null);
                                      widget.tasksController.dateSelected
                                          .value = false;
                                      widget.tasksController.date.value = null;
                                    },
                                    theme: ThemeData(
                                      primaryColor: context.isDarkMode
                                          ? Constants.kDarkThemeBGColor
                                          : Constants.kLightGrayColor2,
                                    ),
                                    styleDatePicker:
                                        MaterialRoundedDatePickerStyle(
                                      textStyleDayButton: TextStyle(
                                        fontSize: 35,
                                        color: context.isDarkMode
                                            ? Constants.kDarkThemeTextColor
                                            : Constants.kAlternativeTextColor,
                                      ),
                                      textStyleYearButton: TextStyle(
                                        fontSize: 35,
                                        color: context.isDarkMode
                                            ? Constants.kDarkThemeTextColor
                                            : Constants.kAlternativeTextColor,
                                      ),
                                      textStyleDayHeader: TextStyle(
                                        fontSize: 15,
                                        color: context.isDarkMode
                                            ? Constants
                                                .kDarkThemeTextColorAlternative
                                                .withOpacity(0.5)
                                            : Constants.kBlackTextOnWhiteBGColor
                                                .withOpacity(0.5),
                                      ),
                                      textStyleCurrentDayOnCalendar: TextStyle(
                                          fontSize: 25,
                                          color: context.isDarkMode
                                              ? Constants.kDarkThemeAccentColor
                                              : Constants.kAccentColor,
                                          fontWeight: FontWeight.bold),
                                      textStyleDayOnCalendar: TextStyle(
                                        fontSize: 17,
                                        color: context.isDarkMode
                                            ? Constants
                                                .kDarkThemeTextColorAlternative
                                            : Constants.kAlternativeTextColor,
                                      ),
                                      textStyleDayOnCalendarSelected:
                                          const TextStyle(
                                        fontSize: 26,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textStyleDayOnCalendarDisabled: TextStyle(
                                        fontSize: 17,
                                        color: context.isDarkMode
                                            ? Constants
                                                .kDarkThemeTextColorAlternative
                                                .withOpacity(0.3)
                                            : Constants.kAlternativeTextColor
                                                .withOpacity(0.3),
                                      ),
                                      textStyleMonthYearHeader: TextStyle(
                                        fontSize: 21,
                                        color: context.isDarkMode
                                            ? Constants
                                                .kDarkThemeTextColorAlternative
                                            : Constants
                                                .kBlackTextOnWhiteBGColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      paddingDatePicker:
                                          const EdgeInsets.all(0),
                                      paddingMonthHeader:
                                          const EdgeInsets.all(15),
                                      paddingActionBar: const EdgeInsets.all(0),
                                      paddingDateYearHeader:
                                          const EdgeInsets.all(0),
                                      arrowIconLeft: CustomIcons.arrowLeft,
                                      arrowIconRight: CustomIcons.arrowRight,
                                      sizeArrow: 20,
                                      colorArrowNext: context.isDarkMode
                                          ? Constants
                                              .kDarkThemeTextColorAlternative
                                          : Constants.kBlackTextOnWhiteBGColor,
                                      colorArrowPrevious: context.isDarkMode
                                          ? Constants
                                              .kDarkThemeTextColorAlternative
                                          : Constants.kBlackTextOnWhiteBGColor,
                                      marginLeftArrowPrevious: 15,
                                      marginTopArrowPrevious: 15,
                                      marginTopArrowNext: 15,
                                      marginRightArrowNext: 15,
                                      textStyleButtonAction: TextStyle(
                                          fontSize: 15,
                                          color: context.isDarkMode
                                              ? Constants
                                                  .kDarkThemeTextColorAlternative
                                              : Constants
                                                  .kBlackTextOnWhiteBGColor,
                                          fontWeight: FontWeight.bold),
                                      textStyleButtonPositive: TextStyle(
                                          fontSize: 15,
                                          color: context.isDarkMode
                                              ? Constants
                                                  .kDarkThemeTextColorAlternative
                                              : Constants
                                                  .kBlackTextOnWhiteBGColor,
                                          fontWeight: FontWeight.bold),
                                      textStyleButtonNegative: TextStyle(
                                        fontSize: 15,
                                        color: context.isDarkMode
                                            ? Constants
                                                .kDarkThemeTextColorAlternative
                                                .withOpacity(0.6)
                                            : Constants.kBlackTextOnWhiteBGColor
                                                .withOpacity(0.6),
                                      ),
                                      decorationDateSelected: BoxDecoration(
                                        color: context.isDarkMode
                                            ? Constants.kDarkThemeAccentColor
                                            : Constants.kAccentColor,
                                        shape: BoxShape.circle,
                                      ),
                                      backgroundPicker: context.isDarkMode
                                          ? Constants.kDarkThemeBGLightColor
                                          : Constants.kWhiteBgColor,
                                      backgroundActionBar: context.isDarkMode
                                          ? Constants.kDarkThemeBGLightColor
                                          : Constants.kWhiteBgColor,
                                      backgroundHeaderMonth: context.isDarkMode
                                          ? Constants.kDarkThemeBGLightColor
                                          : Constants.kWhiteBgColor,
                                    ),
                                    styleYearPicker:
                                        MaterialRoundedYearPickerStyle(
                                      textStyleYear: TextStyle(
                                        fontSize: 40,
                                        color: context.isDarkMode
                                            ? Constants.kDarkThemeTextColor
                                            : Constants.kAlternativeTextColor,
                                      ),
                                      textStyleYearSelected: TextStyle(
                                          fontSize: 56,
                                          color: context.isDarkMode
                                              ? Constants.kDarkThemeAccentColor
                                              : Constants.kAccentColor,
                                          fontWeight: FontWeight.bold),
                                      heightYearRow: 100,
                                      backgroundPicker: context.isDarkMode
                                          ? Constants.kDarkThemeBGLightColor
                                          : Constants.kWhiteBgColor,
                                    ),
                                  );

                                  widget
                                      .categoriesController
                                      .isDateModalOpenedFromTasksScreen
                                      .value = false;
                                  //Since we change only the date (without time) it would be logical to change the Date to tasksController.date.value + 23:59:59
                                  // because otherwise we take the current time and todo becomes instantly overdue

                                  if (widget.tasksController.date.value !=
                                          null &&
                                      widget.tasksController.date.value!
                                          .isToday) {
                                    //TODO change custom hour, minute and blablabla to a variable that is the endOfTheDay which should be present in TasksController somewhere in the future

                                    int newHour = 23;
                                    int newMinute = 59;
                                    int newSecond = 59;
                                    widget.tasksController.date.value = widget
                                        .tasksController.date.value!
                                        .toLocal();
                                    widget.tasksController.date.value =
                                        DateTime(
                                            widget.tasksController.date.value!
                                                .year,
                                            widget.tasksController.date.value!
                                                .month,
                                            widget.tasksController.date.value!
                                                .day,
                                            newHour,
                                            newMinute,
                                            newSecond,
                                            widget.tasksController.date.value!
                                                .millisecond);
                                  }
                                  int? extractedID;
                                  extractedID = await widget.databaseController
                                      .updateTodo(
                                    widget.fireStoreData,
                                    {
                                      'day':
                                          widget.tasksController.date.value !=
                                                  null
                                              ? Timestamp.fromDate(widget
                                                  .tasksController.date.value!)
                                              : null,
                                    },
                                  );
                                  widget.notificationsController
                                      .cancelNotification(extractedID);
                                  //shchedule notification if date is selected and time is selected
                                  if (widget.tasksController.dateSelected.value &&
                                      widget.tasksController.date.value !=
                                          null &&
                                      widget
                                          .tasksController.timeSelected.value &&
                                      widget.tasksController.time.value !=
                                          null) {
                                    widget.notificationsController
                                        .showScheduledNotification(
                                      id: extractedID,
                                      title: 'Task reminder',
                                      body: widget.todo.description,
                                      scheduledTime: DateTime(
                                          widget
                                              .tasksController.date.value!.year,
                                          widget.tasksController.date.value!
                                              .month,
                                          widget
                                              .tasksController.date.value!.day,
                                          widget
                                              .tasksController.time.value!.hour,
                                          widget.tasksController.time.value!
                                              .minute,
                                          0,
                                          0,
                                          0),
                                    );
                                  }
                                  //schedule notofication if date is not selected and time is selected
                                  if (!widget
                                          .tasksController.dateSelected.value &&
                                      widget
                                          .tasksController.timeSelected.value &&
                                      widget.tasksController.time.value !=
                                          null) {
                                    widget.notificationsController
                                        .showScheduledNotification(
                                      id: extractedID,
                                      title: 'Task reminder',
                                      body: widget.todo.description,
                                      scheduledTime: DateTime(
                                          widget
                                              .tasksController.time.value!.year,
                                          widget.tasksController.time.value!
                                              .month,
                                          widget
                                              .tasksController.time.value!.day,
                                          widget
                                              .tasksController.time.value!.hour,
                                          widget.tasksController.time.value!
                                              .minute,
                                          0,
                                          0,
                                          0),
                                    );
                                  }
                                  widget.tasksController.date.value = null;
                                  widget.tasksController.dateSelected.value =
                                      false;
                                  widget.tasksController.time.value = null;
                                  widget.tasksController.timeSelected.value =
                                      false;

                                  Get.back();
                                },
                                child: Text('changeDate'.tr),
                              ),
                              CupertinoActionSheetAction(
                                onPressed: () async {
                                  widget
                                      .categoriesController
                                      .isTimeModalOpenedFromTasksScreen
                                      .value = true;
                                  if (widget.fireStoreData.data().todoDate !=
                                      null) {
                                    widget.tasksController.dateSelected.value =
                                        true;
                                    widget.tasksController.date.value = widget
                                        .fireStoreData
                                        .data()
                                        .todoDate!
                                        .toDate();
                                  }
                                  if (widget.fireStoreData.data().todoTime !=
                                      null) {
                                    widget.tasksController.timeSelected.value =
                                        true;
                                  }

                                  await CupertinoRoundedDatePicker.show(
                                    context,
                                    minuteInterval: 5,
                                    textColor: context.isDarkMode
                                        ? Constants.kDarkThemeTextColor
                                        : Constants.kBlackTextOnWhiteBGColor,
                                    background: context.isDarkMode
                                        ? Constants.kDarkThemeBGLightColor
                                        : Constants.kWhiteBgColor,
                                    use24hFormat: MediaQuery.of(context)
                                        .alwaysUse24HourFormat,
                                    initialDate: widget.tasksController
                                                .timeSelected.value &&
                                            widget.tasksController.time.value !=
                                                null
                                        ? widget.tasksController.time.value
                                        : DateTime.now()
                                            .roundUp(DateTime.now()),
                                    initialDatePickerMode:
                                        CupertinoDatePickerMode.time,
                                    onDateTimeChanged: (selectedDateTime) {
                                      widget.tasksController.time.value =
                                          selectedDateTime;
                                    },
                                  );
                                  if (widget.tasksController.time.value !=
                                      null) {
                                    widget.tasksController.timeSelected.value =
                                        true;
                                    if (widget.tasksController.time.value!
                                        .isBefore(DateTime.now())) {
                                      widget.tasksController.time.value = widget
                                          .tasksController.time.value!
                                          .add(const Duration(days: 1));
                                    } else if (widget
                                        .tasksController.time.value!
                                        .isAfter(DateTime.now())) {
                                      widget.tasksController.time.value =
                                          DateTime(
                                              DateTime.now().year,
                                              DateTime.now().month,
                                              DateTime.now().day,
                                              widget.tasksController.time.value!
                                                  .hour,
                                              widget.tasksController.time.value!
                                                  .minute);
                                    }
                                  }
                                  int? extractedID;
                                  extractedID = await widget.databaseController
                                      .updateTodo(
                                    widget.fireStoreData,
                                    {
                                      'time':
                                          widget.tasksController.time.value !=
                                                  null
                                              ? Timestamp.fromDate(widget
                                                  .tasksController.time.value!)
                                              : null,
                                    },
                                  );
                                  widget.notificationsController
                                      .cancelNotification(extractedID);
                                  //shchedule notification if date is selected and time is selected
                                  if (widget.tasksController.dateSelected.value &&
                                      widget.tasksController.date.value !=
                                          null &&
                                      widget
                                          .tasksController.timeSelected.value &&
                                      widget.tasksController.time.value !=
                                          null) {
                                    widget.notificationsController
                                        .showScheduledNotification(
                                      id: extractedID,
                                      title: 'Task reminder',
                                      body: widget.todo.description,
                                      scheduledTime: DateTime(
                                          widget
                                              .tasksController.date.value!.year,
                                          widget.tasksController.date.value!
                                              .month,
                                          widget
                                              .tasksController.date.value!.day,
                                          widget
                                              .tasksController.time.value!.hour,
                                          widget.tasksController.time.value!
                                              .minute,
                                          0,
                                          0,
                                          0),
                                    );
                                  }
                                  //schedule notofication if date is not selected and time is selected
                                  if (!widget
                                          .tasksController.dateSelected.value &&
                                      widget
                                          .tasksController.timeSelected.value &&
                                      widget.tasksController.time.value !=
                                          null) {
                                    widget.notificationsController
                                        .showScheduledNotification(
                                      id: extractedID,
                                      title: 'Task reminder',
                                      body: widget.todo.description,
                                      scheduledTime: DateTime(
                                          widget
                                              .tasksController.time.value!.year,
                                          widget.tasksController.time.value!
                                              .month,
                                          widget
                                              .tasksController.time.value!.day,
                                          widget
                                              .tasksController.time.value!.hour,
                                          widget.tasksController.time.value!
                                              .minute,
                                          0,
                                          0,
                                          0),
                                    );
                                  }
                                  widget.tasksController.time.value = null;
                                  widget.tasksController.timeSelected.value =
                                      false;
                                  widget.tasksController.date.value = null;
                                  widget.tasksController.dateSelected.value =
                                      false;
                                  Get.back();
                                },
                                child: Text('changeTime'.tr),
                              ),
                            ],
                          );
                        },
                        context: context)
                    : showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (BuildContext context) {
                          return SimpleDialog(
                            titlePadding: const EdgeInsets.only(
                                top: 20, left: 20, right: 20),
                            titleTextStyle: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20.sp),
                            title: Text('dateOrTime'.tr),
                            children: [
                              SimpleDialogOption(
                                onPressed: () async {
                                  widget
                                      .categoriesController
                                      .isDateModalOpenedFromTasksScreen
                                      .value = true;

                                  if (widget.fireStoreData.data().todoDate !=
                                      null) {
                                    widget.tasksController.dateSelected.value =
                                        true;
                                  }
                                  if (widget.fireStoreData.data().todoTime !=
                                      null) {
                                    widget.tasksController.timeSelected.value =
                                        true;
                                    widget.tasksController.time.value = widget
                                        .fireStoreData
                                        .data()
                                        .todoTime!
                                        .toDate();
                                  }
                                  widget.tasksController.date.value =
                                      await showRoundedDatePicker(
                                    context: context,
                                    initialDate:
                                        widget.tasksController.date.value,
                                    listDateDisabled: helpers.getDaysInBeteween(
                                        DateTime(DateTime.now().year,
                                            DateTime.now().month, 1),
                                        DateTime.now()),
                                    firstDate: DateTime(
                                        DateTime.now().year,
                                        DateTime.now().month,
                                        DateTime.now().day,
                                        0,
                                        0,
                                        0),
                                    lastDate: DateTime(
                                        DateTime.now().year + 2, 12, 31),
                                    locale: Get.deviceLocale,
                                    customWeekDays: DateFormat.EEEE(
                                            Get.deviceLocale!.languageCode)
                                        .dateSymbols
                                        .SHORTWEEKDAYS,
                                    height: 380,
                                    textActionButton: "DELETE DATE",
                                    onTapActionButton: () {
                                      Navigator.of(context).pop(null);
                                      widget.tasksController.dateSelected
                                          .value = false;
                                      widget.tasksController.date.value = null;
                                    },
                                    theme: ThemeData(
                                      primaryColor: context.isDarkMode
                                          ? Constants.kDarkThemeBGColor
                                          : Constants.kLightGrayColor2,
                                    ),
                                    styleDatePicker:
                                        MaterialRoundedDatePickerStyle(
                                      textStyleDayButton: TextStyle(
                                        fontSize: 35,
                                        color: context.isDarkMode
                                            ? Constants.kDarkThemeTextColor
                                            : Constants.kAlternativeTextColor,
                                      ),
                                      textStyleYearButton: TextStyle(
                                        fontSize: 35,
                                        color: context.isDarkMode
                                            ? Constants.kDarkThemeTextColor
                                            : Constants.kAlternativeTextColor,
                                      ),
                                      textStyleDayHeader: TextStyle(
                                        fontSize: 15,
                                        color: context.isDarkMode
                                            ? Constants
                                                .kDarkThemeTextColorAlternative
                                                .withOpacity(0.5)
                                            : Constants.kBlackTextOnWhiteBGColor
                                                .withOpacity(0.5),
                                      ),
                                      textStyleCurrentDayOnCalendar: TextStyle(
                                          fontSize: 25,
                                          color: context.isDarkMode
                                              ? Constants.kDarkThemeAccentColor
                                              : Constants.kAccentColor,
                                          fontWeight: FontWeight.bold),
                                      textStyleDayOnCalendar: TextStyle(
                                        fontSize: 17,
                                        color: context.isDarkMode
                                            ? Constants
                                                .kDarkThemeTextColorAlternative
                                            : Constants.kAlternativeTextColor,
                                      ),
                                      textStyleDayOnCalendarSelected:
                                          const TextStyle(
                                        fontSize: 26,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textStyleDayOnCalendarDisabled: TextStyle(
                                        fontSize: 17,
                                        color: context.isDarkMode
                                            ? Constants
                                                .kDarkThemeTextColorAlternative
                                                .withOpacity(0.3)
                                            : Constants.kAlternativeTextColor
                                                .withOpacity(0.3),
                                      ),
                                      textStyleMonthYearHeader: TextStyle(
                                        fontSize: 21,
                                        color: context.isDarkMode
                                            ? Constants
                                                .kDarkThemeTextColorAlternative
                                            : Constants
                                                .kBlackTextOnWhiteBGColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      paddingDatePicker:
                                          const EdgeInsets.all(0),
                                      paddingMonthHeader:
                                          const EdgeInsets.all(15),
                                      paddingActionBar: const EdgeInsets.all(0),
                                      paddingDateYearHeader:
                                          const EdgeInsets.all(0),
                                      arrowIconLeft: CustomIcons.arrowLeft,
                                      arrowIconRight: CustomIcons.arrowRight,
                                      sizeArrow: 20,
                                      colorArrowNext: context.isDarkMode
                                          ? Constants
                                              .kDarkThemeTextColorAlternative
                                          : Constants.kBlackTextOnWhiteBGColor,
                                      colorArrowPrevious: context.isDarkMode
                                          ? Constants
                                              .kDarkThemeTextColorAlternative
                                          : Constants.kBlackTextOnWhiteBGColor,
                                      marginLeftArrowPrevious: 15,
                                      marginTopArrowPrevious: 15,
                                      marginTopArrowNext: 15,
                                      marginRightArrowNext: 15,
                                      textStyleButtonAction: TextStyle(
                                          fontSize: 15,
                                          color: context.isDarkMode
                                              ? Constants
                                                  .kDarkThemeTextColorAlternative
                                              : Constants
                                                  .kBlackTextOnWhiteBGColor,
                                          fontWeight: FontWeight.bold),
                                      textStyleButtonPositive: TextStyle(
                                          fontSize: 15,
                                          color: context.isDarkMode
                                              ? Constants
                                                  .kDarkThemeTextColorAlternative
                                              : Constants
                                                  .kBlackTextOnWhiteBGColor,
                                          fontWeight: FontWeight.bold),
                                      textStyleButtonNegative: TextStyle(
                                        fontSize: 15,
                                        color: context.isDarkMode
                                            ? Constants
                                                .kDarkThemeTextColorAlternative
                                                .withOpacity(0.6)
                                            : Constants.kBlackTextOnWhiteBGColor
                                                .withOpacity(0.6),
                                      ),
                                      decorationDateSelected: BoxDecoration(
                                        color: context.isDarkMode
                                            ? Constants.kDarkThemeAccentColor
                                            : Constants.kAccentColor,
                                        shape: BoxShape.circle,
                                      ),
                                      backgroundPicker: context.isDarkMode
                                          ? Constants.kDarkThemeBGLightColor
                                          : Constants.kWhiteBgColor,
                                      backgroundActionBar: context.isDarkMode
                                          ? Constants.kDarkThemeBGLightColor
                                          : Constants.kWhiteBgColor,
                                      backgroundHeaderMonth: context.isDarkMode
                                          ? Constants.kDarkThemeBGLightColor
                                          : Constants.kWhiteBgColor,
                                    ),
                                    styleYearPicker:
                                        MaterialRoundedYearPickerStyle(
                                      textStyleYear: TextStyle(
                                        fontSize: 40,
                                        color: context.isDarkMode
                                            ? Constants.kDarkThemeTextColor
                                            : Constants.kAlternativeTextColor,
                                      ),
                                      textStyleYearSelected: TextStyle(
                                          fontSize: 56,
                                          color: context.isDarkMode
                                              ? Constants.kDarkThemeAccentColor
                                              : Constants.kAccentColor,
                                          fontWeight: FontWeight.bold),
                                      heightYearRow: 100,
                                      backgroundPicker: context.isDarkMode
                                          ? Constants.kDarkThemeBGLightColor
                                          : Constants.kWhiteBgColor,
                                    ),
                                  );

                                  // if (tasksController.date.value != null) {
                                  //   tasksController.dateSelected.value = true;
                                  // }
                                  widget
                                      .categoriesController
                                      .isDateModalOpenedFromTasksScreen
                                      .value = false;
                                  //Since we change only the date (without time) it would be logical to change to Date to tasksController.date.value + 23:59:59
                                  // because otherwise we take the current time and todo becomes instantly overdue

                                  if (widget.tasksController.date.value !=
                                          null &&
                                      widget.tasksController.date.value!
                                          .isToday) {
                                    //TODO change custom hour, minute and blablabla to a variable that is the endOfTheDay which should be present in TasksController somewhere in the future

                                    int newHour = 23;
                                    int newMinute = 59;
                                    int newSecond = 59;
                                    widget.tasksController.date.value = widget
                                        .tasksController.date.value!
                                        .toLocal();
                                    widget.tasksController.date.value =
                                        DateTime(
                                            widget.tasksController.date.value!
                                                .year,
                                            widget.tasksController.date.value!
                                                .month,
                                            widget.tasksController.date.value!
                                                .day,
                                            newHour,
                                            newMinute,
                                            newSecond,
                                            widget.tasksController.date.value!
                                                .millisecond);
                                  }
                                  int? extractedID;
                                  extractedID = await widget.databaseController
                                      .updateTodo(
                                    widget.fireStoreData,
                                    {
                                      'day':
                                          widget.tasksController.date.value !=
                                                  null
                                              ? Timestamp.fromDate(widget
                                                  .tasksController.date.value!)
                                              : null,
                                    },
                                  );
                                  widget.notificationsController
                                      .cancelNotification(extractedID);
                                  //shchedule notification if date is selected and time is selected
                                  if (widget.tasksController.dateSelected.value &&
                                      widget.tasksController.date.value !=
                                          null &&
                                      widget
                                          .tasksController.timeSelected.value &&
                                      widget.tasksController.time.value !=
                                          null) {
                                    widget.notificationsController
                                        .showScheduledNotification(
                                      id: extractedID,
                                      title: 'Task reminder',
                                      body: widget.todo.description,
                                      scheduledTime: DateTime(
                                          widget
                                              .tasksController.date.value!.year,
                                          widget.tasksController.date.value!
                                              .month,
                                          widget
                                              .tasksController.date.value!.day,
                                          widget
                                              .tasksController.time.value!.hour,
                                          widget.tasksController.time.value!
                                              .minute,
                                          0,
                                          0,
                                          0),
                                    );
                                  }
                                  //schedule notofication if date is not selected and time is selected
                                  if (!widget
                                          .tasksController.dateSelected.value &&
                                      widget
                                          .tasksController.timeSelected.value &&
                                      widget.tasksController.time.value !=
                                          null) {
                                    widget.notificationsController
                                        .showScheduledNotification(
                                      id: extractedID,
                                      title: 'Task reminder',
                                      body: widget.todo.description,
                                      scheduledTime: DateTime(
                                          widget
                                              .tasksController.time.value!.year,
                                          widget.tasksController.time.value!
                                              .month,
                                          widget
                                              .tasksController.time.value!.day,
                                          widget
                                              .tasksController.time.value!.hour,
                                          widget.tasksController.time.value!
                                              .minute,
                                          0,
                                          0,
                                          0),
                                    );
                                  }
                                  widget.tasksController.date.value = null;
                                  widget.tasksController.dateSelected.value =
                                      false;
                                  widget.tasksController.time.value = null;
                                  widget.tasksController.timeSelected.value =
                                      false;
                                  Get.back();
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.calendar_today_outlined,
                                      size: 25,
                                    ),
                                    Flexible(
                                      child: Padding(
                                        padding:
                                            const EdgeInsetsDirectional.only(
                                                start: 16),
                                        child: Text(
                                          'changeDate'.tr,
                                          style: TextStyle(fontSize: 14.sp),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SimpleDialogOption(
                                onPressed: () async {
                                  widget
                                      .categoriesController
                                      .isTimeModalOpenedFromTasksScreen
                                      .value = true;
                                  if (widget.fireStoreData.data().todoDate !=
                                      null) {
                                    widget.tasksController.dateSelected.value =
                                        true;
                                    widget.tasksController.date.value = widget
                                        .fireStoreData
                                        .data()
                                        .todoDate!
                                        .toDate();
                                  }
                                  if (widget.fireStoreData.data().todoTime !=
                                      null) {
                                    widget.tasksController.timeSelected.value =
                                        true;
                                  }
                                  widget.tasksController.time.value =
                                      await CupertinoRoundedDatePicker.show(
                                    context,
                                    minuteInterval: 5,
                                    textColor: context.isDarkMode
                                        ? Constants.kDarkThemeTextColor
                                        : Constants.kBlackTextOnWhiteBGColor,
                                    background: context.isDarkMode
                                        ? Constants.kDarkThemeBGLightColor
                                        : Constants.kWhiteBgColor,
                                    use24hFormat: MediaQuery.of(context)
                                        .alwaysUse24HourFormat,
                                    initialDate: widget.tasksController
                                                .timeSelected.value &&
                                            widget.tasksController.time.value !=
                                                null
                                        ? widget.tasksController.time.value
                                        : DateTime.now()
                                            .roundUp(DateTime.now()),
                                    initialDatePickerMode:
                                        CupertinoDatePickerMode.time,
                                    onDateTimeChanged: (selectedDateTime) {
                                      widget.tasksController.time.value =
                                          selectedDateTime;
                                    },
                                  );
                                  int? extractedID;
                                  extractedID = await widget.databaseController
                                      .updateTodo(
                                    widget.fireStoreData,
                                    {
                                      'time':
                                          widget.tasksController.time.value !=
                                                  null
                                              ? Timestamp.fromDate(widget
                                                  .tasksController.time.value!)
                                              : null,
                                    },
                                  );
                                  widget.notificationsController
                                      .cancelNotification(extractedID);
                                  //shchedule notification if date is selected and time is selected
                                  if (widget.tasksController.dateSelected.value &&
                                      widget.tasksController.date.value !=
                                          null &&
                                      widget
                                          .tasksController.timeSelected.value &&
                                      widget.tasksController.time.value !=
                                          null) {
                                    widget.notificationsController
                                        .showScheduledNotification(
                                      id: extractedID,
                                      title: 'Task reminder',
                                      body: widget.todo.description,
                                      scheduledTime: DateTime(
                                          widget
                                              .tasksController.date.value!.year,
                                          widget.tasksController.date.value!
                                              .month,
                                          widget
                                              .tasksController.date.value!.day,
                                          widget
                                              .tasksController.time.value!.hour,
                                          widget.tasksController.time.value!
                                              .minute,
                                          0,
                                          0,
                                          0),
                                    );
                                  }
                                  //schedule notofication if date is not selected and time is selected
                                  if (!widget
                                          .tasksController.dateSelected.value &&
                                      widget
                                          .tasksController.timeSelected.value &&
                                      widget.tasksController.time.value !=
                                          null) {
                                    widget.notificationsController
                                        .showScheduledNotification(
                                      id: extractedID,
                                      title: 'Task reminder',
                                      body: widget.todo.description,
                                      scheduledTime: DateTime(
                                          widget
                                              .tasksController.time.value!.year,
                                          widget.tasksController.time.value!
                                              .month,
                                          widget
                                              .tasksController.time.value!.day,
                                          widget
                                              .tasksController.time.value!.hour,
                                          widget.tasksController.time.value!
                                              .minute,
                                          0,
                                          0,
                                          0),
                                    );
                                  }
                                  widget.tasksController.time.value = null;
                                  widget.tasksController.timeSelected.value =
                                      false;
                                  widget.tasksController.date.value = null;
                                  widget.tasksController.dateSelected.value =
                                      false;
                                  Get.back();
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.timer_outlined,
                                      size: 25,
                                    ),
                                    Flexible(
                                      child: Padding(
                                        padding:
                                            const EdgeInsetsDirectional.only(
                                                start: 16),
                                        child: Text(
                                          'changeTime'.tr,
                                          style: TextStyle(fontSize: 14.sp),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      );
              },
            ),
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
                widget.tasksController.todoOpenedFromTasksScreen.value = true;
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
                    fireStoreData: widget.fireStoreData,
                    category: widget.firestoreCategoryData,
                    categoryReferenceID: widget.categoryReferenceID,
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
                widget.databaseController.deleteTodo(widget.fireStoreData);
              },
            ),
          ],
        ),
        child: FadeOutParticle(
          duration: const Duration(milliseconds: 500),
          disappear: isPressed,
          onAnimationEnd: () async {
            int? todoID;
            todoID = await widget.databaseController
                .updateTodo(widget.fireStoreData, {
              'isDone': widget.todo.isDone,
              'whenCompleted': Timestamp.fromDate(
                DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                ),
              ),
            });
            if (widget.todo.isDone == true) {
              widget.notificationsController.cancelNotification(todoID);
            }
          },
          child: Material(
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(stops: const [
                  0.015,
                  0.015
                ], colors: [
                  widget.color == null
                      ? context.isDarkMode
                          ? Constants.kDarkThemeWhiteAccentColor
                          : Constants.kAlternativeTextColor
                      : Color(widget.color!),
                  context.isDarkMode
                      ? widget.todo.isDone == true
                          ? Constants.kDarkThemeTodoIsDoneColor
                          : Constants.kDarkThemeBGLightColor
                      : widget.todo.isDone == true
                          ? Constants.kLightThemeTodoIsDoneColor
                          : Constants.kWhiteBgColor,
                ]),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.only(right: 20.0),
                horizontalTitleGap: 0,
                minVerticalPadding: 0,
                onTap: () {
                  widget.tasksController.todoOpenedFromTasksScreen.value = true;
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
                      fireStoreData: widget.fireStoreData,
                      category: widget.firestoreCategoryData,
                      categoryReferenceID: widget.categoryReferenceID,
                    ),
                  );
                },
                leading: Checkbox(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                  fillColor: MaterialStateProperty.all(context.isDarkMode
                      ? Constants.kDarkThemeAccentColor
                      : Constants.kAccentColor),
                  value: widget.todo.isDone,
                  onChanged: (value) async {
                    widget.todo.isDone = value;
                    setState(() {
                      isPressed = true;
                    });

                    // int? todoID;
                    // todoID =
                    //     await databaseController.updateTodo(fireStoreData, {
                    //   'isDone': value,
                    //   'whenCompleted': Timestamp.fromDate(
                    //     DateTime(
                    //       DateTime.now().year,
                    //       DateTime.now().month,
                    //       DateTime.now().day,
                    //     ),
                    //   ),
                    // });
                    // if (value == true) {
                    //   notificationsController.cancelNotification(todoID);
                    // }
                  },
                ),
                title: Text(
                  widget.todo.description!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: widget.todo.subTodos != null &&
                        widget.todo.subTodos!.isNotEmpty
                    ? const Icon(Icons.list_outlined)
                    : null,
                subtitle: widget.todo.todoDate == null &&
                        widget.todo.todoTime == null
                    ? null
                    : (() {
                        DateTime? parsedDate;
                        DateTime? parsedTime;
                        String? formattedDate;
                        if (widget.todo.todoDate != null) {
                          parsedDate = widget.todo.todoDate!.toDate();
                          formattedDate = DateFormat.MMMd(Platform.localeName)
                              .format(parsedDate);
                        }
                        if (widget.todo.todoTime != null) {
                          parsedTime = widget.todo.todoTime?.toDate();
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
      ),
    );
  }
}
