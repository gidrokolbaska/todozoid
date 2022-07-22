import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:todozoid2/Database/database.dart';
import '../consts/theme_service.dart';
import '../controllers/tasks_controller.dart';
import '../controllers/theme_controller.dart';
import '../helpers/custom_icons_icons.dart';
import 'package:get/get.dart';
import '../routes/app_pages.dart';
import 'notifications_settings_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../consts/consts.dart';
import '../widgets/floating_modal.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ThemeController themeController = Get.put(ThemeController());

  final TasksController tasksController = Get.find();
  final DatabaseController _databaseController = Get.find();

  //final ThemeController themeController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Constants.kWhiteBgColor,
      appBar: AppBar(
        title: Text(
          'settings'.tr,
          style: TextStyle(
            fontSize: 22.sp,
            letterSpacing: 1,
            color: context.isDarkMode
                ? Constants.kDarkThemeWhiteAccentColor
                : Constants.kAlternativeTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          //splashColor: Colors.transparent,
          splashRadius: 1,
          iconSize: 25,
          icon: const Icon(Icons.arrow_back_ios_rounded),
          color: context.isDarkMode
              ? Constants.kDarkThemeTextColor
              : Constants.kAlternativeTextColor,
          onPressed: () {
            Get.back();
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Constants.kAlternativeTextColor,
        ),
      ),
      body: SettingsBodyWidget(
        themeController: themeController,
        tasksController: tasksController,
        databaseController: _databaseController,
      ),
    );
  }
}

class SettingsBodyWidget extends StatelessWidget {
  const SettingsBodyWidget({
    Key? key,
    required this.themeController,
    required this.tasksController,
    required this.databaseController,
  }) : super(key: key);

  final ThemeController themeController;
  final TasksController tasksController;
  final DatabaseController databaseController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, left: 15.0, right: 15.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          const ThemeRow(),
          const SizedBox(
            height: 10,
          ),
          Align(
            alignment: Alignment.center,
            child: CupertinoSlidingSegmentedControl(
                thumbColor: context.isDarkMode
                    ? Constants.kDarkThemeLightOnLightColor
                    : Constants.kWhiteBgColor,
                backgroundColor: context.isDarkMode
                    ? Constants.kDarkThemeBGLightColor
                    : Constants.kLightGrayColor2,
                children: {
                  0: ListTile(
                    dense: true,
                    minVerticalPadding: 0.0,
                    horizontalTitleGap: 0.0,
                    minLeadingWidth: 0.0,
                    leading: const Icon(
                      Icons.wb_sunny_outlined,
                      size: 27,
                      //color: Constants.kIconColor,
                    ),
                    title: Text(
                      'light'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        letterSpacing: 1,
                        color: context.isDarkMode
                            ? Constants.kDarkThemeTextColor
                            : Constants.kAlternativeTextColor,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  1: ListTile(
                    dense: true,
                    minVerticalPadding: 0.0,
                    horizontalTitleGap: 0.0,
                    minLeadingWidth: 0,
                    leading: Icon(
                      CustomIcons.moon,
                      color: context.isDarkMode
                          ? Constants.kDarkThemeWhiteAccentColor
                          : Constants.kAlternativeTextColor,
                    ),
                    title: Text(
                      'dark'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height * 0.017,
                        letterSpacing: 1,
                        color: context.isDarkMode
                            ? Constants.kDarkThemeTextColor
                            : Constants.kAlternativeTextColor,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                },
                groupValue: themeController.selectedIndex.value,
                onValueChanged: (int? newValue) {
                  themeController.selectedIndex.value = newValue!;

                  ThemeService().changeThemeMode();
                }),
          ),
          const SizedBox(
            height: 20.0,
          ),
          Expanded(
            child: SettingsActionsWidget(
              tasksController: tasksController,
              databaseController: databaseController,
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsActionsWidget extends StatefulWidget {
  const SettingsActionsWidget({
    Key? key,
    required this.tasksController,
    required this.databaseController,
  }) : super(key: key);
  final TasksController tasksController;
  final DatabaseController databaseController;

  @override
  State<SettingsActionsWidget> createState() => _SettingsActionsWidgetState();
}

class _SettingsActionsWidgetState extends State<SettingsActionsWidget> {
  final InAppReview inAppReview = InAppReview.instance;
  bool isWorking = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.topCenter,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                inAppReview.openStoreListing(appStoreId: '1634769736');
              },
              icon: const Icon(
                Icons.reviews_outlined,
                size: 35,
              ),
              label: Text(
                'review'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height * 0.022,
                  letterSpacing: 1,
                  //color: Constants.kIconColor,
                  fontWeight: FontWeight.normal,
                ),
              ),
              style: ButtonStyle(
                foregroundColor: context.isDarkMode
                    ? MaterialStateProperty.all(
                        Constants.kDarkThemeWhiteAccentColor)
                    : MaterialStateProperty.all(
                        Constants.kAlternativeTextColor),
                padding: MaterialStateProperty.all(EdgeInsets.zero),
                elevation: MaterialStateProperty.all(0),
                backgroundColor: MaterialStateProperty.all(Colors.transparent),
                //shadowColor: MaterialStateProperty.all(Colors.transparent),
                overlayColor: MaterialStateProperty.all(Colors.transparent),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                String? encodeQueryParameters(Map<String, String> params) {
                  return params.entries
                      .map((e) =>
                          '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
                      .join('&');
                }

                final Uri emailLaunchUri = Uri(
                  scheme: 'mailto',
                  path: 'gidroskolbasovich@gmail.com',
                  query: encodeQueryParameters(<String, String>{
                    'subject': 'Submit the bug below',
                    'body':
                        'If for some reason the recipient is not auto populated, please send the report to gidroskolbasovich@gmail.com \r\n \r\nPlease describe the bug here:'
                  }),
                );

                launchUrl(emailLaunchUri);
              },
              icon: const Icon(
                Icons.bug_report_outlined,
                size: 35,
              ),
              label: Text(
                'bug'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height * 0.022,
                  letterSpacing: 1,
                  //color: Constants.kIconColor,
                  fontWeight: FontWeight.normal,
                ),
              ),
              style: ButtonStyle(
                foregroundColor: context.isDarkMode
                    ? MaterialStateProperty.all(
                        Constants.kDarkThemeWhiteAccentColor)
                    : MaterialStateProperty.all(
                        Constants.kAlternativeTextColor),
                padding: MaterialStateProperty.all(EdgeInsets.zero),
                elevation: MaterialStateProperty.all(0),
                backgroundColor: MaterialStateProperty.all(Colors.transparent),
                //shadowColor: MaterialStateProperty.all(Colors.transparent),
                overlayColor: MaterialStateProperty.all(Colors.transparent),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Get.to(() => NotificationsSettings());
              },
              icon: const Icon(
                Icons.notifications_none_outlined,
                size: 35,
              ),
              label: Text(
                'notifications'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height * 0.022,
                  letterSpacing: 1,
                  //color: Constants.kIconColor,
                  fontWeight: FontWeight.normal,
                ),
              ),
              style: ButtonStyle(
                foregroundColor: context.isDarkMode
                    ? MaterialStateProperty.all(
                        Constants.kDarkThemeWhiteAccentColor)
                    : MaterialStateProperty.all(
                        Constants.kAlternativeTextColor),
                padding: MaterialStateProperty.all(EdgeInsets.zero),
                elevation: MaterialStateProperty.all(0),
                backgroundColor: MaterialStateProperty.all(Colors.transparent),
                //shadowColor: MaterialStateProperty.all(Colors.transparent),
                overlayColor: MaterialStateProperty.all(Colors.transparent),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    await showFloatingModalBottomSheet(
                      context: context,
                      builder: (context) => SizedBox(
                        height: 0.3.sh,
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(
                              initialItem: widget
                                  .tasksController.amountOfDailyGoalToSelect
                                  .indexOf(
                                      widget.tasksController.dailyGoal.value)),
                          onSelectedItemChanged: (value) {
                            widget.tasksController.dailyGoal.value = value + 1;
                          },
                          itemExtent: 45,
                          diameterRatio: 1,
                          magnification: 1.3,
                          useMagnifier: true,
                          looping: true,
                          children:
                              widget.tasksController.amountOfDailyGoalToSelect
                                  .map((item) => Text(
                                        '$item',
                                        style: TextStyle(fontSize: 35.sp),
                                      ))
                                  .toList(),
                        ),
                      ),
                    );
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .update({
                      'dailyRequirement': widget.tasksController.dailyGoal.value
                    });
                    //print(tasksController.dailyGoal.value);
                  },
                  icon: const Icon(
                    Icons.flag_outlined,
                    size: 35,
                  ),
                  label: Text(
                    'dailygoal'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.022,
                      letterSpacing: 1,
                      //color: Constants.kIconColor,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  style: ButtonStyle(
                    foregroundColor: context.isDarkMode
                        ? MaterialStateProperty.all(
                            Constants.kDarkThemeWhiteAccentColor)
                        : MaterialStateProperty.all(
                            Constants.kAlternativeTextColor),
                    padding: MaterialStateProperty.all(EdgeInsets.zero),
                    elevation: MaterialStateProperty.all(0),
                    backgroundColor:
                        MaterialStateProperty.all(Colors.transparent),
                    //shadowColor: MaterialStateProperty.all(Colors.transparent),
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                  ),
                ),
                Obx(
                  () => Text(
                    '${widget.tasksController.dailyGoal.value}',
                    style: const TextStyle(fontSize: 20.0),
                  ),
                ),
              ],
            ),
          ],
        ),
        Positioned(
          width: 0.9.sw,
          bottom: 0.03.sh,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  await handleSignOut();
                },
                icon: const Icon(Icons.logout_outlined),
                label: Text('signOut'.tr),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  await handleAccountDeletion(
                      widget.databaseController, context, isWorking);
                  setState(() {
                    isWorking = false;
                  });
                  //TODO implement this instead of my boilerplate code
                  //  showReauthenticateDialog(
                  //   context: context,
                  //   providerConfigs: [
                  //     GoogleProviderConfiguration(
                  //         clientId: Platform.isIOS
                  //             ? '${DefaultFirebaseOptions.currentPlatform.iosClientId}'
                  //             : '${DefaultFirebaseOptions.currentPlatform.androidClientId}'),
                  //     const AppleProviderConfiguration()
                  //   ],
                  //   auth: FirebaseAuth.instance,
                  //   onSignedIn: () => Navigator.of(context).pop(true),
                  // );
                },
                icon: const Icon(Icons.delete_outline_rounded),
                label: Text('deleteAccount'.tr),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future handleAccountDeletion(DatabaseController databaseController,
      BuildContext context, bool isWorking) async {
    if (databaseController.isConnected.value) {
      Platform.isIOS
          ? await showCupertinoDialog(
              context: context,
              builder: (context) {
                return StatefulBuilder(
                  builder: (BuildContext context,
                          void Function(void Function()) setState) =>
                      !isWorking
                          ? CupertinoAlertDialog(
                              title: Text('warning'.tr),
                              content: Text('areYouSure'.tr),
                              actions: [
                                CupertinoDialogAction(
                                  onPressed: () async {
                                    //reauth if apple
                                    if (FirebaseAuth.instance.currentUser!
                                            .providerData[0].providerId ==
                                        'apple.com') {
                                      try {
                                        var appleCredentials = await signIn();
                                        await FirebaseAuth.instance.currentUser!
                                            .reauthenticateWithCredential(
                                                appleCredentials);
                                      } on SignInWithAppleAuthorizationException {
                                        return;
                                      }
                                    }
                                    //reauth if google
                                    else {
                                      final GoogleSignInAccount? googleUser =
                                          await GoogleSignIn().signIn();

                                      // Obtain the auth details from the request
                                      final GoogleSignInAuthentication?
                                          googleAuth =
                                          await googleUser?.authentication;

                                      // Create a new credential
                                      if (googleAuth != null) {
                                        final credential =
                                            GoogleAuthProvider.credential(
                                          accessToken: googleAuth.accessToken,
                                          idToken: googleAuth.idToken,
                                        );
                                        try {
                                          await FirebaseAuth
                                              .instance.currentUser!
                                              .reauthenticateWithCredential(
                                                  credential);
                                        } on FirebaseAuthException {
                                          Get.snackbar(
                                              'error'.tr, 'sameAccount'.tr,
                                              icon: const Icon(
                                                  Icons.error_outline,
                                                  color: Colors.white),
                                              snackPosition:
                                                  SnackPosition.BOTTOM,
                                              shouldIconPulse: true,
                                              backgroundColor: Colors.red);

                                          return;
                                        }
                                      } else {
                                        return;
                                      }
                                    }

                                    setState(() => isWorking = true);
                                    WriteBatch batch =
                                        FirebaseFirestore.instance.batch();
                                    var currentUserDoc = FirebaseFirestore
                                        .instance
                                        .collection('users')
                                        .doc(FirebaseAuth
                                            .instance.currentUser!.uid);
                                    await currentUserDoc
                                        .collection('categories')
                                        .get()
                                        .then(
                                      (querySnapshot) {
                                        for (var document
                                            in querySnapshot.docs) {
                                          batch.delete(document.reference);
                                        }
                                      },
                                    );
                                    await currentUserDoc
                                        .collection('todos')
                                        .get()
                                        .then(
                                      (querySnapshot) {
                                        for (var document
                                            in querySnapshot.docs) {
                                          batch.delete(document.reference);
                                        }
                                      },
                                    );
                                    await currentUserDoc
                                        .collection('lists')
                                        .get()
                                        .then(
                                      (querySnapshot) {
                                        for (var document
                                            in querySnapshot.docs) {
                                          batch.delete(document.reference);
                                        }
                                      },
                                    );
                                    await batch.commit().then(
                                          (value) async => await currentUserDoc
                                              .delete()
                                              .then(
                                                (value) async =>
                                                    await FirebaseAuth
                                                        .instance.currentUser!
                                                        .delete()
                                                        .then(
                                                          (value) async =>
                                                              await Get
                                                                  .offAllNamed(
                                                            AppPages
                                                                .routes[1].name,
                                                          ),
                                                        ),
                                              ),
                                        );
                                  },
                                  child: Text(
                                    'yes'.tr,
                                  ),
                                ),
                                CupertinoDialogAction(
                                  onPressed: () {
                                    Get.back();
                                  },
                                  child: Text(
                                    'no'.tr,
                                  ),
                                ),
                                CupertinoDialogAction(
                                  isDestructiveAction: true,
                                  onPressed: () {
                                    Get.back();
                                  },
                                  child: Text(
                                    'cancel'.tr,
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox(
                              width: 50,
                              height: 50,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                );
              },
            )
          : showDialog(
              context: context,
              builder: (context) {
                return StatefulBuilder(
                  builder: (BuildContext context,
                          void Function(void Function()) setState) =>
                      !isWorking
                          ? AlertDialog(
                              title: Text('warning'.tr),
                              content: Text(
                                'areYouSure'.tr,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () async {
                                    //reauth if apple
                                    if (FirebaseAuth.instance.currentUser!
                                            .providerData[0].providerId ==
                                        'apple.com') {
                                      try {
                                        var appleCredentials = await signIn();
                                        await FirebaseAuth.instance.currentUser!
                                            .reauthenticateWithCredential(
                                                appleCredentials);
                                      } on SignInWithAppleAuthorizationException {
                                        return;
                                      }
                                    }
                                    //reauth if google
                                    else {
                                      final GoogleSignInAccount? googleUser =
                                          await GoogleSignIn().signIn();

                                      // Obtain the auth details from the request
                                      final GoogleSignInAuthentication?
                                          googleAuth =
                                          await googleUser?.authentication;

                                      // Create a new credential
                                      if (googleAuth != null) {
                                        final credential =
                                            GoogleAuthProvider.credential(
                                          accessToken: googleAuth.accessToken,
                                          idToken: googleAuth.idToken,
                                        );
                                        await FirebaseAuth.instance.currentUser!
                                            .reauthenticateWithCredential(
                                                credential);
                                      } else {
                                        return;
                                      }
                                    }

                                    setState(() => isWorking = true);
                                    WriteBatch batch =
                                        FirebaseFirestore.instance.batch();
                                    var currentUserDoc = FirebaseFirestore
                                        .instance
                                        .collection('users')
                                        .doc(FirebaseAuth
                                            .instance.currentUser!.uid);
                                    await currentUserDoc
                                        .collection('categories')
                                        .get()
                                        .then(
                                      (querySnapshot) {
                                        for (var document
                                            in querySnapshot.docs) {
                                          batch.delete(document.reference);
                                        }
                                      },
                                    );
                                    await currentUserDoc
                                        .collection('todos')
                                        .get()
                                        .then(
                                      (querySnapshot) {
                                        for (var document
                                            in querySnapshot.docs) {
                                          batch.delete(document.reference);
                                        }
                                      },
                                    );
                                    await currentUserDoc
                                        .collection('lists')
                                        .get()
                                        .then(
                                      (querySnapshot) {
                                        for (var document
                                            in querySnapshot.docs) {
                                          batch.delete(document.reference);
                                        }
                                      },
                                    );
                                    await batch.commit().then(
                                          (value) async => await currentUserDoc
                                              .delete()
                                              .then(
                                                (value) async =>
                                                    await FirebaseAuth
                                                        .instance.currentUser!
                                                        .delete()
                                                        .then(
                                                          (value) async =>
                                                              await Get
                                                                  .offAllNamed(
                                                            AppPages
                                                                .routes[1].name,
                                                          ),
                                                        ),
                                              ),
                                        );
                                  },
                                  child: Text('yes'.tr),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Get.back();
                                  },
                                  child: Text('no'.tr),
                                ),
                              ],
                            )
                          : const SizedBox(
                              width: 50,
                              height: 50,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                );
              },
            );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('alert'.tr),
          content: Text('alertDescription'.tr),
          actions: <Widget>[
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}

/// Returns the sha256 hash of [input] in hex notation.
String sha256ofString(String input) {
  final bytes = utf8.encode(input);
  final digest = sha256.convert(bytes);
  return digest.toString();
}

Future<OAuthCredential> signIn() async {
  final rawNonce = generateNonce();
  final nonce = sha256ofString(rawNonce);

  // Request credential for the currently signed in Apple account.
  final appleCredential = await SignInWithApple.getAppleIDCredential(
    scopes: [
      AppleIDAuthorizationScopes.email,
      AppleIDAuthorizationScopes.fullName,
    ],
    nonce: nonce,
  );

  // Create an `OAuthCredential` from the credential returned by Apple.
  final oauthCredential = OAuthProvider('apple.com').credential(
    idToken: appleCredential.identityToken,
    rawNonce: rawNonce,
  );

  return oauthCredential;
}

Future handleSignOut() async {
  try {
    return await FirebaseAuth.instance.signOut().then((value) async {
      //Get.deleteAll();
      //Get.delete<DatabaseController>();
      Get.offAllNamed(AppPages.routes[1].name);
      // Get.back();
    });
  } catch (e) {
    return (e);
  }
}

class ThemeRow extends StatelessWidget {
  const ThemeRow({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(
          CustomIcons.show,
          color: context.isDarkMode
              ? Constants.kDarkThemeWhiteAccentColor
              : Constants.kAlternativeTextColor,
        ),
        const SizedBox(
          width: 25.0,
        ),
        Text(
          'theme'.tr,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18.sp,
            letterSpacing: 1,
            color: context.isDarkMode
                ? Constants.kDarkThemeWhiteAccentColor
                : Constants.kAlternativeTextColor,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
