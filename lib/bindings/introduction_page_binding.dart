import 'package:get/get.dart';

import 'package:todozoid2/controllers/introductionpage_controller.dart';

class IntroductionPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<IntroductionPageController>(IntroductionPageController());
  }
}
