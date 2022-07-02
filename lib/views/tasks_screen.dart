import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'package:flutter/material.dart';

import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:get/get.dart';

import 'package:todozoid2/Database/database.dart';
import 'package:todozoid2/controllers/categories_controller.dart';
import 'package:todozoid2/controllers/notifications_controller.dart';

import 'package:todozoid2/controllers/tasks_controller.dart';

import 'package:todozoid2/models/category.dart';

import 'package:todozoid2/models/todo.dart';

import 'package:todozoid2/widgets/firestoreQueryBuilderNew.dart';

import '../widgets/todo_tile_widget.dart';

class TasksScreen extends StatelessWidget {
  TasksScreen({Key? key}) : super(key: key);

  final TasksController tasksController = Get.put(TasksController());

  final DatabaseController databaseController = Get.find();
  final NotificationsController notificationsController = Get.find();
  final CategoriesController categoriesController =
      Get.put(CategoriesController());
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        SlidableAutoCloseBehavior(
          child: Obx(
            () => FirestoreQueryBuilderNew<Todo>(
              pageSize: 40,
              query: todosCollection.where('isDone', isEqualTo: false).orderBy(
                  (() {
                    if (tasksController.sortedByValue.value == 0) {
                      return 'description';
                    }
                    if (tasksController.sortedByValue.value == 1) {
                      return 'isDone';
                    } else {
                      return 'day';
                    }
                  }()),
                  descending: true),
              builder: (context, todoSnapshot, child) {
                if (todoSnapshot.isFetching) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (todoSnapshot.hasError) {
                  return Text('Something went wrong! ${todoSnapshot.error}');
                }
                if (todoSnapshot.docs.isEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                    tasksController.todosEmpty.value = true;
                  });

                  return Center(
                      child: Text(
                    'noactive'.tr,
                    style: TextStyle(fontSize: 15.sp),
                  ));
                } else if (todoSnapshot.docs.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                    tasksController.todosEmpty.value = false;
                  });
                }
                return ListView.separated(
                  physics: const ClampingScrollPhysics(),
                  controller: scrollController,
                  padding: const EdgeInsets.only(
                    left: 20.0,
                    right: 20.0,
                    bottom: 100.0,
                  ),
                  itemCount: todoSnapshot.docs.length,
                  separatorBuilder: (BuildContext context, int index) {
                    return const SizedBox(
                      height: 15.0,
                    );
                  },
                  itemBuilder: (context, index) {
                    if (todoSnapshot.hasMore &&
                        index + 1 == todoSnapshot.docs.length) {
                      // Tell FirestoreQueryBuilder to try to obtain more items.
                      // It is safe to call this function from within the build method.
                      todoSnapshot.fetchMore();
                    }

                    Todo todo = todoSnapshot.docs[index].data();
                    return FirestoreQueryBuilderNew<Category>(
                      query: categoriesCollection,
                      builder: (context, snapshot, child) {
                        Category? category;
                        String? categoryReferenceID;
                        if (snapshot.isFetching) {
                          return const CircularProgressIndicator();
                        }
                        for (var element in snapshot.docs) {
                          if (element.id == todo.categoryReference) {
                            category = element.data();

                            categoryReferenceID = element.id;
                          }
                        }

                        return AnimationConfiguration.staggeredList(
                          delay: const Duration(milliseconds: 100),
                          position: index,
                          duration: const Duration(milliseconds: 300),
                          child: SlideAnimation(
                            child: ScaleAnimation(
                              child: Item(
                                notificationsController:
                                    notificationsController,
                                categoriesController: categoriesController,
                                databaseController: databaseController,
                                fireStoreData: todoSnapshot.docs[index],
                                firestoreCategoryData: category,
                                categoryReferenceID: categoryReferenceID,
                                color: category?.color,
                                todo: todo,
                                tasksController: tasksController,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
