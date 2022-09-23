import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:launch_review/launch_review.dart';

import '../../../constants.dart';
import '../../accounts/accounts_view.dart';
import '../../auth/login_view.dart';
import '../../categories/categories_view.dart';
import '../../settings/settings_view.dart';
import '../home_controller.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    Key? key,
    required HomeController controller,
  })  : _controller = controller,
        super(key: key);

  final HomeController _controller;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: kPrimaryColor,
      child: Column(
        children: [
          const SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.account_balance_wallet_outlined,
                color: Colors.white,
                size: 50,
              ),
              Text(
                'Monify',
                style: TextStyle(color: Colors.white, fontSize: 50),
              ),
            ],
          ),
          ListView(
            shrinkWrap: true,
            children: <Widget>[
              ListTile(
                title: const Text(
                  'Accounts',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AccountsView(),
                    ),
                  ).then((value) {
                    _controller.refreshAccounts();
                  });
                },
              ),
              ListTile(
                title: const Text(
                  'Categories',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CategoriesView(),
                    ),
                  ).then((value) => _controller.refreshCategories());
                },
              ),
              ListTile(
                title: const Text(
                  'Settings',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsView(),
                    ),
                  ).then((value) => _controller.refreshUser());
                },
              ),
              ListTile(
                title: const Text(
                  'Rate us',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  LaunchReview.launch(iOSAppId: '6443472705');
                },
              ),
              ListTile(
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginView()));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
