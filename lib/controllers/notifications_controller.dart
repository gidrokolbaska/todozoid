import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:todozoid2/controllers/navigation_bar_controller.dart';

class NotificationsController extends GetxController {
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
  late NavigationBarController navigationBarController;

  @override
  void onReady() {
    super.onReady();
    navigationBarController = Get.put(NavigationBarController());
  }

  @override
  void onInit() async {
    super.onInit();
    tz.initializeTimeZones();
    final locationName = await FlutterNativeTimezone.getLocalTimezone();

    tz.setLocalLocation(tz.getLocation(locationName));
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) async {
      if (payload != null) {
        navigationBarController.selectedIndex.value = 0;
      }
      // selectedNotificationPayload = payload;
      // selectNotificationSubject.add(payload);
    });
  }

  void showScheduledNotification({
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
            iOS: const IOSNotificationDetails(threadIdentifier: 'test_ID'),
          ),
          payload: payload,
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime);

  void cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}
