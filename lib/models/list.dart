import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ListTask {
  String name;
  String? icon;
  List<dynamic>? subLists;

  ListTask({
    required this.name,
    this.icon,
    this.subLists,
  });

  ListTask.fromJson(Map<String, Object?> json)
      : this(
          name: json['name'] as String,
          icon: json['icon'] != null ? json['icon'] as String : null,
          subLists: json['sublists'] != null
              ? json['sublists'] as List<dynamic>
              : null,
        );
  Map<String, Object?> toJson() {
    return {
      'name': name,
      'sublists': subLists,
      'icon': icon,
    };
  }
}

final listsCollection = FirebaseFirestore.instance
    .collection('users')
    .doc(FirebaseAuth.instance.currentUser!.uid)
    .collection('lists')
    .withConverter<ListTask>(
      fromFirestore: (snapshot, _) => ListTask.fromJson(snapshot.data()!),
      toFirestore: (list, _) => list.toJson(),
    );
