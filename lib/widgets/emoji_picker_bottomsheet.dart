import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:todozoid2/controllers/tasks_diary_controller.dart';
import '../consts/consts.dart';

class EmojiPickerBottomSheet extends StatelessWidget {
  EmojiPickerBottomSheet({Key? key}) : super(key: key);
  final TasksDiaryController tasksDiaryController = Get.find();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 0.4.sh,
      child: EmojiPicker(
        onEmojiSelected: (category, emoji) {
          // Do something when emoji is tapped
          //print(emoji.emoji);
          tasksDiaryController.emojiSelected.value = true;
          Get.back(result: emoji.emoji);
        },
        // onBackspacePressed: () {
        //   // Backspace-Button tapped logic
        //   // Remove this line to also remove the button in the UI
        // },
        config: Config(
          columns: 7,
          emojiSizeMax: 32 *
              (Platform.isIOS
                  ? 1.30
                  : 1.0), // Issue: https://github.com/flutter/flutter/issues/28894
          verticalSpacing: 0,
          horizontalSpacing: 0,
          initCategory: Category.RECENT,
          bgColor: context.isDarkMode
              ? Constants.kDarkThemeBGColor
              : Constants.kGrayBgColor,
          indicatorColor: context.isDarkMode
              ? Constants.kDarkThemeAccentColor
              : Constants.kAccentColor,
          iconColor: context.isDarkMode
              ? Constants.kDarkThemeAccentColor
              : Constants.kDarkThemeAccentColor,
          iconColorSelected: Constants.kAccentColor,
          progressIndicatorColor: context.isDarkMode
              ? Constants.kDarkThemeAccentColor
              : Constants.kAccentColor,

          skinToneDialogBgColor: context.isDarkMode
              ? Constants.kDarkThemeBGLightColor
              : Constants.kGrayBgColor,
          skinToneIndicatorColor: Colors.grey,
          enableSkinTones: true,
          showRecentsTab: false,
          recentsLimit: 28,
          noRecents: const Text(
            'No Recents',
            style: TextStyle(fontSize: 20, color: Colors.black26),
            textAlign: TextAlign.center,
          ),
          tabIndicatorAnimDuration: kTabScrollDuration,
          categoryIcons: const CategoryIcons(),
          buttonMode:
              Platform.isIOS ? ButtonMode.CUPERTINO : ButtonMode.MATERIAL,
        ),
      ),
    );
  }
}
