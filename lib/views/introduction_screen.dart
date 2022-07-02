import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:introduction_screen/introduction_screen.dart';

import 'package:todozoid2/controllers/introductionpage_controller.dart';
import 'package:todozoid2/helpers/helpers.dart' as helpers;

import 'package:todozoid2/routes/app_pages.dart';

import '../consts/consts.dart';

class IntroductionPage extends GetView<IntroductionPageController> {
  final introKey = GlobalKey<IntroductionScreenState>();

  IntroductionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var bodyStyle = TextStyle(
        color: Constants.kAlternativeTextColor,
        fontWeight: FontWeight.normal,
        fontSize: MediaQuery.of(context).size.width * 0.04);

    var pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(
        color: Constants.kAlternativeTextColor,
        fontWeight: FontWeight.bold,
        fontSize: MediaQuery.of(context).size.width * 0.07,
      ),
      bodyTextStyle: bodyStyle,
      descriptionPadding: const EdgeInsets.only(left: 5, right: 5),
      titlePadding: const EdgeInsets.only(bottom: 5),
      imageAlignment: Alignment.center,
      bodyAlignment: Alignment.topCenter,
      imagePadding: EdgeInsets.zero,
      contentMargin:
          EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.04),
      imageFlex: 2,
    );

    return IntroductionScreen(
      isTopSafeArea: true,
      key: introKey,
      globalBackgroundColor: Constants.kGrayBgColor,
      pages: [
        PageViewModel(
          title: "TONS OF TASKS?",
          body:
              "And you just can’t organize yourself enough to be more productive?",
          image: helpers.buildImage('introFirst.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "WE GOT YOU COVERED!",
          body: "Get yourself together with TODOlicious",
          image: helpers.buildImage('introSecond.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "TASKS",
          body:
              "Manage and track your tasks easily with a slick and easy to use UI. You will never forget to attend a meeting on time or give a call to a friend",
          image: helpers.buildImage('introThird.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "LISTS",
          body:
              "Create and organise beautiful looking lists. Always wanted to watch a movie but never had a chance? You forget to buy eggs in the store every single time? Lists are at your service!",
          image: helpers.buildImage('introFourth.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          titleWidget: const SizedBox.shrink(),
          body: 'So what are you waiting for?',
          image: helpers.buildImage('introFifth.png'),
          decoration: pageDecoration,
          footer: CupertinoButton(
            color: Constants.kAccentColor,
            child: const Text('Let\'s get started!'),
            onPressed: () {
              controller.saveIntroductionState(true);
            },
          ),
        ),
      ],
      onDone: () {
        controller.saveIntroductionState(true);
        Get.offAllNamed(Routes.home);
      },
      showSkipButton: true,
      showDoneButton: false,
      skip: const Text(
        "Skip",
        style: TextStyle(
            color: Constants.kAccentColor, fontWeight: FontWeight.w500),
      ),
      next: const Icon(
        Icons.keyboard_arrow_right,
        color: Constants.kAccentColor,
      ),
      dotsDecorator: const DotsDecorator(
        size: Size.square(10.0),
        activeSize: Size(12.0, 12.0),
        activeColor: Constants.kAccentColor,
        color: Constants.kAlternativeTextColor,
        spacing: EdgeInsets.symmetric(horizontal: 5.0),
      ),
      dotsContainerDecorator: const BoxDecoration(color: Color(0xFFEFF0F3)),
    );
  }
}
