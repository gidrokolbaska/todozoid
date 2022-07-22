import 'package:get/get.dart';

class ListsController extends GetxController {
  final RxnString selectedEmoji = RxnString();
  final RxBool emojiSelected = RxBool(false);
  final listOpenedFromListsScreen = false.obs;
}
