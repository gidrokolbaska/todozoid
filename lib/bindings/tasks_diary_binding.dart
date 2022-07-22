import 'package:get/get.dart';

import '../controllers/tasks_diary_controller.dart';

class TasksDiaryBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(() => ListsController());
  }
}
