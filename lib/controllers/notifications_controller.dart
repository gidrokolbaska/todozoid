import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:get/get.dart';

import 'navigation_bar_controller.dart';

class NotificationsController extends GetxController {
  late NavigationBarController navigationBarController;
  final amountOfRepeats = 3.obs;
  final intervalOfRepeats = 15.obs;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('ic_alarm');
  static const IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings(
    requestSoundPermission: true,
    requestBadgePermission: true,
    requestAlertPermission: true,
  );

  static const InitializationSettings initializationSettings =
      InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  @override
  void onReady() {
    super.onReady();
    navigationBarController = Get.put(NavigationBarController());
  }

  int initialItemForinterval() {
    switch (intervalOfRepeats.value) {
      case 5:
        return 0;
      case 10:
        return 1;
      case 15:
        return 2;
      case 20:
        return 3;
      default:
        return 0;
    }
  }

  @override
  void onInit() async {
    tz.initializeTimeZones();
    final locationName = await FlutterNativeTimezone.getLocalTimezone();

    tz.setLocalLocation(tz.getLocation(locationName));
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) async {
      if (payload != null) {
        navigationBarController.selectedIndex.value = 0;
      }
    });

    super.onInit();
  }

  int createUniqueID(int maxValue) {
    Random random = Random();
    return random.nextInt(maxValue);
  }

  void cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future showScheduledNotification({
    int? id = 0,
    String? title,
    String? body,
    String? payload,
    required DateTime scheduledTime,
  }) async =>
      await flutterLocalNotificationsPlugin.zonedSchedule(
          id!,
          title,
          body,
          tz.TZDateTime.from(scheduledTime, tz.local),
          NotificationDetails(
            android: AndroidNotificationDetails(
              '$id',
              'taskReminder'.tr,
              channelDescription: 'Task reminders notification channel',
              colorized: true,
              largeIcon: const DrawableResourceAndroidBitmap('ic_launcher'),
            ),
            iOS: const IOSNotificationDetails(
              threadIdentifier: 'test_ID',
              //badgeNumber: 0,
              //),
            ),
          ),
          payload: payload,
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime);
}
