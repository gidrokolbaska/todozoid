import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:todozoid2/Database/database.dart';

import 'package:todozoid2/consts/theme_service.dart';
import 'package:todozoid2/controllers/tasks_controller.dart';
import 'package:todozoid2/controllers/theme_controller.dart';
import 'package:todozoid2/helpers/custom_icons_icons.dart';
import 'package:get/get.dart';
import 'package:todozoid2/models/todo.dart';
import 'package:url_launcher/url_launcher.dart';

import '../consts/consts.dart';
import '../widgets/floating_modal.dart';

class SettingsScreen extends StatelessWidget {
  final ThemeController themeController = Get.put(ThemeController());
  final TasksController tasksController = Get.find();

  SettingsScreen({Key? key}) : super(key: key);

  //final ThemeController themeController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Constants.kWhiteBgColor,
      appBar: AppBar(
        title: Text(
          'settings'.tr,
          style: TextStyle(
            fontSize: 22.sp,
            letterSpacing: 1,
            color: context.isDarkMode
                ? Constants.kDarkThemeWhiteAccentColor
                : Constants.kAlternativeTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          //splashColor: Colors.transparent,
          splashRadius: 1,
          iconSize: 25,
          icon: const Icon(Icons.arrow_back_ios_rounded),
          color: context.isDarkMode
              ? Constants.kDarkThemeTextColor
              : Constants.kAlternativeTextColor,
          onPressed: () {
            Get.back();
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Constants.kAlternativeTextColor,
        ),
      ),
      body: SettingsBodyWidget(
        themeController: themeController,
        tasksController: tasksController,
      ),
    );
  }
}

class SettingsBodyWidget extends StatelessWidget {
  const SettingsBodyWidget({
    Key? key,
    required this.themeController,
    required this.tasksController,
  }) : super(key: key);

  final ThemeController themeController;
  final TasksController tasksController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, left: 15.0, right: 15.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          const ThemeRow(),
          const SizedBox(
            height: 10,
          ),
          Align(
            alignment: Alignment.center,
            child: RepaintBoundary(
              child: CupertinoSlidingSegmentedControl(
                  thumbColor: context.isDarkMode
                      ? Constants.kDarkThemeLightOnLightColor
                      : Constants.kWhiteBgColor,
                  backgroundColor: context.isDarkMode
                      ? Constants.kDarkThemeBGLightColor
                      : Constants.kLightGrayColor2,
                  children: {
                    0: ListTile(
                      dense: true,
                      minVerticalPadding: 0.0,
                      horizontalTitleGap: 0.0,
                      minLeadingWidth: 0.0,
                      leading: const Icon(
                        Icons.wb_sunny_outlined,
                        size: 27,
                        //color: Constants.kIconColor,
                      ),
                      title: Text(
                        'light'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height * 0.017,
                          letterSpacing: 1,
                          color: context.isDarkMode
                              ? Constants.kDarkThemeTextColor
                              : Constants.kAlternativeTextColor,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    1: ListTile(
                      dense: true,
                      minVerticalPadding: 0.0,
                      horizontalTitleGap: 0.0,
                      minLeadingWidth: 0,
                      leading: Icon(
                        CustomIcons.moon,
                        color: context.isDarkMode
                            ? Constants.kDarkThemeWhiteAccentColor
                            : Constants.kAlternativeTextColor,
                      ),
                      title: Text(
                        'dark'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height * 0.017,
                          letterSpacing: 1,
                          color: context.isDarkMode
                              ? Constants.kDarkThemeTextColor
                              : Constants.kAlternativeTextColor,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  },
                  groupValue: themeController.selectedIndex.value,
                  onValueChanged: (int? newValue) {
                    themeController.selectedIndex.value = newValue!;

                    ThemeService().changeThemeMode();
                  }),
            ),
          ),
          const SizedBox(
            height: 20.0,
          ),
          Expanded(
            child: SettingsActionsWidget(
              tasksController: tasksController,
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsActionsWidget extends StatelessWidget {
  SettingsActionsWidget({
    Key? key,
    required this.tasksController,
  }) : super(key: key);
  final TasksController tasksController;
  final InAppReview inAppReview = InAppReview.instance;
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.topCenter,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                inAppReview.openStoreListing();
              },
              icon: const Icon(
                Icons.reviews_outlined,
                size: 35,
              ),
              label: Text(
                'review'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height * 0.022,
                  letterSpacing: 1,
                  //color: Constants.kIconColor,
                  fontWeight: FontWeight.normal,
                ),
              ),
              style: ButtonStyle(
                foregroundColor: context.isDarkMode
                    ? MaterialStateProperty.all(
                        Constants.kDarkThemeWhiteAccentColor)
                    : MaterialStateProperty.all(
                        Constants.kAlternativeTextColor),
                padding: MaterialStateProperty.all(EdgeInsets.zero),
                elevation: MaterialStateProperty.all(0),
                backgroundColor: MaterialStateProperty.all(Colors.transparent),
                //shadowColor: MaterialStateProperty.all(Colors.transparent),
                overlayColor: MaterialStateProperty.all(Colors.transparent),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                String? encodeQueryParameters(Map<String, String> params) {
                  return params.entries
                      .map((e) =>
                          '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
                      .join('&');
                }

                final Uri emailLaunchUri = Uri(
                  scheme: 'mailto',
                  path: 'gidroskolbasovich@gmail.com',
                  query: encodeQueryParameters(<String, String>{
                    'subject': 'Submit the bug below',
                    'body':
                        'If for some reason the recipient is not auto populated, please send the report to gidroskolbasovich@gmail.com \r\n \r\nPlease describe the bug here:'
                  }),
                );

                launchUrl(emailLaunchUri);
              },
              icon: const Icon(
                Icons.bug_report_outlined,
                size: 35,
              ),
              label: Text(
                'bug'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height * 0.022,
                  letterSpacing: 1,
                  //color: Constants.kIconColor,
                  fontWeight: FontWeight.normal,
                ),
              ),
              style: ButtonStyle(
                foregroundColor: context.isDarkMode
                    ? MaterialStateProperty.all(
                        Constants.kDarkThemeWhiteAccentColor)
                    : MaterialStateProperty.all(
                        Constants.kAlternativeTextColor),
                padding: MaterialStateProperty.all(EdgeInsets.zero),
                elevation: MaterialStateProperty.all(0),
                backgroundColor: MaterialStateProperty.all(Colors.transparent),
                //shadowColor: MaterialStateProperty.all(Colors.transparent),
                overlayColor: MaterialStateProperty.all(Colors.transparent),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    await showFloatingModalBottomSheet(
                      context: context,
                      builder: (context) => SizedBox(
                        height: 0.3.sh,
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(
                              initialItem: tasksController
                                  .amountOfDailyGoalToSelect
                                  .indexOf(tasksController.dailyGoal.value)),
                          onSelectedItemChanged: (value) {
                            tasksController.dailyGoal.value = value + 1;
                          },
                          itemExtent: 45,
                          diameterRatio: 1,
                          magnification: 1.3,
                          useMagnifier: true,
                          looping: true,
                          children: tasksController.amountOfDailyGoalToSelect
                              .map((item) => Text(
                                    '$item',
                                    style: TextStyle(fontSize: 35.sp),
                                  ))
                              .toList(),
                        ),
                      ),
                    );

                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .collection('todosDaily')
                        .doc('dailyRequirement')
                        .set({'amount': tasksController.dailyGoal.value},
                            SetOptions(merge: true));
                    //print(tasksController.dailyGoal.value);
                  },
                  icon: const Icon(
                    Icons.flag_outlined,
                    size: 35,
                  ),
                  label: Text(
                    'dailygoal'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.022,
                      letterSpacing: 1,
                      //color: Constants.kIconColor,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  style: ButtonStyle(
                    foregroundColor: context.isDarkMode
                        ? MaterialStateProperty.all(
                            Constants.kDarkThemeWhiteAccentColor)
                        : MaterialStateProperty.all(
                            Constants.kAlternativeTextColor),
                    padding: MaterialStateProperty.all(EdgeInsets.zero),
                    elevation: MaterialStateProperty.all(0),
                    backgroundColor:
                        MaterialStateProperty.all(Colors.transparent),
                    //shadowColor: MaterialStateProperty.all(Colors.transparent),
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                  ),
                ),
                Obx(
                  () => Text(
                    '${tasksController.dailyGoal.value}',
                    style: const TextStyle(fontSize: 20.0),
                  ),
                ),
              ],
            ),
          ],
        ),
        Positioned(
          bottom: 0.03.sh,
          child: ElevatedButton.icon(
            onPressed: () async {
              await handleSignOut();
            },
            icon: const Icon(Icons.logout_outlined),
            label: Text('signOut'.tr),
          ),
        ),
      ],
    );
  }
}

Future handleSignOut() async {
  try {
    return await FirebaseAuth.instance.signOut().then((value) async {
      Get.deleteAll();

      Get.back();
    });
  } catch (e) {
    return (e);
  }
}

class ThemeRow extends StatelessWidget {
  const ThemeRow({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(
          CustomIcons.show,
          color: context.isDarkMode
              ? Constants.kDarkThemeWhiteAccentColor
              : Constants.kAlternativeTextColor,
        ),
        const SizedBox(
          width: 25.0,
        ),
        Text(
          'theme'.tr,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18.sp,
            letterSpacing: 1,
            color: context.isDarkMode
                ? Constants.kDarkThemeWhiteAccentColor
                : Constants.kAlternativeTextColor,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
