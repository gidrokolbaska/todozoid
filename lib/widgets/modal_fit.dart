import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:get/get.dart';

import '../Database/database.dart';
import '../controllers/categories_controller.dart';

import '../models/category.dart';
import 'shake_widget.dart';

class CreateCategoryModalBottomSheet extends StatefulWidget {
  const CreateCategoryModalBottomSheet({
    Key? key,
  }) : super(key: key);

  @override
  State<CreateCategoryModalBottomSheet> createState() =>
      _CreateCategoryModalBottomSheetState();
}

class _CreateCategoryModalBottomSheetState
    extends State<CreateCategoryModalBottomSheet>
    with SingleTickerProviderStateMixin {
  final CategoriesController _categoriesController =
      Get.put(CategoriesController());

  final DatabaseController databaseController = Get.find();
  late ShakeController shakeController;
  late TextEditingController textEditingController;
  @override
  void initState() {
    super.initState();
    shakeController = ShakeController(vsync: this);
    textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    shakeController.dispose();
    textEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 0.5.sh,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        //mainAxisSize: MainAxisSize.min,
        children: [
          ShakeView(
            controller: shakeController,
            child: TextField(
              controller: textEditingController,
              autocorrect: false,
              keyboardAppearance:
                  context.isDarkMode ? Brightness.dark : Brightness.light,
              inputFormatters: [
                FilteringTextInputFormatter.deny(
                  RegExp(r"^\s"),
                ),
              ],
              onEditingComplete: () {
                if (textEditingController.text.isEmpty) {
                  shakeController.shake();
                  Vibrate.feedback(FeedbackType.error);
                  return;
                }
                databaseController.addCategory(Category(
                    name: textEditingController.text,
                    color: _categoriesController.kCategoriesColor[
                        _categoriesController.selectedIndex.value]));
                Get.back();
              },
              //onSubmitted: (categoryNameTextField) async {},
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
                            color: Color(_categoriesController.kCategoriesColor[
                                _categoriesController.selectedIndex.value])),
                      )),
                ),
                hintText: 'categoryName'.tr,
                hintStyle: const TextStyle(
                  fontSize: 16,
                  //color: Constants.kPrimaryTextColor,
                  fontWeight: FontWeight.normal,
                ),
              ),
              autofocus: true,
            ),
          ),
          const SizedBox(
            height: 50.0,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: GridView.count(
                shrinkWrap: true,
                primary: false,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                crossAxisCount: 8,
                children: _categoriesController.availableColorsForCategories),
          ),
        ],
      ),
    );
  }
}
