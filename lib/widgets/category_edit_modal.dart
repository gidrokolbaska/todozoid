import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:get/get.dart';

import 'package:todozoid2/Database/database.dart';
import 'package:todozoid2/controllers/categories_controller.dart';
import 'package:todozoid2/widgets/shake_widget.dart';

class CategoryEditModal extends StatefulWidget {
  const CategoryEditModal({Key? key}) : super(key: key);

  @override
  State<CategoryEditModal> createState() => _CategoryEditModalState();
}

class _CategoryEditModalState extends State<CategoryEditModal>
    with SingleTickerProviderStateMixin {
  final editingController = TextEditingController();
  final CategoriesController _categoriesController = Get.find();
  final DatabaseController _databaseController = Get.find();
  late ShakeController shakeController;
  @override
  void initState() {
    super.initState();
    shakeController = ShakeController(vsync: this);
  }

  @override
  void dispose() {
    super.dispose();

    editingController.dispose();
    shakeController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 0.5.sh,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          ShakeView(
            controller: shakeController,
            child: TextField(
                autocorrect: false,
                controller: editingController
                  ..text = _categoriesController.categoryName.value
                  ..selection = TextSelection.fromPosition(
                    TextPosition(offset: editingController.text.length),
                  ),
                keyboardAppearance:
                    context.isDarkMode ? Brightness.dark : Brightness.light,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(
                    RegExp(r"^\s"),
                  ),
                ],
                onEditingComplete: () async {
                  if (editingController.text.isEmpty) {
                    shakeController.shake();
                    Vibrate.feedback(FeedbackType.error);
                    return;
                  }
                  _databaseController.updateCategory(
                      _categoriesController.selectedCategoryID.value!,
                      FirebaseAuth.instance.currentUser!.uid, {
                    'categoryName': editingController.text,
                    'categoryColor': _categoriesController.kCategoriesColor[
                        _categoriesController.selectedIndex.value]
                  });
                  _categoriesController.selectedCategoryID.value = null;

                  Get.back();
                  //editingController.dispose();
                },
                decoration: InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Obx(() => Container(
                          width: 1,
                          height: 1,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(_categoriesController
                                      .kCategoriesColor[
                                  _categoriesController.selectedIndex.value])),
                        )),
                  ),
                  hintText: 'categoryName'.tr,
                  hintStyle: TextStyle(
                    fontSize: 16.sp,
                    //color: Constants.kPrimaryTextColor,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                autofocus: true),
          ),
          const SizedBox(
            height: 50.0,
          ),
          Container(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: GridView.count(
              shrinkWrap: true,
              primary: false,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              crossAxisCount: 8,
              children: _categoriesController.availableColorsForCategories,
            ),
          ),
        ],
      ),
    );
  }
}
