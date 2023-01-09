import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:get/get.dart';

import 'package:intl/intl.dart';

import '../Database/database.dart';
import '../controllers/notifications_controller.dart';

import '../helpers/helpers.dart' as helpers;
import '../controllers/categories_controller.dart';
import '../controllers/tasks_controller.dart';
import '../helpers/custom_icons_icons.dart';
import '../helpers/time_extensions.dart';
import '../models/subtodo.dart';
import '../models/todo.dart';
import 'shake_widget.dart';

import '../consts/consts.dart';
import '../models/category.dart';
import 'calendar picker/flutter_rounded_date_picker.dart';
import 'categories_modal_fit.dart';

class TaskModalView extends StatefulWidget {
  const TaskModalView(
      {Key? key, this.fireStoreData, this.category, this.categoryReferenceID})
      : super(key: key);
  final QueryDocumentSnapshot<Todo>? fireStoreData;
  final Category? category;
  final String? categoryReferenceID;
  @override
  State<TaskModalView> createState() => _TaskModalViewState();
}

class _TaskModalViewState extends State<TaskModalView>
    with TickerProviderStateMixin {
  ScrollController scrollController = ScrollController();
  TextEditingController todoNoteController = TextEditingController();
  TextEditingController todoDescriptionController = TextEditingController();
  List<TextEditingController> subtaskTextEditingController = [];
  List<ShakeController> subtaskShakeControllers = [];
  List<Subtodo> subtasks = [];
  List<FocusNode> subtaskFocusNodes = [];
  int? id;

  var listKey = GlobalKey<AnimatedListState>();
  final FocusNode mainFocusNode = FocusNode();
  final CategoriesController categoriesController = Get.find();
  final TasksController _tasksController = Get.find();
  final DatabaseController _databaseController = Get.find();
  final NotificationsController _notificationsController = Get.find();
  var type = FeedbackType.medium;
  late ShakeController _shakeController;
  @override
  void initState() {
    _shakeController = ShakeController(vsync: this);

    //Here we perform the checks if todo modal view was opened by clicking on the existing todo
    if (_tasksController.todoOpenedFromTasksScreen.value!) {
      //Assign todo description
      todoDescriptionController.text =
          widget.fireStoreData!.data().description!;
//Assign category
      categoriesController.selectedCategoryForNewTask!.value = widget.category;
      categoriesController.selectedCategoryID.value =
          widget.categoryReferenceID;

//Assign Date
      if (widget.fireStoreData!.data().todoDate != null) {
        _tasksController.dateSelected.value = true;
        _tasksController.date.value =
            widget.fireStoreData!.data().todoDate!.toDate();
      }
      //Assign Time
      if (widget.fireStoreData!.data().todoTime != null) {
        _tasksController.timeSelected.value = true;
        _tasksController.time.value =
            widget.fireStoreData!.data().todoTime!.toDate();
      }
      //Assign Note
      if (widget.fireStoreData!.data().notes != null) {
        todoNoteController.text = widget.fireStoreData!.data().notes!;
      }
      //Assign Subtotos
      if (widget.fireStoreData!.data().subTodos != null) {
        subtasks = widget.fireStoreData!
            .data()
            .subTodos!
            .map((e) => Subtodo(
                subDescription: e['subDescription'], subIsDone: e['subIsDone']))
            .toList();

        for (var i = 0; i < subtasks.length; i++) {
          FocusNode focusNode = FocusNode();
          subtaskFocusNodes.insert(i, focusNode);
          subtaskTextEditingController.insert(
              i, TextEditingController(text: subtasks[i].subDescription));
          listKey.currentState
              ?.insertItem(i, duration: const Duration(milliseconds: 200));
          subtaskShakeControllers.insert(i, ShakeController(vsync: this));
        }
      }
    }
    Future.delayed(const Duration(milliseconds: 350))
        .then((value) => mainFocusNode.requestFocus());

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();

    todoDescriptionController.dispose();
    scrollController.dispose();
    todoNoteController.dispose();
    mainFocusNode.dispose();

    _shakeController.dispose();
    _tasksController.timeSelected.value = false;
    _tasksController.dateSelected.value = false;
    _tasksController.date.value = null;
    _tasksController.time.value = null;
    categoriesController.selectedCategoryForNewTask!.value = null;
    categoriesController.selectedCategoryID.value = null;
    _tasksController.todoOpenedFromTasksScreen.value = false;
    // Clean up the focus nodes when the Form is disposed.
    for (var element in subtaskFocusNodes) {
      element.dispose();
    }
    for (var element in subtaskTextEditingController) {
      element.dispose();
    }
    for (var element in subtaskShakeControllers) {
      element.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      //height: 0.9.sh,
      child: Column(
        children: [
          CreateTaskWidget(
            firestoreData: widget.fireStoreData,
            subtodos: subtasks,
            notesController: todoNoteController,
            tasksController: _tasksController,
            categoriesController: categoriesController,
            todoDescriptionController: todoDescriptionController,
            shakeController: _shakeController,
            databaseController: _databaseController,
            subtaskTextEditingController: subtaskTextEditingController,
            notificationsController: _notificationsController,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: ListView(
                padding: EdgeInsets.zero,

                controller: scrollController,
                //keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  InputFieldForTodoDescription(
                      shakeController: _shakeController,
                      mainFocusNode: mainFocusNode,
                      todoDescriptionController: todoDescriptionController),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 140,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: context.isDarkMode
                          ? Constants.kDarkThemeBGLightColor
                          : Constants.kWhiteBgColor,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          CategorySelectorWidget(
                              categoriesController: categoriesController),
                          DateSelectorWidget(tasksController: _tasksController),
                          TimeSelectorWidget(tasksController: _tasksController),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  NoteTextFieldWidget(todoNoteController: todoNoteController),
                  const SizedBox(
                    height: 20.0,
                  ),
                  subtasks.isNotEmpty
                      ? AnimatedList(
                          physics: const NeverScrollableScrollPhysics(),
                          key: listKey,
                          shrinkWrap: true,
                          initialItemCount: subtasks.length,
                          itemBuilder: (context, index, animation) {
                            //this check is neccessary when we invoke insertSubtask() for the first time
                            //and is not executed when todo is opened from TasksScreen and has subtasks>0

                            if (subtasks.length == 1 &&
                                !_tasksController
                                    .todoOpenedFromTasksScreen.value!) {
                              SchedulerBinding.instance
                                  .addPostFrameCallback((timeStamp) {
                                scrollController.animateTo(
                                  scrollController.position.maxScrollExtent,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.fastOutSlowIn,
                                );
                              });
                            }

                            animation.addStatusListener((status) {
                              if (status == AnimationStatus.completed) {
                                scrollController.animateTo(
                                  scrollController.position.maxScrollExtent,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.fastOutSlowIn,
                                );
                              }
                            });

                            return SizeTransition(
                              sizeFactor: animation,
                              child: ScaleTransition(
                                scale: animation,
                                child: ListTile(
                                  horizontalTitleGap: 0.0,
                                  contentPadding: EdgeInsets.zero,
                                  leading: Checkbox(
                                    onChanged: (value) {
                                      setState(() {
                                        subtasks[index].subIsDone = value;
                                        late int lastIndex;
                                        if (subtasks.isNotEmpty) {
                                          lastIndex = subtasks.length - 1;
                                        } else {
                                          lastIndex = 0;
                                        }

                                        String description;
                                        if (lastIndex != index &&
                                            subtasks[index].subIsDone !=
                                                false) {
                                          description =
                                              subtaskTextEditingController[
                                                      index]
                                                  .text;

                                          subtaskTextEditingController
                                              .removeAt(index);
                                          subtaskShakeControllers
                                              .removeAt(index);
                                          subtasks.removeAt(index);
                                          subtaskFocusNodes[index].unfocus();
                                          subtaskFocusNodes.removeAt(index);
                                          listKey.currentState!.removeItem(
                                            index,
                                            (context, animation) =>
                                                SizeTransition(
                                              sizeFactor: animation,
                                              child: ScaleTransition(
                                                scale: animation,
                                                child: ListTile(
                                                  title: Text(description
                                                          .isEmpty
                                                      ? 'New subtask'
                                                      : subtaskTextEditingController[
                                                              index]
                                                          .text),
                                                  trailing: IconButton(
                                                      icon: const Icon(
                                                          CustomIcons.cross),
                                                      onPressed: () {}),
                                                ),
                                              ),
                                            ),
                                            duration: const Duration(
                                                milliseconds: 300),
                                          );
                                          var newItem = Subtodo(
                                              subDescription: description,
                                              subIsDone: true);
                                          subtasks.insert(lastIndex, newItem);
                                          listKey.currentState?.insertItem(
                                              lastIndex,
                                              duration: const Duration(
                                                  milliseconds: 300));
                                          subtaskFocusNodes.insert(
                                              lastIndex, FocusNode());
                                          // subtaskFocusNodes[lastIndex]
                                          //     .unfocus();
                                          subtaskTextEditingController.insert(
                                              lastIndex,
                                              TextEditingController()
                                                ..text = description);
                                          subtaskShakeControllers.insert(
                                              lastIndex,
                                              ShakeController(vsync: this));
                                        } else if (lastIndex == index &&
                                            subtasks[index].subIsDone !=
                                                false) {
                                          subtaskFocusNodes[index].unfocus();
                                        }

                                        //
                                      });
                                    },
                                    value: subtasks[index].subIsDone,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5)),
                                    fillColor: MaterialStateProperty.all(
                                        context.isDarkMode
                                            ? Constants.kDarkThemeAccentColor
                                            : Constants.kAccentColor),
                                  ),
                                  title: TitleForSubTodoWidget(
                                      index: index,
                                      subtaskShakeControllers:
                                          subtaskShakeControllers,
                                      subtaskFocusNodes: subtaskFocusNodes,
                                      subtasks: subtasks,
                                      subtaskTextEditingController:
                                          subtaskTextEditingController),
                                  trailing: IconButton(
                                      icon: const Icon(
                                        Icons.cancel_rounded,
                                        size: 25.0,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          subtaskFocusNodes[index].unfocus();
                                          var removedItem = subtasks[index];

                                          subtaskTextEditingController
                                              .removeAt(index);

                                          subtaskFocusNodes.removeAt(index);
                                          subtaskShakeControllers
                                              .removeAt(index);
                                          subtasks.removeAt(index);

                                          listKey.currentState!.removeItem(
                                            index,
                                            (context, animation) =>
                                                SizeTransition(
                                              sizeFactor: animation,
                                              child: ScaleTransition(
                                                scale: animation,
                                                child: ListTile(
                                                  title: Text(removedItem
                                                          .subDescription ??
                                                      ''),
                                                  trailing: IconButton(
                                                      icon: const Icon(
                                                          CustomIcons.cross),
                                                      onPressed: () {}),
                                                ),
                                              ),
                                            ),
                                            duration: const Duration(
                                                milliseconds: 100),
                                          );
                                        });
                                      }),
                                ),
                              ),
                            );
                          })
                      : const SizedBox.shrink(),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          insertSubtask();
                        });
                      },
                      icon: Icon(
                        CustomIcons.plus,
                        color: context.isDarkMode
                            ? Constants.kDarkThemeTextColor
                            : Constants.kAlternativeTextColor,
                        size: 15.0,
                      ),
                      label: Text(
                        'addSubtask'.tr,
                        style: TextStyle(
                          fontSize: 16,
                          color: context.isDarkMode
                              ? Constants.kDarkThemeTextColor
                              : Constants.kAlternativeTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void insertSubtask() async {
    late int lastIndex;

    if (subtasks.isNotEmpty) {
      lastIndex = subtasks.length;
    } else {
      lastIndex = 0;
    }
    if (subtaskTextEditingController.isNotEmpty &&
        subtaskTextEditingController[lastIndex - 1].text.isEmpty) {
      subtaskShakeControllers[lastIndex - 1].shake();

      Vibrate.feedback(FeedbackType.error);
      return;
    }
    FocusNode focusNode = FocusNode();
    subtaskFocusNodes.insert(lastIndex, focusNode);

    subtaskTextEditingController.insert(lastIndex, TextEditingController());
    var newSubtask = Subtodo(
      subIsDone: false,
    );
    subtasks.insert(lastIndex, newSubtask);
    listKey.currentState
        ?.insertItem(lastIndex, duration: const Duration(milliseconds: 200));
    subtaskShakeControllers.insert(lastIndex, ShakeController(vsync: this));
    subtaskFocusNodes[lastIndex].requestFocus();

    //this is the only way I figured out in order the scrolling to work correctly
    //await Future.delayed(const Duration(milliseconds: 250));
  }
}

class TitleForSubTodoWidget extends StatelessWidget {
  const TitleForSubTodoWidget({
    Key? key,
    required this.subtaskShakeControllers,
    required this.subtaskFocusNodes,
    required this.subtasks,
    required this.subtaskTextEditingController,
    required this.index,
  }) : super(key: key);

  final List<ShakeController> subtaskShakeControllers;
  final List<FocusNode> subtaskFocusNodes;
  final List<Subtodo> subtasks;
  final List<TextEditingController> subtaskTextEditingController;
  final int index;

  @override
  Widget build(BuildContext context) {
    return ShakeView(
      controller: subtaskShakeControllers[index],
      child: TextField(
        textInputAction: TextInputAction.next,
        autofocus: false,
        focusNode: subtaskFocusNodes[index],

        onSubmitted: (value) {
          subtasks[index].subDescription =
              subtaskTextEditingController[index].text;
          FocusScope.of(context).unfocus();
        },

        style: TextStyle(
            color: context.isDarkMode
                ? subtasks[index].subIsDone!
                    ? Constants.kAlternativeTextColor
                    : Constants.kDarkThemeTextColor
                : subtasks[index].subIsDone!
                    ? Constants.kLightGrayColor
                    : Constants.kBlackTextOnWhiteBGColor),
        //autofocus: true,

        controller: subtaskTextEditingController[index],

        keyboardAppearance:
            context.isDarkMode ? Brightness.dark : Brightness.light,
        inputFormatters: [
          FilteringTextInputFormatter.deny(
            RegExp(r"^\s"),
          ),
        ],
        textAlign: TextAlign.left,
        decoration: InputDecoration(
          hintText: 'newSubtaskTextField'.tr,
          hintStyle: TextStyle(
              color: context.isDarkMode
                  ? Constants.kAlternativeTextColor
                  : Constants.kBlackTextOnWhiteBGColor),
          isCollapsed: true,
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class NoteTextFieldWidget extends StatelessWidget {
  const NoteTextFieldWidget({
    Key? key,
    required this.todoNoteController,
  }) : super(key: key);

  final TextEditingController todoNoteController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      constraints: const BoxConstraints(minHeight: 50.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: context.isDarkMode
            ? Constants.kDarkThemeNoteColor
            : Constants.kNoteColor,
      ),
      child: TextField(
        style: TextStyle(fontSize: 12.sp),
        maxLines: 9,
        minLines: 1,
        controller: todoNoteController,
        textInputAction: TextInputAction.done,
        keyboardAppearance:
            context.isDarkMode ? Brightness.dark : Brightness.light,
        // inputFormatters: [
        //   FilteringTextInputFormatter.deny(
        //     RegExp(r"^\s"),
        //   ),
        // ],
        textAlign: TextAlign.left,
        decoration: InputDecoration.collapsed(
          border: InputBorder.none,
          hintText: 'note'.tr,
          //contentPadding: const EdgeInsets.all(5),
        ),
      ),
    );
  }
}

class TimeSelectorWidget extends StatefulWidget {
  const TimeSelectorWidget({
    Key? key,
    required TasksController tasksController,
  })  : _tasksController = tasksController,
        super(key: key);

  final TasksController _tasksController;

  @override
  State<TimeSelectorWidget> createState() => _TimeSelectorWidgetState();
}

class _TimeSelectorWidgetState extends State<TimeSelectorWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.timer_outlined,
                size: 20.0,
                color: context.isDarkMode
                    ? Constants.kDarkThemeTextColor
                    : Constants.kBlackTextOnWhiteBGColor),
            const SizedBox(
              width: 10,
            ),
            Text(
              'time'.tr,
              style: TextStyle(
                  fontSize: 15.sp,
                  letterSpacing: 1,
                  color: context.isDarkMode
                      ? Constants.kDarkThemeTextColor
                      : Constants.kBlackTextOnWhiteBGColor
                  //color: Constants.kPrimaryTextColor,
                  ),
            )
          ],
        ),
        GestureDetector(
          onTap: () async {
            // if (FocusScope.of(context).hasFocus) {
            //   FocusScope.of(context).unfocus();
            //   await Future.delayed(const Duration(milliseconds: 200));
            // }
            //print(_tasksController.time.value);
            await CupertinoRoundedDatePicker.show(
              context,
              minuteInterval: 5,
              textColor: context.isDarkMode
                  ? Constants.kDarkThemeTextColor
                  : Constants.kBlackTextOnWhiteBGColor,
              background: context.isDarkMode
                  ? Constants.kDarkThemeBGLightColor
                  : Constants.kWhiteBgColor,
              use24hFormat: MediaQuery.of(context).alwaysUse24HourFormat,
              initialDate: widget._tasksController.timeSelected.value &&
                      widget._tasksController.time.value != null
                  ? widget._tasksController.time.value
                  : DateTime.now().roundUp(DateTime.now()),
              initialDatePickerMode: CupertinoDatePickerMode.time,
              onDateTimeChanged: (selectedDateTime) {
                widget._tasksController.time.value = selectedDateTime;
                //print(selectedDateTime);
              },
            );

            if (widget._tasksController.time.value != null) {
              widget._tasksController.timeSelected.value = true;
              if (widget._tasksController.time.value!
                  .isBefore(DateTime.now())) {
                widget._tasksController.time.value = widget
                    ._tasksController.time.value!
                    .add(const Duration(days: 1));
              } else if (widget._tasksController.time.value!
                  .isAfter(DateTime.now())) {
                widget._tasksController.time.value = DateTime(
                    DateTime.now().year,
                    DateTime.now().month,
                    DateTime.now().day,
                    widget._tasksController.time.value!.hour,
                    widget._tasksController.time.value!.minute);
              }
            }
            if (!mounted) return;
            FocusScope.of(context).requestFocus();
          },
          child: Container(
            height: 30,
            width: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: context.isDarkMode
                  ? Constants.kDarkThemeBGColor
                  : Constants.kGrayBgColor,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5.0),
                    child: Obx(
                      () => Text(
                        widget._tasksController.timeSelected.value
                            ? MediaQuery.of(context).alwaysUse24HourFormat
                                ? DateFormat.Hm()
                                    .format(widget._tasksController.time.value!)
                                : DateFormat.jm()
                                    .format(widget._tasksController.time.value!)
                            : 'selectTime'.tr,
                        textAlign: TextAlign.left,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.fade,
                      ),
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: context.isDarkMode
                      ? Constants.kDarkThemeWhiteAccentColor
                      : Constants.kAlternativeTextColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class DateSelectorWidget extends StatelessWidget {
  const DateSelectorWidget({
    Key? key,
    required TasksController tasksController,
  })  : _tasksController = tasksController,
        super(key: key);

  final TasksController _tasksController;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 20.0,
                color: context.isDarkMode
                    ? Constants.kDarkThemeTextColor
                    : Constants.kBlackTextOnWhiteBGColor),
            const SizedBox(
              width: 10,
            ),
            Text(
              'day'.tr,
              style: TextStyle(
                  fontSize: 15.sp,
                  letterSpacing: 1,
                  color: context.isDarkMode
                      ? Constants.kDarkThemeTextColor
                      : Constants.kBlackTextOnWhiteBGColor
                  //color: Constants.kPrimaryTextColor,
                  ),
            )
          ],
        ),
        GestureDetector(
          onTap: () async {
            if (FocusScope.of(context).hasFocus) {
              FocusScope.of(context).unfocus();
              await Future.delayed(const Duration(milliseconds: 200));
            }
            _tasksController.date.value = await showRoundedDatePicker(
              context: context,
              initialDate: _tasksController.date.value,
              listDateDisabled: helpers.getDaysInBeteween(
                  DateTime(DateTime.now().year, DateTime.now().month, 1),
                  DateTime.now()),
              firstDate: DateTime(DateTime.now().year, DateTime.now().month,
                  DateTime.now().day, 0, 0, 0),
              lastDate: DateTime(DateTime.now().year + 2, 12, 31),
              locale: Get.deviceLocale,
              customWeekDays: DateFormat.EEEE(Get.deviceLocale!.languageCode)
                  .dateSymbols
                  .SHORTWEEKDAYS,
              height: 380,
              textActionButton: "DELETE DATE",
              onTapActionButton: () {
                Navigator.of(context).pop(null);
                _tasksController.dateSelected.value = false;
                _tasksController.date.value = null;
              },
              theme: ThemeData(
                primaryColor: context.isDarkMode
                    ? Constants.kDarkThemeBGColor
                    : Constants.kLightGrayColor2,
              ),
              styleDatePicker: MaterialRoundedDatePickerStyle(
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
                      ? Constants.kDarkThemeTextColorAlternative
                          .withOpacity(0.5)
                      : Constants.kBlackTextOnWhiteBGColor.withOpacity(0.5),
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
                      ? Constants.kDarkThemeTextColorAlternative
                      : Constants.kAlternativeTextColor,
                ),
                textStyleDayOnCalendarSelected: const TextStyle(
                  fontSize: 26,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textStyleDayOnCalendarDisabled: TextStyle(
                  fontSize: 17,
                  color: context.isDarkMode
                      ? Constants.kDarkThemeTextColorAlternative
                          .withOpacity(0.3)
                      : Constants.kAlternativeTextColor.withOpacity(0.3),
                ),
                textStyleMonthYearHeader: TextStyle(
                  fontSize: 21,
                  color: context.isDarkMode
                      ? Constants.kDarkThemeTextColorAlternative
                      : Constants.kBlackTextOnWhiteBGColor,
                  fontWeight: FontWeight.bold,
                ),
                paddingDatePicker: const EdgeInsets.all(0),
                paddingMonthHeader: const EdgeInsets.all(15),
                paddingActionBar: const EdgeInsets.all(0),
                paddingDateYearHeader: const EdgeInsets.all(0),
                arrowIconLeft: CustomIcons.arrowLeft,
                arrowIconRight: CustomIcons.arrowRight,
                sizeArrow: 20,
                colorArrowNext: context.isDarkMode
                    ? Constants.kDarkThemeTextColorAlternative
                    : Constants.kBlackTextOnWhiteBGColor,
                colorArrowPrevious: context.isDarkMode
                    ? Constants.kDarkThemeTextColorAlternative
                    : Constants.kBlackTextOnWhiteBGColor,
                marginLeftArrowPrevious: 15,
                marginTopArrowPrevious: 15,
                marginTopArrowNext: 15,
                marginRightArrowNext: 15,
                textStyleButtonAction: TextStyle(
                    fontSize: 15,
                    color: context.isDarkMode
                        ? Constants.kDarkThemeTextColorAlternative
                        : Constants.kBlackTextOnWhiteBGColor,
                    fontWeight: FontWeight.bold),
                textStyleButtonPositive: TextStyle(
                    fontSize: 15,
                    color: context.isDarkMode
                        ? Constants.kDarkThemeTextColorAlternative
                        : Constants.kBlackTextOnWhiteBGColor,
                    fontWeight: FontWeight.bold),
                textStyleButtonNegative: TextStyle(
                  fontSize: 15,
                  color: context.isDarkMode
                      ? Constants.kDarkThemeTextColorAlternative
                          .withOpacity(0.6)
                      : Constants.kBlackTextOnWhiteBGColor.withOpacity(0.6),
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
              styleYearPicker: MaterialRoundedYearPickerStyle(
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
            FocusScope.of(context).requestFocus();
            if (_tasksController.date.value != null) {
              _tasksController.dateSelected.value = true;
            }
          },
          child: Container(
            height: 30,
            width: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: context.isDarkMode
                  ? Constants.kDarkThemeBGColor
                  : Constants.kGrayBgColor,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5.0),
                    child: Obx(
                      () => Text(
                        _tasksController.dateSelected.value
                            ? DateFormat.yMMMd(Platform.localeName)
                                .format(_tasksController.date.value!)
                            : 'selectDay'.tr,
                        textAlign: TextAlign.left,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.fade,
                      ),
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: context.isDarkMode
                      ? Constants.kDarkThemeWhiteAccentColor
                      : Constants.kAlternativeTextColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CategorySelectorWidget extends StatelessWidget {
  const CategorySelectorWidget({
    Key? key,
    required this.categoriesController,
  }) : super(key: key);

  final CategoriesController categoriesController;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.format_list_bulleted,
                size: 20.0,
                color: context.isDarkMode
                    ? Constants.kDarkThemeTextColor
                    : Constants.kBlackTextOnWhiteBGColor),
            const SizedBox(
              width: 10,
            ),
            Text(
              'category'.tr,
              style: TextStyle(
                  fontSize: 15.sp,
                  letterSpacing: 1,
                  color: context.isDarkMode
                      ? Constants.kDarkThemeTextColor
                      : Constants.kBlackTextOnWhiteBGColor
                  //color: Constants.kPrimaryTextColor,
                  ),
            )
          ],
        ),
        GestureDetector(
          onTap: () async {
            if (FocusScope.of(context).hasFocus) {
              FocusScope.of(context).unfocus();
              await Future.delayed(const Duration(milliseconds: 200));
            }

            await Get.bottomSheet(
              CategoriesModalFit(),
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
            FocusScope.of(context).requestFocus();
          },
          child: Container(
            width: 140,
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: context.isDarkMode
                  ? Constants.kDarkThemeBGColor
                  : Constants.kGrayBgColor,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(
                  () => Container(
                    margin: const EdgeInsets.only(left: 5.0, right: 4.0),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,

                      color: categoriesController
                                  .selectedCategoryForNewTask!.value ==
                              null
                          ? Colors.grey
                          : Color(categoriesController
                              .selectedCategoryForNewTask!.value!.color),
                      //     0
                      // ? Colors.grey
                      // : Color(categoriesController
                      //     .selectedColorForNewTask
                      //     .value)),
                    ),
                  ),
                ),
                Obx(
                  () => Expanded(
                    child: categoriesController
                                .selectedCategoryForNewTask!.value ==
                            null
                        ? Text(
                            'category'.tr,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.fade,
                          )
                        : Text(
                            categoriesController
                                .selectedCategoryForNewTask!.value!.name,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.fade),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: context.isDarkMode
                      ? Constants.kDarkThemeWhiteAccentColor
                      : Constants.kAlternativeTextColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class InputFieldForTodoDescription extends StatelessWidget {
  const InputFieldForTodoDescription({
    Key? key,
    required ShakeController shakeController,
    required this.mainFocusNode,
    required this.todoDescriptionController,
  })  : _shakeController = shakeController,
        super(key: key);

  final ShakeController _shakeController;
  final FocusNode mainFocusNode;
  final TextEditingController todoDescriptionController;

  @override
  Widget build(BuildContext context) {
    return ShakeView(
      controller: _shakeController,
      child: TextField(
        autofocus: false,
        focusNode: mainFocusNode,
        controller: todoDescriptionController,
        textInputAction: TextInputAction.next,
        keyboardAppearance:
            context.isDarkMode ? Brightness.dark : Brightness.light,
        inputFormatters: [
          FilteringTextInputFormatter.deny(
            RegExp(r"^\s"),
          ),
        ],
        textAlign: TextAlign.left,
        decoration: InputDecoration(
          hintText: 'newTaskTextField'.tr,
          isCollapsed: true,
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class CreateTaskWidget extends StatelessWidget {
  const CreateTaskWidget({
    Key? key,
    required this.todoDescriptionController,
    required ShakeController shakeController,
    required this.databaseController,
    required this.categoriesController,
    required this.tasksController,
    required this.notesController,
    required this.subtodos,
    required this.subtaskTextEditingController,
    this.firestoreData,
    required this.notificationsController,
  })  : _shakeController = shakeController,
        super(key: key);

  final TextEditingController todoDescriptionController;
  final ShakeController _shakeController;
  final DatabaseController databaseController;
  final CategoriesController categoriesController;
  final TasksController tasksController;
  final TextEditingController notesController;
  final List<Subtodo> subtodos;
  final List<TextEditingController> subtaskTextEditingController;
  final QueryDocumentSnapshot<Todo>? firestoreData;
  final NotificationsController notificationsController;
  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: () async {
            if (todoDescriptionController.text.isEmpty) {
              _shakeController.shake();
              Vibrate.feedback(FeedbackType.error);
              return;
            }

            //Generating a proper list for subtodos. Maybe it is possible to do it in a more proper way, but that works as well
            List finalListWithSubTodos = [];
            for (int i = 0; i < subtodos.length; i++) {
              //simple check if a newly added subtodo has a text. If it doesn't then we just skip it
              if (subtaskTextEditingController[i].text.isNotEmpty) {
                finalListWithSubTodos.add({
                  "subDescription": subtaskTextEditingController[i].text,
                  "subIsDone": subtodos[i].subIsDone,
                });
              }
            }

            //generate new random id and assign it to todo
            int uniqueID = notificationsController.createUniqueID(2147483645);
            Todo newTodo = Todo(
              description: todoDescriptionController.text,
              categoryReference: categoriesController.selectedCategoryID.value,
              todoDate: tasksController.dateSelected.value
                  ? Timestamp.fromDate(tasksController.date.value!)
                  : null,
              isDone: false,
              notes: notesController.text.isEmpty ? null : notesController.text,
              todoTime: tasksController.timeSelected.value
                  ? Timestamp.fromDate(tasksController.time.value!)
                  : null,
              subTodos: finalListWithSubTodos,
              uniqueNotificationID: uniqueID,
            );

            tasksController.todoOpenedFromTasksScreen.value!
                ? databaseController.updateTodo(
                    firestoreData!,
                    {
                      'description': todoDescriptionController.text,
                      'day': tasksController.dateSelected.value
                          ? Timestamp.fromDate(tasksController.date.value!)
                          : null,
                      'time': tasksController.timeSelected.value
                          ? Timestamp.fromDate(tasksController.time.value!)
                          : null,
                      'note': notesController.text.isEmpty
                          ? null
                          : notesController.text,
                      'category': categoriesController.selectedCategoryID.value,
                      'isDone': false,
                      'subtodos': finalListWithSubTodos,
                    },
                  )
                : databaseController.addTodo(newTodo);

            //now you can safely schedule notifications here with a random id
            //shchedule notification if date is selected and time is selected
            if (tasksController.dateSelected.value &&
                tasksController.date.value != null &&
                tasksController.timeSelected.value &&
                tasksController.time.value != null) {
              var scheduledDateTime = DateTime(
                  tasksController.date.value!.year,
                  tasksController.date.value!.month,
                  tasksController.date.value!.day,
                  tasksController.time.value!.hour,
                  tasksController.time.value!.minute,
                  0,
                  0,
                  0);

              //cancel pending notifications

              for (var i = 1;
                  i <= notificationsController.amountOfRepeats.value;
                  i++) {
                if (i == 1) {
                  notificationsController.cancelNotification(uniqueID);
                }
                if (notificationsController.amountOfRepeats.value > 1 &&
                    i > 1) {
                  notificationsController.cancelNotification(uniqueID + i);
                }
              }

              for (var i = 1;
                  i <= notificationsController.amountOfRepeats.value;
                  i++) {
                if (notificationsController.amountOfRepeats.value > 1 &&
                    i > 1) {
                  var finalDateTime = scheduledDateTime.add(Duration(
                      minutes:
                          notificationsController.intervalOfRepeats.value));
                  if (i > 1 && i < 3) {
                    await notificationsController.showScheduledNotification(
                      id: uniqueID + i,
                      title: 'Task reminder',
                      body: todoDescriptionController.text,
                      scheduledTime: scheduledDateTime.add(
                        Duration(
                            minutes: notificationsController
                                .intervalOfRepeats.value),
                      ),
                    );
                  }

                  if (i == 3) {
                    await notificationsController.showScheduledNotification(
                      id: uniqueID + i,
                      title: 'Task reminder',
                      body: todoDescriptionController.text,
                      scheduledTime: finalDateTime.add(
                        Duration(
                            minutes: notificationsController
                                .intervalOfRepeats.value),
                      ),
                    );
                  }
                }
              }
            }
            //schedule notofication if date is not selected and time is selected
            if (!tasksController.dateSelected.value &&
                tasksController.timeSelected.value &&
                tasksController.time.value != null) {
              var scheduledDateTime = DateTime(
                  tasksController.time.value!.year,
                  tasksController.time.value!.month,
                  tasksController.time.value!.day,
                  tasksController.time.value!.hour,
                  tasksController.time.value!.minute,
                  0,
                  0,
                  0);

              //cancel pending notifications

              for (var i = 1;
                  i <= notificationsController.amountOfRepeats.value;
                  i++) {
                if (i == 1) {
                  notificationsController.cancelNotification(uniqueID);
                }
                if (notificationsController.amountOfRepeats.value > 1 &&
                    i > 1) {
                  notificationsController.cancelNotification(uniqueID + i);
                }
              }

              for (var i = 1;
                  i <= notificationsController.amountOfRepeats.value;
                  i++) {
                if (i == 1) {
                  await notificationsController.showScheduledNotification(
                    id: uniqueID,
                    title: 'Task reminder',
                    body: todoDescriptionController.text,
                    scheduledTime: scheduledDateTime,
                  );
                }

                if (notificationsController.amountOfRepeats.value > 1 &&
                    i > 1) {
                  var finalDateTime = scheduledDateTime.add(Duration(
                      minutes:
                          notificationsController.intervalOfRepeats.value));
                  if (i > 1 && i < 3) {
                    await notificationsController.showScheduledNotification(
                      id: uniqueID + i,
                      title: 'Task reminder',
                      body: todoDescriptionController.text,
                      scheduledTime: scheduledDateTime.add(
                        Duration(
                            minutes: notificationsController
                                .intervalOfRepeats.value),
                      ),
                    );
                  }

                  if (i == 3) {
                    await notificationsController.showScheduledNotification(
                      id: uniqueID + i,
                      title: 'Task reminder',
                      body: todoDescriptionController.text,
                      scheduledTime: finalDateTime.add(
                        Duration(
                            minutes: notificationsController
                                .intervalOfRepeats.value),
                      ),
                    );
                  }
                }
              }
            }
            Get.back();
          },
          child: tasksController.todoOpenedFromTasksScreen.value!
              ? Text(
                  'updateTask'.tr,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 23.5.sp,
                    letterSpacing: 1,
                    //color: Constants.kPrimaryTextColor,
                  ),
                )
              : Text(
                  'createTask'.tr,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 23.5.sp,
                    letterSpacing: 1,
                    //color: Constants.kPrimaryTextColor,
                  ),
                ),
        ));
  }
}
