import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:get/get.dart';

import 'package:todozoid2/Database/database.dart';

import 'package:todozoid2/controllers/categories_controller.dart';
import 'package:todozoid2/helpers/custom_icons_icons.dart';
import 'package:todozoid2/models/category.dart';
import 'package:todozoid2/views/settings_screen.dart';
import 'package:todozoid2/views/tasks_diary.dart';
import 'package:todozoid2/widgets/category_edit_modal.dart';
import 'package:todozoid2/widgets/custom_slidable_action.dart';
import 'package:todozoid2/widgets/modal_fit.dart';

import '../consts/consts.dart';

class NavDrawer extends StatelessWidget {
  NavDrawer({Key? key}) : super(key: key);

  final CategoriesController _categoriesController = Get.find();

  final DatabaseController databaseController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20.0,
          top: 30.h,
        ),
        child: Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Get.to(() => SettingsScreen());
                  },
                  icon: Icon(
                    CustomIcons.settings,
                    size: 25,
                    color: context.isDarkMode
                        ? Constants.kDarkThemeTextColorAlternative
                        : Constants.kBlackTextOnWhiteBGColor,
                  ),
                  splashRadius: 1,
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    maximumSize: MaterialStateProperty.all(const Size(200, 50)),
                    padding: MaterialStateProperty.all(EdgeInsets.zero),
                    elevation: MaterialStateProperty.all(0),
                    backgroundColor:
                        MaterialStateProperty.all(Colors.transparent),
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                  ),
                  onPressed: () {
                    Get.to(() => TasksDiary());
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        CustomIcons.scroll,
                        color: context.isDarkMode
                            ? Constants.kDarkThemeTextColorAlternative
                            : Constants.kBlackTextOnWhiteBGColor,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text('diary'.tr,
                          style: TextStyle(
                            fontSize: 16,
                            color: context.isDarkMode
                                ? Constants.kDarkThemeTextColorAlternative
                                : Constants.kBlackTextOnWhiteBGColor,
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                  ),
                ),
                const AddNewCategorySection(),
              ],
            ),
            CategoriesInDrawerWidget(
                categoriesController: _categoriesController,
                databaseController: databaseController),
          ],
        ),
      ),
    );
  }
}

class AddNewCategorySection extends StatefulWidget {
  const AddNewCategorySection({
    Key? key,
  }) : super(key: key);

  @override
  State<AddNewCategorySection> createState() => _AddNewCategorySectionState();
}

class _AddNewCategorySectionState extends State<AddNewCategorySection>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'categorieslist'.tr,
          style: TextStyle(
            fontSize: 16,
            color: context.isDarkMode
                ? Constants.kDarkThemeWhiteAccentColor
                : Constants.kLightGrayColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        IconButton(
          splashColor: Colors.transparent,
          splashRadius: 1,
          color: context.isDarkMode
              ? Constants.kDarkThemeWhiteAccentColor
              : Constants.kLightGrayColor,
          icon: const Icon(CustomIcons.plus),
          onPressed: () {
            Get.bottomSheet(
              const CreateCategoryModalBottomSheet(),
              backgroundColor: context.isDarkMode
                  ? Constants.kDarkThemeBGColor
                  : Constants.kWhiteBgColor,
              isScrollControlled: true,
              ignoreSafeArea: false,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.0),
                    topRight: Radius.circular(24.0)),
              ),
            );
          },
        ),
      ],
    );
  }
}

class CategoriesInDrawerWidget extends StatelessWidget {
  CategoriesInDrawerWidget({
    Key? key,
    required CategoriesController categoriesController,
    required this.databaseController,
  })  : _categoriesController = categoriesController,
        super(key: key);

  final CategoriesController _categoriesController;
  final DatabaseController databaseController;
  final categoriesCollection = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('categories')
      .withConverter<Category>(
        fromFirestore: (snapshot, _) => Category.fromJson(snapshot.data()!),
        toFirestore: (category, _) => category.toJson(),
      );
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SlidableAutoCloseBehavior(
        child: FirestoreListView<Category>(
          primary: false,
          padding: EdgeInsets.zero,
          query: categoriesCollection.orderBy('categoryName'),
          itemBuilder: (context, snapshot) {
            Category category = snapshot.data();
            return MySlidable(
              categoriesController: _categoriesController,
              category: category,
              databaseController: databaseController,
              snapshot: snapshot,
            );
          },
        ),
      ),
    );
  }
}

class MySlidable extends StatelessWidget {
  const MySlidable({
    Key? key,
    required CategoriesController categoriesController,
    required this.category,
    required this.databaseController,
    required this.snapshot,
  })  : _categoriesController = categoriesController,
        super(key: key);

  final CategoriesController _categoriesController;
  final Category category;
  final DatabaseController databaseController;
  final QueryDocumentSnapshot<Category> snapshot;

  @override
  Widget build(BuildContext context) {
    return Slidable(
      groupTag: 0,

      key: const ValueKey(0),
      endActionPane: ActionPane(
        dragDismissible: false,
        dismissible: DismissiblePane(
          onDismissed: () {},
        ),
        extentRatio: 0.6,
        motion: const BehindMotion(),
        children: [
          MySlidableAction(
            spacing: 10,
            foregroundColor: Constants.kWhiteBgColor,
            label: 'edit'.tr,
            labelStyle: const TextStyle(
              fontSize: 11,
              //color: Constants.kPrimaryTextColor,
              fontWeight: FontWeight.bold,
            ),
            backgroundColor: Constants.kLightGrayColor,
            icon: Icons.edit_outlined,
            iconSize: 25,
            onPressed: (context) async {
              _categoriesController.categoryName.value = category.name;

              _categoriesController.selectedIndex.value = _categoriesController
                  .kCategoriesColor
                  .indexOf(category.color);

              _categoriesController.selectedCategoryID.value = snapshot.id;
              //_categoriesController.categoryIndex.value = ;

              Get.bottomSheet(
                const CategoryEditModal(),
                backgroundColor: context.isDarkMode
                    ? Constants.kDarkThemeBGColor
                    : Constants.kWhiteBgColor,
                isScrollControlled: true,
                ignoreSafeArea: false,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24.0),
                      topRight: Radius.circular(24.0)),
                ),
              );
            },
          ),
          MySlidableAction(
            spacing: 10,
            label: 'delete'.tr,
            backgroundColor: Colors.red,
            labelStyle: const TextStyle(
              fontSize: 11,
              //color: Constants.kPrimaryTextColor,
              fontWeight: FontWeight.bold,
            ),
            icon: CustomIcons.trashCan,
            iconSize: 25,
            onPressed: (context) async {
              databaseController.deleteCategory(snapshot.id);
            },
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 50,
            child: CategoryColorCircleWidget(category: category),
          ),
          const SizedBox(
            width: 10.0,
          ),
          SizedBox(
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                category.name,
                //textAlign: TextAlign.left,
                style: const TextStyle(
                  fontSize: 16,
                  //color: Constants.kPrimaryTextColor,
                  //fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      //  ListTile(
      //   minLeadingWidth: 0,
      //   contentPadding: EdgeInsets.zero,
      //   title: Text(
      //     category.name,
      //     textAlign: TextAlign.left,
      //     style: const TextStyle(
      //       fontSize: 16,
      //       //color: Constants.kPrimaryTextColor,
      //       //fontWeight: FontWeight.w600,
      //     ),
      //   ),
      //   leading: CategoryColorCircleWidget(category: category),
      // ),
    );
  }
}

class CategoryColorCircleWidget extends StatelessWidget {
  const CategoryColorCircleWidget({
    Key? key,
    required this.category,
  }) : super(key: key);

  final Category category;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 15,
      //height: double.infinity,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color(
          category.color,
        ),
      ),
    );
  }
}
