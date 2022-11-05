import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:monify/generated/locale_keys.g.dart';
import 'package:monify/models/account.dart';
import 'package:monify/pages/accounts/accounts_controller.dart';

import '../../resources/firestore_methods.dart';

class AddAccountView extends StatefulWidget {
  const AddAccountView({Key? key}) : super(key: key);

  @override
  State<AddAccountView> createState() => _AddAccountViewState();
}

class _AddAccountViewState extends State<AddAccountView> {
  final TextEditingController _accountTypeController = TextEditingController();
  var account = Account(
    name: '',
    description: '',
    balance: 0,
    type: AccountType.cash,
    createdAt: '',
    updatedAt: '',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            children: [
              TextFormField(
                toolbarOptions: const ToolbarOptions(),
                controller: _accountTypeController,
                onTap: () {
                  _showActionSheet(context);
                },
                keyboardType: TextInputType.none,
                decoration: InputDecoration(
                  labelText: LocaleKeys.accountType.tr(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Account Name',
                ),
                onChanged: (value) {
                  account.name = value;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Account Balance',
                ),
                onChanged: (value) {
                  account.balance = double.parse(value);
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  account.createdAt = DateTime.now().toString();
                  account.updatedAt = DateTime.now().toString();
                  await FirestoreMethods().addAccount(account: account, uid: FirebaseAuth.instance.currentUser!.uid);
                },
                child: const Text('Add Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showActionSheet(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Select Account Type'),
        message: const Text('Please select the type of account you want to add.'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _accountTypeController.text = 'Cash';
              account.type = AccountType.cash;
            },
            child: const Text('Cash'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _accountTypeController.text = 'Bank';
              account.type = AccountType.bank;
            },
            child: const Text('Bank'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _accountTypeController.text = 'Credit Card';
              account.type = AccountType.creditCard;
            },
            child: const Text('Credit Card'),
          ),
        ],
      ),
    );
  }
}
