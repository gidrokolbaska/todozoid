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
