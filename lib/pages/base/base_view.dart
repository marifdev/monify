import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:monify/generated/locale_keys.g.dart';
import 'package:monify/pages/accounts/accounts_view.dart';
import 'package:monify/pages/home/home_view.dart';

import '../contact/contact_view.dart';
import '../home/widgets/app_drawer.dart';

class BaseView extends StatefulWidget {
  const BaseView({Key? key}) : super(key: key);

  @override
  State<BaseView> createState() => _BaseViewState();
}

class _BaseViewState extends State<BaseView> {
  int _selectedIndex = 1;
  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    AccountsView(),
    MyHomePage(),
    Text(
      'Index 2: School',
      style: optionStyle,
    ),
    Text(
      'Index 3: Settings',
      style: optionStyle,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Monify'),
      //   elevation: 0,
      //   actions: [
      //     // contact us
      //     IconButton(
      //       onPressed: () {
      //         Navigator.push(context, MaterialPageRoute(builder: (context) => ContactView()));
      //       },
      //       icon: const Icon(Icons.mail_outline),
      //     ),
      //   ],
      // ),
      // drawer: AppDrawer(controller: _controller, interstitialAd: _interstitialAd),
      // onDrawerChanged: (isOpened) {
      //   // if (!isOpened && _interstitialAd != null) {
      //   //   _loadInterstitialAd();
      //   // }
      // },
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.account_balance),
            label: LocaleKeys.accounts.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.history),
            label: LocaleKeys.transactions.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.analytics),
            label: LocaleKeys.statistics.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: LocaleKeys.settings.tr(),
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
