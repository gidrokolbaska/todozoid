import 'package:animations/animations.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:todozoid2/controllers/notifications_controller.dart';
import '../Database/database.dart';

import '../controllers/navigation_bar_controller.dart';
import '../controllers/tasks_controller.dart';

import '../helpers/custom_icons_icons.dart';

import '../widgets/drawer_widget.dart';

import '../consts/consts.dart';
import '../controllers/categories_controller.dart';
import '../widgets/create_list_bottom_sheet.dart';
import '../widgets/create_task_modal.dart';

class HomePageContainer extends StatelessWidget {
  HomePageContainer({Key? key}) : super(key: key);
  final DatabaseController databaseController = Get.put(DatabaseController());
  final NavigationBarController _navigationController =
      Get.put(NavigationBarController());
  final TasksController tasksController = Get.find();
  final categoriesController =
      Get.lazyPut<CategoriesController>(() => CategoriesController());
  final NotificationsController notificationsController =
      Get.put(NotificationsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      drawer: NavDrawer(),
      appBar: AppBar(
        centerTitle: false,
        title: Title(
          navigationController: _navigationController,
          tasksController: tasksController,
        ),
        leading: const LeadingWidget(),
        elevation: 0,
      ),
      body: Obx(() =>
          // _navigationController.resultingPage(),
          PageTransitionSwitcher(
            transitionBuilder: (
              child,
              animation,
              secondaryAnimation,
            ) {
              return FadeThroughTransition(
                //fillColor: Colors.transparent,
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                child: child,
              );
            },
            child: _navigationController.resultingPage(),
          )),
      bottomNavigationBar:
          BottomNavBar(navigationController: _navigationController),
      floatingActionButton: MyConditionalFab(
        controller: _navigationController,
      ),
    );
  }
}

class MyConditionalFab extends StatelessWidget {
  const MyConditionalFab({
    super.key,
    required this.controller,
  });
  final NavigationBarController controller;
  @override
  Widget build(BuildContext context) {
    return Obx(() => controller.selectedIndex.value == 0 ||
            controller.selectedIndex.value == 2
        ? FloatingActionButton(
            enableFeedback: false,
            onPressed: () {
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
                builder: (context) => controller.selectedIndex.value == 0
                    ? const TaskModalView()
                    : const CreateListBottomSheetWidget(),
              );
            },
            child: Icon(CustomIcons.plus,
                color: context.isDarkMode
                    ? Constants.kDarkThemeWhiteAccentColor
                    : Constants.kLightGrayColor2),
          )
        : const SizedBox.shrink());
  }
}

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    Key? key,
    required NavigationBarController navigationController,
  })  : _navigationController = navigationController,
        super(key: key);

  final NavigationBarController _navigationController;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75.h,
      decoration: BoxDecoration(
        color: context.isDarkMode
            ? Constants.kDarkThemeBGLightColor
            : Constants.kWhiteBgColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(14),
          topRight: Radius.circular(14),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 3.0,
            spreadRadius: 1.0,
            offset: Offset(1.0, 0.0), // shadow direction: bottom right
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                _navigationController.changePage(0);
              },
              child: Obx(
                () => Icon(CustomIcons.check,
                    size: 25,
                    color: _navigationController.selectedIndex.value == 0
                        ? context.isDarkMode
                            ? Constants.kDarkThemeAccentColor
                            : Constants.kAccentColor
                        : !context.isDarkMode
                            ? Constants.kBlackTextOnWhiteBGColor
                            : Constants.kDarkThemeTextColor),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                _navigationController.changePage(1);
              },
              child: Obx(() => Icon(CustomIcons.home,
                  size: 25,
                  color: _navigationController.selectedIndex.value == 1
                      ? context.isDarkMode
                          ? Constants.kDarkThemeAccentColor
                          : Constants.kAccentColor
                      : !context.isDarkMode
                          ? Constants.kBlackTextOnWhiteBGColor
                          : Constants.kDarkThemeTextColor)),
            ),
          ),
          Expanded(
            child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  _navigationController.changePage(2);
                },
                child: Obx(() => Icon(CustomIcons.lists,
                    size: 25,
                    color: _navigationController.selectedIndex.value == 2
                        ? context.isDarkMode
                            ? Constants.kDarkThemeAccentColor
                            : Constants.kAccentColor
                        : !context.isDarkMode
                            ? Constants.kBlackTextOnWhiteBGColor
                            : Constants.kDarkThemeTextColor))),
          ),
        ],
      ),
    );
  }
}

class LeadingWidget extends StatelessWidget {
  const LeadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
        splashRadius: 0.1,
        //splashColor: Colors.transparent,
        iconSize: 15,
        icon: const Icon(CustomIcons.drawerLeft),
        color: context.isDarkMode
            ? Constants.kDarkThemeTextColor
            : Constants.kAlternativeTextColor,
        onPressed: () {
          Scaffold.of(context).openDrawer();
        });
  }
}

class Title extends StatelessWidget {
  const Title({
    Key? key,
    required NavigationBarController navigationController,
    required this.tasksController,
  })  : _navigationController = navigationController,
        super(key: key);

  final NavigationBarController _navigationController;
  final TasksController tasksController;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Obx(
        () => tasksController.todosEmpty.value
            ? Text(
                _navigationController.title,
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 25.sp),
              )
            : _navigationController.selectedIndex.value == 0
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      PopupMenuButton(
                        color: context.isDarkMode
                            ? Constants.kDarkThemeBGLightColor
                            : Constants.kWhiteBgColor,
                        offset: const Offset(40, 12),
                        position: PopupMenuPosition.under,
                        splashRadius: 0.1,
                        icon: const Icon(Icons.filter_alt_outlined),
                        onSelected: (value) {
                          switch (value) {
                            case 'Description':
                              tasksController.sortedByValue.value = 0;
                              break;
                            case 'Completion':
                              tasksController.sortedByValue.value = 1;
                              break;
                            case 'Date':
                              tasksController.sortedByValue.value = 2;
                              break;
                            default:
                              tasksController.sortedByValue.value = 0;
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem<String>(
                            value: 'Description',
                            child: Text(
                              'sortByDescription'.tr,
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'Date',
                            child: Text(
                              'sortByDate'.tr,
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'Category',
                            child: Text(
                              'sortByCategory'.tr,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _navigationController.title,
                        textAlign: TextAlign.right,
                        style: TextStyle(fontSize: 25.sp),
                      )
                    ],
                  )
                : Text(
                    _navigationController.title,
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 25.sp),
                  ),
      ),
    );
  }
}
