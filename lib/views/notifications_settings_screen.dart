import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:todozoid2/consts/consts.dart';
import 'package:todozoid2/controllers/notifications_controller.dart';
import 'package:todozoid2/widgets/floating_modal.dart';

class NotificationsSettings extends StatelessWidget {
  NotificationsSettings({super.key});
  final NotificationsController notificationsController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //backgroundColor: Constants.kWhiteBgColor,
        appBar: AppBar(
          title: Text(
            'notifications'.tr,
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
        body: Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 15.0, right: 15.0),
          child: Column(
            children: [
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
                              initialItem: notificationsController
                                      .amountOfRepeats.value -
                                  1,
                            ),
                            onSelectedItemChanged: (value) {
                              notificationsController.amountOfRepeats.value =
                                  value + 1;
                            },
                            itemExtent: 45,
                            diameterRatio: 1,
                            magnification: 1.3,
                            useMagnifier: true,
                            looping: false,
                            children: [
                              Text(
                                '1',
                                style: TextStyle(fontSize: 35.sp),
                              ),
                              Text(
                                '2',
                                style: TextStyle(fontSize: 35.sp),
                              ),
                              Text(
                                '3',
                                style: TextStyle(fontSize: 35.sp),
                              ),
                            ],
                          ),
                        ),
                      );

                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .update({
                        'amountOfRepeats':
                            notificationsController.amountOfRepeats.value
                      });
                      //print(tasksController.dailyGoal.value);
                    },
                    icon: const Icon(
                      Icons.repeat_one_rounded,
                      size: 35,
                    ),
                    label: Text(
                      'amountOfRepeats'.tr,
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
                      overlayColor:
                          MaterialStateProperty.all(Colors.transparent),
                    ),
                  ),
                  Obx(
                    () => Text(
                      '${notificationsController.amountOfRepeats.value}',
                      style: const TextStyle(fontSize: 20.0),
                    ),
                  ),
                ],
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
                                initialItem: notificationsController
                                    .initialItemForinterval()),
                            onSelectedItemChanged: (value) {
                              notificationsController.intervalOfRepeats.value =
                                  value * 5 + 5;
                            },
                            itemExtent: 45,
                            diameterRatio: 1,
                            magnification: 1.3,
                            useMagnifier: true,
                            looping: false,
                            children: [
                              Text(
                                '5',
                                style: TextStyle(fontSize: 35.sp),
                              ),
                              Text(
                                '10',
                                style: TextStyle(fontSize: 35.sp),
                              ),
                              Text(
                                '15',
                                style: TextStyle(fontSize: 35.sp),
                              ),
                              Text(
                                '20',
                                style: TextStyle(fontSize: 35.sp),
                              ),
                            ],
                          ),
                        ),
                      );

                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .update({
                        'intervalOfRepeats':
                            notificationsController.intervalOfRepeats.value
                      });
                      //print(tasksController.dailyGoal.value);
                    },
                    icon: const Icon(
                      Icons.av_timer_outlined,
                      size: 35,
                    ),
                    label: Text(
                      'intervalOfRepeats'.tr,
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
                      overlayColor:
                          MaterialStateProperty.all(Colors.transparent),
                    ),
                  ),
                  Obx(
                    () => Text(
                      '${notificationsController.intervalOfRepeats.value}',
                      style: const TextStyle(fontSize: 20.0),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
