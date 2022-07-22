import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:todozoid2/controllers/tasks_controller.dart';
import '../controllers/notifications_controller.dart';
import '../models/category.dart';
import '../models/list.dart';
import '../models/todo.dart';

class DatabaseController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late StreamSubscription<ConnectivityResult> subscription;
  final isConnected = false.obs;
  //CollectionReference users = FirebaseFirestore.instance.collection('users');
  final NotificationsController notificationsController =
      Get.put(NotificationsController());
  final TasksController tasksController = Get.put(TasksController());
  final _firebaseAuth = FirebaseAuth.instance;
  final todosCollection = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('todos')
      .withConverter<Todo>(
        fromFirestore: (snapshot, _) => Todo.fromJson(snapshot.data()!),
        toFirestore: (todo, _) => todo.toJson(),
      );
  final categoriesCollection = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('categories')
      .withConverter<Category>(
        fromFirestore: (snapshot, _) => Category.fromJson(snapshot.data()!),
        toFirestore: (category, _) => category.toJson(),
      );
  final listsCollection = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('lists')
      .withConverter<ListTask>(
        fromFirestore: (snapshot, _) => ListTask.fromJson(snapshot.data()!),
        toFirestore: (list, _) => list.toJson(),
      );
  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }

  @override
  void onInit() async {
    super.onInit();

    await createDefaultsForNewUser();
    subscription = Connectivity().onConnectivityChanged.listen(
      (ConnectivityResult result) async {
        if (result == ConnectivityResult.none) {
          await FirebaseFirestore.instance.disableNetwork();

          isConnected.value = false;
        } else if (result == ConnectivityResult.mobile ||
            result == ConnectivityResult.wifi) {
          await FirebaseFirestore.instance.enableNetwork();

          isConnected.value = true;
        }
      },
    );
  }

  Future<bool> checkExist() async {
    var snapshot = await firestore
        .collection('users')
        .doc(_firebaseAuth.currentUser!.uid)
        .get(const GetOptions(source: Source.serverAndCache));

    if (snapshot.exists) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> createDefaultsForNewUser() async {
    try {
      if (await checkExist() == false) {
        var batch = firestore.batch();
        firestore.collection('users').doc(_firebaseAuth.currentUser!.uid).set({
          'email': _firebaseAuth.currentUser!.email,
          'amountOfRepeats': 3,
          'intervalOfRepeats': 15,
          'dailyRequirement': 10,
        });
        firestore
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get(const GetOptions(source: Source.serverAndCache))
            .then((value) {
          if (value['amountOfRepeats'] != null &&
              value['intervalOfRepeats'] != null &&
              value['dailyRequirement'] != null) {
            notificationsController.amountOfRepeats.value =
                value.data()!['amountOfRepeats'];
            notificationsController.intervalOfRepeats.value =
                value.data()!['intervalOfRepeats'];
            tasksController.dailyGoal.value = value.data()!['dailyRequirement'];
          }
        });
        var categories = firestore
            .collection('users')
            .doc(_firebaseAuth.currentUser!.uid)
            .collection('categories');

        List<Map<String, dynamic>> defaultCategories = [
          {
            "categoryColor": 0xFF4CFFA6,
            "categoryName": "work".tr,
          },
          {
            "categoryColor": 0xFFFF5DA1,
            "categoryName": "home".tr,
          },
          {
            "categoryColor": 0xFFFF0000,
            "categoryName": "shopping".tr,
          },
          {
            "categoryColor": 0xFFbc433a,
            "categoryName": "personal".tr,
          }
        ];
        for (var i = 0; i < defaultCategories.length; i++) {
          var docReference = categories.doc();
          batch.set(docReference, defaultCategories[i]);
        }
        batch.commit();
      }
      firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get(const GetOptions(source: Source.serverAndCache))
          .then((value) {
        if (value['amountOfRepeats'] != null &&
            value['intervalOfRepeats'] != null &&
            value['dailyRequirement'] != null) {
          notificationsController.amountOfRepeats.value =
              value.data()!['amountOfRepeats'];
          notificationsController.intervalOfRepeats.value =
              value.data()!['intervalOfRepeats'];
          tasksController.dailyGoal.value = value.data()!['dailyRequirement'];
        }
      });
      return true;
    } catch (e) {
      return false;
    }
  }

//CATEGORIES CRUD OPERARIONS
  Future addCategory(Category category) async {
    await categoriesCollection.add(category);
  }

  Future updateCategory(
      String catID, String uid, Map<String, Object> data) async {
    await categoriesCollection.doc(catID).update(data);
  }

  Future deleteCategory(String catID) async {
    await categoriesCollection.doc(catID).delete();
  }

//TODOS CRUD OPERATIONS
  Future addTodo(
    Todo todo,
  ) async {
    await todosCollection.add(todo);
  }

  Future updateTodo(
    QueryDocumentSnapshot<Todo> queryData,
    Map<String, Object?> data,
  ) async {
    // await notificationsController.flutterLocalNotificationsPlugin
    //     .cancel(queryData.reference.id.hashCode);
    await queryData.reference.update(data);
  }

  Future deleteTodo(QueryDocumentSnapshot<Todo> queryData) async {
    for (var i = 1; i <= notificationsController.amountOfRepeats.value; i++) {
      if (i == 1) {
        await notificationsController.flutterLocalNotificationsPlugin
            .cancel(queryData.data().uniqueNotificationID!);
      }
      if (notificationsController.amountOfRepeats.value > 1 && i > 1) {
        await notificationsController.flutterLocalNotificationsPlugin
            .cancel(queryData.data().uniqueNotificationID! + i);
      }
    }

    await queryData.reference.delete();
  }

//LISTS CRUD OPERATIONS
  Future addList(ListTask list) async {
    await listsCollection.add(list);
  }

  Future updateList(QueryDocumentSnapshot<ListTask> queryData,
      Map<String, Object?> data) async {
    await queryData.reference.update(data);
  }

  Future deleteList(QueryDocumentSnapshot<ListTask> queryData) async {
    await queryData.reference.delete();
  }

//MISC CRUD OPERATIONS
  Future<void> signOut() async {
    //await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
  }

  Future updateAmountOfRepeats(int value) async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'amountOfRepeats': value});
  }

  Future updateInterval(int value) async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'intervalOfRepeats': value});
  }
}
