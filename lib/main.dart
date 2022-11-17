import 'dart:io';

import 'package:monify/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:monify/firebase_options.dart';
import 'package:monify/pages/base/base_view.dart';
import 'package:monify/pages/onboarding/onboarding_view.dart';
import 'package:purchases_flutter/object_wrappers.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'pages/add_transaction/new_add_transaction.dart';

final _configuration =
    PurchasesConfiguration(Platform.isIOS ? 'appl_LEKwHiwDPDbTwWIwnUyTBJbPueY' : 'goog_tGdnySYObiqIBhjNaeJOZEzVnnN');

void main() async {
  List<String> testDevices = ["7ABE9ACDE1496DF76DED55CA924426BE", "c7033721599c9ff6340e16f7566c6f46"];
  // List<String> testDevices = [];
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await EasyLocalization.ensureInitialized();
  MobileAds.instance.initialize();

  RequestConfiguration configuration = RequestConfiguration(testDeviceIds: testDevices);
  MobileAds.instance.updateRequestConfiguration(configuration);
  await Purchases.configure(_configuration);
  runApp(
    EasyLocalization(
        supportedLocales: const [Locale('en', 'US'), Locale('tr', 'TR'), Locale('de', 'DE')],
        path: 'assets/translations', // <-- change the path of the translation files
        fallbackLocale: const Locale('en', 'US'),
        child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      title: 'Monify',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: kPrimaryColor,
          secondary: kPrimaryColor,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: kPrimaryColor,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.shifting,
          enableFeedback: true,
        ),
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              return const BaseView();
            } else if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong'));
            }
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
              color: kPrimaryColor,
            ));
          }
          return const OnboardingView();
        },
      ),
    );
  }
}
