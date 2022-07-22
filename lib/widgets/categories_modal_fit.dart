import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:get/get.dart';

import '../Database/database.dart';
import '../controllers/categories_controller.dart';

import '../models/category.dart';
import '../models/todo.dart';

class CategoriesModalFit extends StatelessWidget {
  CategoriesModalFit({Key? key, this.queryData}) : super(key: key);
  final CategoriesController _categoriesController = Get.find();
  final DatabaseController databaseController = Get.find();
  final QueryDocumentSnapshot<Todo>? queryData;
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
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 0.5.sh,
        child: Column(
          children: [
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: () => Get.back(),
              icon: const Icon(Icons.keyboard_arrow_down),
              iconSize: 30.0,
            ),
            Expanded(
              child: FirestoreListView<Category>(
                padding: EdgeInsets.zero,
                query: categoriesCollection.orderBy('categoryName'),
                itemBuilder: (context, snapshot) {
                  Category category = snapshot.data();
                  return ListTile(
                    onTap: () {
                      if (_categoriesController
                          .isCategoryModalOpenedFromTasksScreen.value) {
                        _categoriesController.selectedCategoryID.value =
                            snapshot.id;
                        databaseController.updateTodo(queryData!, {
                          'category':
                              _categoriesController.selectedCategoryID.value
                        });
                        _categoriesController
                            .isCategoryModalOpenedFromTasksScreen.value = false;
                      } else {
                        _categoriesController.isCategorySelected.value = true;

                        _categoriesController
                            .selectedCategoryForNewTask!.value = category;
                        _categoriesController.selectedCategoryID.value =
                            snapshot.id;
                      }

                      Get.back();
                    },
                    minLeadingWidth: 18,
                    //contentPadding: EdgeInsets.all(0),
                    title: Text(
                      category.name,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 16.sp,
                      ),
                    ),
                    leading: Container(
                      width: 15,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(category.color),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
