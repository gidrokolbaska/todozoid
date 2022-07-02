import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroductionPageController extends GetxController {
  final _storageKey = 'isIntroductionCompleted';

  void saveIntroductionState(bool isSaved) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_storageKey, isSaved);
  }

  getArguments() {
    return Get.arguments;
  }
}
