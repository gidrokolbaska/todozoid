import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:todozoid2/Database/database.dart';
import 'package:todozoid2/models/todo.dart';
import 'package:todozoid2/widgets/firestoreQueryBuilderNew.dart';
import '../consts/consts.dart';
import '../widgets/minimal_item_from_task_diary.dart';

class TasksDiary extends StatelessWidget {
  TasksDiary({Key? key}) : super(key: key);
  final DatabaseController databaseController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'diary'.tr,
          style: TextStyle(
            fontSize: 22.sp,
            letterSpacing: 1,
            color: context.isDarkMode
                ? Constants.kDarkThemeWhiteAccentColor
                : Constants.kAlternativeTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          //splashColor: Colors.transparent,
          splashRadius: 1,
          iconSize: 25,
          icon: const Icon(Icons.arrow_back_ios_rounded),
          color: context.isDarkMode
              ? Constants.kDarkThemeTextColor
              : Constants.kAlternativeTextColor,
          onPressed: () {
            Get.back();
          },
        ),
        //backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Constants.kAlternativeTextColor,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 20.0,
          right: 20.0,
        ),
        child: FirestoreQueryBuilderNew(
          query: databaseController.todosCollection
              .where('isDone', isEqualTo: true)
              .orderBy('whenCompleted', descending: true),
          builder: (BuildContext context,
              FirestoreQueryBuilderSnapshot<Todo> snapshot, Widget? child) {
            if (snapshot.isFetching) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Text('Something went wrong! ${snapshot.error}');
            }
            if (snapshot.hasMore) {
              snapshot.fetchMore();
            }
            return GroupedListView<QueryDocumentSnapshot<Todo>, Timestamp>(
              stickyHeaderBackgroundColor: context.isDarkMode
                  ? Constants.kDarkThemeBGColor
                  : Constants.kGrayBgColor,
              useStickyGroupSeparators: true,
              elements: snapshot.docs,
              groupBy: (element) => element.data().whenCompleted!,
              itemBuilder: (context, element) {
                Todo todo = element.data();

                return MinimalItem(
                  todo: todo,
                  fireStoreData: element,
                  databaseController: databaseController,
                );
              },
              groupComparator: (value1, value2) => value2.compareTo(value1),
              groupSeparatorBuilder: (Timestamp groupByValue) => Text(
                DateFormat('MMMMd', Platform.localeName)
                    .format(groupByValue.toDate())
                    .toUpperCase(),
                style: TextStyle(
                    fontSize: 30.sp,
                    fontWeight: FontWeight.bold,
                    color: context.isDarkMode
                        ? Constants.kDarkThemeWhiteAccentColor
                        : Constants.kAlternativeTextColor),
              ),
            );
          },
        ),
      ),
    );
  }
}
