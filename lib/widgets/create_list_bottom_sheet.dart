import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:get/get.dart';

import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../helpers/custom_icons_icons.dart';
import '../models/list.dart';
import '../models/sublist.dart';
import 'shake_widget.dart';

import '../Database/database.dart';
import '../consts/consts.dart';
import '../controllers/tasks_diary_controller.dart';
import 'emoji_picker_bottomsheet.dart';

class CreateListBottomSheetWidget extends StatefulWidget {
  const CreateListBottomSheetWidget({Key? key, this.firestoreData})
      : super(key: key);
  final QueryDocumentSnapshot<ListTask>? firestoreData;
  @override
  State<CreateListBottomSheetWidget> createState() =>
      _CreateListBottomSheetWidgetState();
}

class _CreateListBottomSheetWidgetState
    extends State<CreateListBottomSheetWidget> with TickerProviderStateMixin {
  final ListsController listsController = Get.find();
  final DatabaseController _databaseController = Get.find();
  final listKey = GlobalKey<AnimatedListState>();
  ScrollController scrollController = ScrollController();
  TextEditingController listDescriptionController = TextEditingController();
  late ShakeController shakeController;
  final FocusNode mainFocusNode = FocusNode();
  List<Sublist> subList = [];
  List<TextEditingController> sublistTextEditingController = [];
  List<ShakeController> sublistShakeControllers = [];
  List<FocusNode> sublistFocusNodes = [];

  @override
  void initState() {
    shakeController = ShakeController(vsync: this);
    //Here we perform the checks if list modal view was opened by clicking on the existing list
    if (listsController.listOpenedFromListsScreen.value) {
      //Assign name of the list

      listDescriptionController.text = widget.firestoreData!.data().name;
      //Assign the icon of the list
      if (widget.firestoreData!.data().icon != null) {
        listsController.emojiSelected.value = true;
        listsController.selectedEmoji.value = widget.firestoreData!.data().icon;
      }
      //Assign sublists
      if (widget.firestoreData!.data().subLists != null) {
        subList = widget.firestoreData!
            .data()
            .subLists!
            .map((e) => Sublist(
                sublistDescription: e['sublistDescription'],
                sublistIsDone: e['sublistIsDone']))
            .toList();

        for (var i = 0; i < subList.length; i++) {
          FocusNode focusNode = FocusNode();
          sublistFocusNodes.insert(i, focusNode);
          sublistTextEditingController.insert(
              i, TextEditingController(text: subList[i].sublistDescription));
          listKey.currentState
              ?.insertItem(i, duration: const Duration(milliseconds: 200));
          sublistShakeControllers.insert(i, ShakeController(vsync: this));
        }
      }
    }
    Future.delayed(const Duration(milliseconds: 350))
        .then((value) => mainFocusNode.requestFocus());
    super.initState();
  }

  @override
  void dispose() {
    listsController.emojiSelected.value = false;
    listsController.listOpenedFromListsScreen.value = false;
    listsController.selectedEmoji.value = null;
    mainFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Column(children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              if (listDescriptionController.text.isEmpty) {
                shakeController.shake();
                Vibrate.feedback(FeedbackType.error);
                return;
              }
              //Generating a proper list for subtodos. Maybe it is possible to do it in a more proper way, but that works as well
              List finalListWithSublists = [];
              for (int i = 0; i < subList.length; i++) {
                //simple check if a newly added subtodo has a text. If it doesn't then we just skip it
                if (sublistTextEditingController[i].text.isNotEmpty) {
                  finalListWithSublists.add({
                    "sublistDescription": sublistTextEditingController[i].text,
                    "sublistIsDone": subList[i].sublistIsDone,
                  });
                }
              }
              listsController.listOpenedFromListsScreen.value
                  ? _databaseController.updateList(
                      widget.firestoreData!,
                      {
                        'name': listDescriptionController.text,
                        'sublists': finalListWithSublists,
                        'icon': listsController.emojiSelected.value
                            ? ' ${listsController.selectedEmoji.value} '
                            : null,
                      },
                    )
                  : _databaseController.addList(
                      ListTask(
                        name: listDescriptionController.text,
                        icon: listsController.emojiSelected.value
                            ? ' ${listsController.selectedEmoji.value} '
                            : null,
                        subLists: finalListWithSublists,
                      ),
                    );
              Get.back();
            },
            child: listsController.listOpenedFromListsScreen.value
                ? Text(
                    'updateList'.tr,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 23.5.sp,
                      letterSpacing: 1,
                      //color: Constants.kPrimaryTextColor,
                    ),
                  )
                : Text(
                    'createList'.tr,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 23.5.sp,
                      letterSpacing: 1,
                      //color: Constants.kPrimaryTextColor,
                    ),
                  ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: ListView(
              //itemExtent: 40,
              controller: scrollController,
              padding: EdgeInsets.zero,
              children: [
                ShakeView(
                  controller: shakeController,
                  child: TextField(
                    // autofocus: true,
                    focusNode: mainFocusNode,
                    controller: listDescriptionController,
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
                      hintText: 'listNameTextField'.tr,
                      isCollapsed: true,
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Obx(
                  () => AnimatedSwitcher(
                    layoutBuilder: (currentChild, previousChildren) {
                      return Stack(
                        alignment: Alignment.topCenter,
                        fit: StackFit.loose,
                        children: [
                          ...previousChildren,
                          if (currentChild != null) currentChild,
                        ],
                      );
                    },
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: child,
                      );
                    },
                    child: listsController.emojiSelected.value
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                  onPressed: () async {
                                    listsController.selectedEmoji.value =
                                        await showMaterialModalBottomSheet(
                                      isDismissible: true,
                                      enableDrag: false,
                                      expand: false,
                                      context: context,
                                      backgroundColor: Colors.transparent,
                                      builder: (context) =>
                                          EmojiPickerBottomSheet(),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 30,
                                  )),
                              Text(
                                ' ${listsController.selectedEmoji.value!} ',
                                style: const TextStyle(
                                  fontSize: 75,
                                ),
                              ),
                              IconButton(
                                  onPressed: () {
                                    listsController.selectedEmoji.value = null;
                                    listsController.emojiSelected.value = false;
                                  },
                                  icon: const Icon(
                                    Icons.delete_outline_outlined,
                                    size: 30,
                                  )),
                            ],
                          )
                        : SelectAnImojiButton(
                            listsController: listsController,
                          ),
                  ),
                ),
                subList.isNotEmpty
                    ? AnimatedList(
                        physics: const NeverScrollableScrollPhysics(),
                        key: listKey,
                        shrinkWrap: true,
                        initialItemCount: subList.length,
                        itemBuilder: (context, index, animation) {
                          //this check is neccessary when we invoke insertSubtask() for the first time
                          //and is not executed when todo is opened from TasksScreen and has subtasks>0

                          if (subList.length == 1 &&
                              !listsController
                                  .listOpenedFromListsScreen.value) {
                            SchedulerBinding.instance
                                .addPostFrameCallback((timeStamp) {
                              scrollController.animateTo(
                                scrollController.position.maxScrollExtent,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.fastOutSlowIn,
                              );
                            });
                          }
                          animation.addStatusListener(
                            (status) {
                              if (status == AnimationStatus.completed) {
                                scrollController.animateTo(
                                  scrollController.position.maxScrollExtent,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.fastOutSlowIn,
                                );
                              }
                            },
                          );

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
                                      subList[index].sublistIsDone = value;
                                    });
                                  },
                                  value: subList[index].sublistIsDone,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5)),
                                  fillColor: MaterialStateProperty.all(
                                      context.isDarkMode
                                          ? Constants.kDarkThemeAccentColor
                                          : Constants.kAccentColor),
                                ),
                                title: TitleForSubListWidget(
                                  index: index,
                                  sublistFocusNodes: sublistFocusNodes,
                                  sublists: subList,
                                  sublistShakeControllers:
                                      sublistShakeControllers,
                                  sublistTextEditingController:
                                      sublistTextEditingController,
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : const SizedBox.shrink(),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        insertSublist();
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
                      'addItem'.tr,
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
      ]),
    );
  }

  void insertSublist() async {
    late int lastIndex;

    if (subList.isNotEmpty) {
      lastIndex = subList.length;
    } else {
      lastIndex = 0;
    }
    if (sublistTextEditingController.isNotEmpty &&
        sublistTextEditingController[lastIndex - 1].text.isEmpty) {
      sublistShakeControllers[lastIndex - 1].shake();

      Vibrate.feedback(FeedbackType.error);
      return;
    }
    FocusNode focusNode = FocusNode();
    sublistFocusNodes.insert(lastIndex, focusNode);

    sublistTextEditingController.insert(lastIndex, TextEditingController());
    var newSublist = Sublist(
      sublistIsDone: false,
    );
    subList.insert(lastIndex, newSublist);
    listKey.currentState
        ?.insertItem(lastIndex, duration: const Duration(milliseconds: 200));
    sublistShakeControllers.insert(lastIndex, ShakeController(vsync: this));
    sublistFocusNodes[lastIndex].requestFocus();

    //this is the only way I figured out in order the scrolling to work correctly
    //await Future.delayed(const Duration(milliseconds: 250));
  }
}

class TitleForSubListWidget extends StatelessWidget {
  const TitleForSubListWidget({
    Key? key,
    required this.sublistShakeControllers,
    required this.sublistFocusNodes,
    required this.sublists,
    required this.sublistTextEditingController,
    required this.index,
  }) : super(key: key);

  final List<ShakeController> sublistShakeControllers;
  final List<FocusNode> sublistFocusNodes;
  final List<Sublist> sublists;
  final List<TextEditingController> sublistTextEditingController;
  final int index;

  @override
  Widget build(BuildContext context) {
    return ShakeView(
      controller: sublistShakeControllers[index],
      child: TextField(
        textInputAction: TextInputAction.next,
        autofocus: false,
        focusNode: sublistFocusNodes[index],

        onSubmitted: (value) {
          sublists[index].sublistDescription =
              sublistTextEditingController[index].text;
          FocusScope.of(context).unfocus();
        },

        style: TextStyle(
            color: context.isDarkMode
                ? sublists[index].sublistIsDone!
                    ? Constants.kAlternativeTextColor
                    : Constants.kDarkThemeTextColor
                : sublists[index].sublistIsDone!
                    ? Constants.kLightGrayColor
                    : Constants.kBlackTextOnWhiteBGColor),
        //autofocus: true,

        controller: sublistTextEditingController[index],

        keyboardAppearance:
            context.isDarkMode ? Brightness.dark : Brightness.light,
        inputFormatters: [
          FilteringTextInputFormatter.deny(
            RegExp(r"^\s"),
          ),
        ],
        textAlign: TextAlign.left,
        decoration: InputDecoration(
          hintText: 'newItem'.tr,
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

class SelectAnImojiButton extends StatelessWidget {
  const SelectAnImojiButton({
    Key? key,
    required this.listsController,
  }) : super(key: key);

  final ListsController listsController;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
        onPressed: () async {
          listsController.selectedEmoji.value =
              await showMaterialModalBottomSheet(
            isDismissible: true,
            enableDrag: false,
            expand: false,
            context: context,
            backgroundColor: Colors.transparent,
            builder: (context) => EmojiPickerBottomSheet(),
          );
        },
        icon: const Icon(Icons.emoji_emotions_outlined),
        label: Text('pickIcon'.tr));
  }
}
