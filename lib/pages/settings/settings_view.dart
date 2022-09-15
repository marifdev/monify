import 'package:monify/constants.dart';
import 'package:monify/models/currency.dart';
import 'package:monify/resources/firestore_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
        title: const Text('Settings'),
      ),
      body: Center(
        child: ListView(
          children: [
            // ListTile(
            //   title: const Text('Dark Mode'),
            //   trailing: Switch(
            //     value: true,
            //     onChanged: (value) {},
            //   ),
            // ),
            ListTile(
              title: const Text('Currency'),
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
            // privacy policy
            ListTile(
              title: const Text('Privacy Policy'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                _launchUrl(privacyUrl);
              },
            ),
            // terms and conditions
            ListTile(
              title: const Text('Terms and Conditions'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                _launchUrl(termsUrl);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(_url) async {
    if (!await launchUrl(_url)) {
      throw 'Could not launch $_url';
    }
  }
}
