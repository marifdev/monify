import 'package:easy_localization/easy_localization.dart';
import 'package:monify/constants.dart';
import 'package:monify/models/currency.dart';
import 'package:monify/pages/auth/login_view.dart';
import 'package:monify/resources/auth_methods.dart';
import 'package:monify/resources/firestore_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../generated/locale_keys.g.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  Currency? _usersCurrency;
  bool isUpdated = false;
  final Uri privacyUrl = Uri.parse('https://pages.flycricket.io/expense-tracker-11/privacy.html');
  final Uri termsUrl = Uri.parse('https://pages.flycricket.io/expense-tracker-11/terms.html');

  //init state
  @override
  void initState() {
    super.initState();
    _getCurrency();
  }

  void _getCurrency() {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    FirestoreMethods().getUser(userId).then((user) {
      setState(() {
        _usersCurrency = user.currency;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.settings.tr()),
      ),
      body: SafeArea(
        child: Column(
          children: [
            ListView(
              shrinkWrap: true,
              children: [
                // ListTile(
                //   title: const Text('Dark Mode'),
                //   trailing: Switch(
                //     value: true,
                //     onChanged: (value) {},
                //   ),
                // ),
                ListTile(
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
                // privacy policy
                ListTile(
                  title: Text(LocaleKeys.privacyPolicy.tr()),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    _launchUrl(privacyUrl);
                  },
                ),
                // terms and conditions
                ListTile(
                  title: Text(LocaleKeys.termsAndConditions.tr()),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    _launchUrl(termsUrl);
                  },
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
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
                child: Text(LocaleKeys.deleteAccount.tr()))
          ],
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
