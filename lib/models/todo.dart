import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  String? description;
  String? categoryReference;
  List<dynamic>? subTodos;

  Timestamp? todoDate;
  Timestamp? todoTime;
  bool? isDone;
  Timestamp? whenCompleted;
  String? notes;
  int? uniqueNotificationID;
  Todo({
    this.categoryReference,
    this.description,
    this.isDone,
    this.notes,
    this.todoDate,
    this.todoTime,
    this.subTodos,
    this.whenCompleted,
    this.uniqueNotificationID,
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
          uniqueNotificationID: json['uniqueNotificationID'] != null
              ? json['uniqueNotificationID'] as int
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
      'whenCompleted': whenCompleted,
      'uniqueNotificationID': uniqueNotificationID,
    };
  }
}
