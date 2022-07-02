class Subtodo {
  String? subDescription;
  bool? subIsDone;

  Subtodo({this.subDescription, this.subIsDone});
  Map<String, Object?> toJson() {
    return {
      'subIsDone': subIsDone,
      'subDescription': subDescription,
    };
  }

  Subtodo.fromJson(Map<String, dynamic> json) {
    subDescription = json['subDescription'];
    subIsDone = json['subIsDone'];
  }
}
