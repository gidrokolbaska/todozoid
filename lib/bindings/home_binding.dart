import 'package:get/get.dart';
import '../controllers/categories_controller.dart';
import '../controllers/notifications_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Get.put(CategoriesController());

    Get.lazyPut(() => CategoriesController());
    Get.lazyPut(() => NotificationsController());
  }
}
