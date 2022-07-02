import 'package:get/get.dart';
import 'package:todozoid2/controllers/categories_controller.dart';
import 'package:todozoid2/controllers/notifications_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Get.put(CategoriesController());

    Get.lazyPut(() => CategoriesController());
    Get.lazyPut(() => NotificationsController());
  }
}
