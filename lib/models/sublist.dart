class Sublist {
  String? sublistDescription;
  bool? sublistIsDone;

  Sublist({this.sublistDescription, this.sublistIsDone});
  Map<String, Object?> toJson() {
    return {
      'sublistIsDone': sublistIsDone,
      'sublistDescription': sublistDescription,
    };
  }

  Sublist.fromJson(Map<String, dynamic> json) {
    sublistDescription = json['sublistDescription'];
    sublistIsDone = json['sublistIsDone'];
  }
}
