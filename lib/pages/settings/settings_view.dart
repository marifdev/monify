import 'package:easy_localization/easy_localization.dart';
import 'package:launch_review/launch_review.dart';
import 'package:monify/constants.dart';
import 'package:monify/models/currency.dart';
import 'package:monify/pages/auth/login_view.dart';
import 'package:monify/pages/base/base_model.dart';
import 'package:monify/pages/onboarding/onboarding_view.dart';
import 'package:monify/pages/onboarding/paywall_screen.dart';
import 'package:monify/resources/auth_methods.dart';
import 'package:monify/resources/firestore_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../generated/locale_keys.g.dart';
import '../categories/categories_view.dart';

class SettingsView extends StatefulWidget {
  final BaseModel model;
  const SettingsView({Key? key, required this.model}) : super(key: key);

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  Currency? _usersCurrency;
  bool isUpdated = false;
  bool isPremium = false;
  final Uri privacyUrl = Uri.parse('https://pages.flycricket.io/expense-tracker-11/privacy.html');
  final Uri termsUrl = Uri.parse('https://pages.flycricket.io/expense-tracker-11/terms.html');

  //init state
  @override
  void initState() {
    super.initState();
    _getCurrency();
    isPremium = widget.model.user!.isPremium;
  }

  void _getCurrency() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    await FirestoreMethods().getUser(userId).then((user) {
      setState(() {
        _usersCurrency = user.currency;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: ((context) => widget.model),
      child: Scaffold(
        appBar: AppBar(
          title: Text(LocaleKeys.settings.tr()),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              ListView(
                shrinkWrap: true,
                children: [
                  // ListTile(
                  //   title: const Text('Dark Mode'),
                  //   trailing: Switch(
                  //     value: isDark,
                  //     onChanged: (value) {
                  //       value = !value;
                  //       value ? ThemeMode.dark : ThemeMode.light;
                  //     },
                  //   ),
                  // ),
                  ListTile(
                    minLeadingWidth: 0,
                    leading: const Icon(Icons.currency_exchange),
                    title: const Text(LocaleKeys.currency).tr(),
                    trailing: DropdownButton(
                      value: _usersCurrency,
                      items: kCurrencyList.map((e) {
                        return DropdownMenuItem(
                          value: e,
                          child: Text(e.code),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _usersCurrency = value as Currency?;
                          FirestoreMethods().updateUser(updatedFields: {
                            'currency': _usersCurrency!.toJson(),
                          }, uid: FirebaseAuth.instance.currentUser!.uid);
                          isUpdated = true;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    minLeadingWidth: 0,
                    leading: const Icon(Icons.language),
                    title: const Text(LocaleKeys.language).tr(),
                    trailing: DropdownButton(
                      value: context.locale,
                      items: context.supportedLocales.map((e) {
                        return DropdownMenuItem(
                          value: e,
                          child: getLanguageFromCode(e),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          context.setLocale(value as Locale);
                        });
                      },
                    ),
                  ),
                  ListTile(
                    minLeadingWidth: 0,
                    leading: const Icon(Icons.category),
                    title: Text(
                      LocaleKeys.categories.tr(),
                    ),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CategoriesView(),
                        ),
                      );
                    },
                  ),
                  // privacy policy
                  ListTile(
                    minLeadingWidth: 0,
                    leading: const Icon(Icons.privacy_tip),
                    title: Text(LocaleKeys.privacyPolicy.tr()),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      _launchUrl(privacyUrl);
                    },
                  ),
                  // terms and conditions
                  ListTile(
                    minLeadingWidth: 0,
                    leading: const Icon(Icons.description),
                    title: Text(LocaleKeys.termsAndConditions.tr()),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      _launchUrl(termsUrl);
                    },
                  ),
                  ListTile(
                    minLeadingWidth: 0,
                    leading: const Icon(Icons.star),
                    title: Text(
                      LocaleKeys.rateUs.tr(),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      LaunchReview.launch(iOSAppId: '6443472705');
                    },
                  ),
                  if (!isPremium)
                    ListTile(
                      minLeadingWidth: 0,
                      leading: const Icon(Icons.lock),
                      title: Text(
                        LocaleKeys.bePremium.tr(),
                      ),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isDismissible: false,
                          builder: (context) => PaywallScreen(model: widget.model),
                        );
                      },
                    ),
                  ListTile(
                    minLeadingWidth: 0,
                    leading: const Icon(Icons.logout),
                    title: Text(
                      LocaleKeys.logout.tr(),
                    ),
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacement(
                          context, MaterialPageRoute(builder: (context) => const OnboardingView()));
                    },
                  ),
                ],
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(LocaleKeys.confirmDelete.tr()),
                            content: Text(LocaleKeys.deleteAccount.tr()),
                            actions: <Widget>[
                              TextButton(
                                child: Text(LocaleKeys.cancel.tr()),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: Text(LocaleKeys.delete.tr()),
                                onPressed: () {
                                  var user = FirebaseAuth.instance.currentUser;
                                  FirestoreMethods().deleteUser(user!.uid);
                                  AuthMethods().deleteUser();
                                  FirebaseAuth.instance.signOut();
                                  // Navigator.of(context).pop();
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (context) => const LoginView()),
                                    (Route<dynamic> route) => false,
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text(LocaleKeys.deleteAccount.tr())),
              )
            ],
          ),
        ),
      ),
    );
  }

  Text getLanguageFromCode(Locale e) {
    var language = 'English';
    switch (e.languageCode) {
      case 'en':
        language = 'English';
        break;
      case 'tr':
        language = 'Türkçe';
        break;
      case 'de':
        language = 'Deutsch';
        break;
      case 'fr':
        language = 'Français';
        break;
      case 'es':
        language = 'Español';
        break;
      case 'it':
        language = 'Italiano';
        break;
      default:
        language = 'English';
    }
    return Text(language);
  }

  Future<void> _launchUrl(_url) async {
    if (!await launchUrl(_url)) {
      throw 'Could not launch $_url';
    }
  }
}
