import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../Database/database.dart';
import '../consts/consts.dart';

import '../models/todo.dart';

class MinimalItem extends StatelessWidget {
  const MinimalItem({
    Key? key,
    required this.todo,
    required this.fireStoreData,
    required this.databaseController,
  }) : super(key: key);
  final Todo todo;

  final DatabaseController databaseController;

  final QueryDocumentSnapshot<Todo> fireStoreData;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.only(right: 20.0),
      horizontalTitleGap: 0,
      minVerticalPadding: 0,
      leading: Checkbox(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        fillColor: MaterialStateProperty.all(context.isDarkMode
            ? Constants.kDarkThemeAccentColor
            : Constants.kAccentColor),
        value: todo.isDone,
        onChanged: (value) async {
          databaseController.updateTodo(fireStoreData, {
            'isDone': value,
            'whenCompleted': null,
          });
        },
      ),
      title: Text(
        todo.description!,
        style: const TextStyle(fontWeight: FontWeight.normal),
      ),
      trailing: todo.subTodos != null && todo.subTodos!.isNotEmpty
          ? const Icon(Icons.list_outlined)
          : null,
    );
  }
}
