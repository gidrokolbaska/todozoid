import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Todo {
  String? description;
  String? categoryReference;
  List<dynamic>? subTodos;

  Timestamp? todoDate;
  Timestamp? todoTime;
  bool? isDone;
  Timestamp? whenCompleted;
  String? notes;
  Todo({
    this.categoryReference,
    this.description,
    this.isDone,
    this.notes,
    this.todoDate,
    this.todoTime,
    this.subTodos,
    this.whenCompleted,
  });

  Todo.fromJson(Map<String, Object?> json)
      : this(
          description: json['description'] as String,
          todoDate: json['day'] != null ? json['day'] as Timestamp : null,
          notes: json['note'] != null ? json['note'] as String : '',
          categoryReference:
              json['category'] != null ? json['category'] as String : '',
          isDone: json['isDone'] as bool,
          todoTime: json['time'] != null ? json['time'] as Timestamp : null,
          subTodos: json['subtodos'] != null
              ? json['subtodos'] as List<dynamic>
              : null,
          whenCompleted: json['whenCompleted'] != null
              ? json['whenCompleted'] as Timestamp
              : null,
        );
  Map<String, Object?> toJson() {
    return {
      'description': description,
      'day': todoDate,
      'note': notes,
      'category': categoryReference,
      'isDone': isDone,
      'time': todoTime,
      'subtodos': subTodos,
      'whenCompleted': whenCompleted
    };
  }
}

final todosCollection = FirebaseFirestore.instance
    .collection('users')
    .doc(FirebaseAuth.instance.currentUser!.uid)
    .collection('todos')
    .withConverter<Todo>(
      fromFirestore: (snapshot, _) => Todo.fromJson(snapshot.data()!),
      toFirestore: (todo, _) => todo.toJson(),
    );
