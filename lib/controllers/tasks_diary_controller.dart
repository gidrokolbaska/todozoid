import 'package:get/get.dart';

class TasksDiaryController extends GetxController {
  final RxnString selectedEmoji = RxnString();
  final RxBool emojiSelected = RxBool(false);
  final listOpenedFromListsScreen = false.obs;
}
