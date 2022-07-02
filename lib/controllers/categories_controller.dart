import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/category.dart';

class CategoriesController extends GetxController {
  List<int> kCategoriesColor = [
    0xFF4CFFA6,
    0xFFFF5DA1,
    0xFFFF0000,
    0xFFbc433a,
    0xFF94949f,
    0xFFe0fbfc,
    0xFF212121,
    0xFF8e2225,
    0xFFab795e,
    0xFF35345c,
    0xFF7d9050,
    0xFF3c539f,
    0xFF3f3f3f,
    0xFFba9a33,
    0xFF6b4ea9,
    0xFF378dc2,
  ].obs;
  RxList<DocumentSnapshot> categories = RxList();
  late List<Widget> availableColorsForCategories;
  RxBool isCategoryModalOpenedFromTasksScreen = RxBool(false);
  RxBool isDateModalOpenedFromTasksScreen = RxBool(false);
  RxBool isTimeModalOpenedFromTasksScreen = RxBool(false);
  @override
  void onInit() {
    super.onInit();

    availableColorsForCategories =
        List.generate(kCategoriesColor.length, (index) {
      return Obx(
        () => ChoiceChip(
          selectedColor: Color(kCategoriesColor[index]),
          backgroundColor: Color(kCategoriesColor[index]),
          label: Visibility(
            replacement: const SizedBox.expand(),
            visible: selectedIndex.value == index,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(width: 2, color: Colors.white)),
            ),
          ),
          selected: selectedIndex.value == index,
          onSelected: (bool selected) {
            selectedIndex.value = (selected ? index : null)!;
          },
        ),
      );
    });
  }

  var selectedIndex = 0.obs;

  var categoryName = ''.obs;
  final selectedCategoryID = RxnString();

  Rxn<Category>? selectedCategoryForNewTask = Rxn();
  var selectedColorForNewTask = 0.obs;
  var isCategorySelected = false.obs;
}
