import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Category {
  final String name;
  final int color;
  Category({
    required this.name,
    required this.color,
  });

  Category.fromJson(Map<String, Object?> json)
      : this(
          name: json['categoryName']! as String,
          color: json['categoryColor']! as int,
        );
  Map<String, Object?> toJson() {
    return {
      'categoryName': name,
      'categoryColor': color,
    };
  }
}

final categoriesCollection = FirebaseFirestore.instance
    .collection('users')
    .doc(FirebaseAuth.instance.currentUser!.uid)
    .collection('categories')
    .withConverter<Category>(
      fromFirestore: (snapshot, _) => Category.fromJson(snapshot.data()!),
      toFirestore: (category, _) => category.toJson(),
    );
