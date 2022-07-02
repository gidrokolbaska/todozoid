import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todozoid2/views/dashboard_screen.dart';
import 'package:todozoid2/views/lists_screen.dart';

import 'package:todozoid2/views/tasks_screen.dart';

class NavigationBarController extends GetxController {
  final selectedIndex = 1.obs;

  final appbarTitles = RxList<String>(['tasks'.tr, 'dashboard'.tr, 'lists'.tr]);

  String get title => appbarTitles[selectedIndex.value];

  List<Widget> pageList = [
    TasksScreen(),
    DashboardScreen(),
    const ListsScreen()
  ];

  changePage(int index) {
    if (selectedIndex.value != index) {
      selectedIndex.value = index;
    } else {
      return;
    }
  }

  Widget resultingPage() {
    return pageList.elementAt(selectedIndex.value);
  }
}
