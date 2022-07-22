import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutterfire_ui/i10n.dart';
import 'package:get/get.dart';
import 'package:todozoid2/views/home_page.dart';

import 'package:url_launcher/url_launcher.dart';
import 'consts/theme_service.dart';
import 'consts/themes.dart';
import 'firebase_options.dart';

import 'localization/customlocalizations.dart';
import 'localization/translations_delegate.dart';
import 'routes/app_pages.dart';
import 'package:flutterfire_ui/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ThemeMode mode = await ThemeService().getThemeMode();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  runApp(MyApp(mode));
}

class MyApp extends StatelessWidget {
  final ThemeMode mode;

  const MyApp(this.mode, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      builder: (context, child) {
        var locale = Get.deviceLocale;
        return GetMaterialApp(
          translations: MyLocalizations(),
          debugShowCheckedModeBanner: false,

          //useInheritedMediaQuery: true,
          localizationsDelegates: [
            FlutterFireUIRuLocalizationsDelegate(),
            FlutterFireUILocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            DefaultCupertinoLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          locale: locale,
          fallbackLocale: const Locale('en', 'US'),
          supportedLocales: const [
            Locale('en', 'US'), // English
            Locale('ru', 'RU'), // Russian
            Locale('de', 'DE'), // German
            Locale('cs', 'CS'), // Czech
          ],
          theme: Themes().lightTheme,
          darkTheme: Themes().darkTheme,
          themeMode: mode,
          //home: child,
          initialRoute: AppPages.initial,
          getPages: AppPages.routes,

          //
        );
      },
      child: AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  AuthGate({Key? key}) : super(key: key);

  final Uri toLaunch = Uri(
      scheme: 'https',
      host: 'gist.github.com',
      path: '/gidrokolbaska/57d39fa38142adc21039801f44ea6ee3');

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, snapshot) {
        // User is not signed in

        if (!snapshot.hasData) {
          return SignInScreen(
            providerConfigs: [
              GoogleProviderConfiguration(
                  clientId: Platform.isIOS
                      ? '${DefaultFirebaseOptions.currentPlatform.iosClientId}'
                      : '${DefaultFirebaseOptions.currentPlatform.androidClientId}'),
              const AppleProviderConfiguration()
            ],
            showAuthActionSwitch: false,
            headerMaxExtent: 250.h,
            headerBuilder: (context, constraints, _) {
              return Image.asset(
                'assets/images/loginImage.png',
                scale: 1,
              );
            },
            subtitleBuilder: (context, action) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'welcome'.tr,
                  style: TextStyle(fontSize: 12.sp),
                ),
              );
            },
            footerBuilder: (context, _) {
              return Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          style: TextStyle(color: Colors.grey, fontSize: 11.sp),
                          text: 'termsandconditions1'.tr,
                        ),
                        TextSpan(
                          text: 'termsandconditions2'.tr,
                          style: TextStyle(
                              color: Colors.blue,
                              fontSize: 11.sp,
                              decoration: TextDecoration.underline),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              _launchInWebViewOrVC(toLaunch);
                            },
                        ),
                      ],
                    ),
                  ));
            },
          );
        }

        return HomePageContainer();
      },
    );
  }

  Future<void> _launchInWebViewOrVC(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.inAppWebView,
    )) {
      throw 'Could not launch $url';
    }
  }
}
