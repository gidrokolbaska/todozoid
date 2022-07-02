//import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  var selectedIndex = 0.obs;
  @override
  void onInit() {
    if (Get.isDarkMode) {
      selectedIndex.value = 1;
    }

    super.onInit();
  }
}
