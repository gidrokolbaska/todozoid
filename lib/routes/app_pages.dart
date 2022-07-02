import 'package:get/get.dart';
import 'package:todozoid2/bindings/home_binding.dart';
import 'package:todozoid2/bindings/login_binding.dart';
import 'package:todozoid2/main.dart';
import 'package:todozoid2/views/home_page.dart';
import '../bindings/tasks_diary_binding.dart';
import '../views/tasks_diary.dart';
part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.login;

  static final routes = [
    GetPage(
      name: _Paths.home,
      page: () => HomePageContainer(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.login,
      page: () => AuthGate(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.tasksDiary,
      page: () => TasksDiary(),
      binding: TasksDiaryBinding(),
    ),
  ];
}
