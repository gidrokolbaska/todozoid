import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:todozoid2/controllers/notifications_controller.dart';
import 'package:todozoid2/models/category.dart';
import 'package:todozoid2/models/list.dart';
import 'package:todozoid2/models/todo.dart';

class DatabaseController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  //CollectionReference users = FirebaseFirestore.instance.collection('users');
  final NotificationsController notificationsController =
      Get.put(NotificationsController());
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
  void onInit() async {
    super.onInit();
    await createDefaultsForNewUser();
  }

  Future<bool> checkExist() async {
    var snapshot = await firestore
        .collection('users')
        .doc(_firebaseAuth.currentUser!.uid)
        .get();

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
      return true;
    } catch (e) {
      return false;
    }
  }

//CATEGORIES CRUD OPERARIONS
  addCategory(Category category) async {
    await categoriesCollection.add(category);
  }

  updateCategory(String catID, String uid, Map<String, Object> data) async {
    await categoriesCollection.doc(catID).update(data);
  }

  deleteCategory(String catID) async {
    await categoriesCollection.doc(catID).delete();
  }

//TODOS CRUD OPERATIONS
  Future<int> addTodo(Todo todo, [int? extractedID]) async {
    await todosCollection.add(todo).then((value) {
      extractedID = value.id.hashCode;
    });
    return extractedID!;
  }

  Future<int> updateTodo(
      QueryDocumentSnapshot<Todo> queryData, Map<String, Object?> data,
      [int? extractedID]) async {
    // await notificationsController.flutterLocalNotificationsPlugin
    //     .cancel(queryData.reference.id.hashCode);
    await queryData.reference
        .update(data)
        .then((value) => extractedID = queryData.reference.id.hashCode);
    return extractedID!;
  }

  deleteTodo(QueryDocumentSnapshot<Todo> queryData) async {
    for (var i = 1; i <= notificationsController.amountOfRepeats.value; i++) {
      if (i == 1) {
        await notificationsController.flutterLocalNotificationsPlugin
            .cancel(queryData.reference.id.hashCode);
      }
      if (notificationsController.amountOfRepeats.value > 1 && i > 1) {
        await notificationsController.flutterLocalNotificationsPlugin
            .cancel(queryData.reference.id.hashCode + i);
      }
    }

    await queryData.reference.delete();
  }

//LISTS CRUD OPERATIONS
  addList(ListTask list) async {
    await listsCollection.add(list);
  }

  updateList(QueryDocumentSnapshot<ListTask> queryData,
      Map<String, Object?> data) async {
    await queryData.reference.update(data);
  }

  deleteList(QueryDocumentSnapshot<ListTask> queryData) async {
    await queryData.reference.delete();
  }

//MISC CRUD OPERATIONS
  Future<void> signOut() async {
    //await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
  }
}
