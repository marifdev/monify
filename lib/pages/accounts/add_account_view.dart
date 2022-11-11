import 'dart:isolate';

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

import '../../constants.dart';
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

  var _accountTypeFocusNode = FocusNode();
  bool _isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  var _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                focusNode: _accountTypeFocusNode,
                toolbarOptions: const ToolbarOptions(),
                controller: _accountTypeController,
                onTap: () {
                  _showActionSheet(context);
                },
                keyboardType: TextInputType.none,
                decoration: InputDecoration(
                  labelText: LocaleKeys.accountType.tr(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return LocaleKeys.accountTypeRequired.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                  ),
                  labelText: 'Account Name',
                ),
                onChanged: (value) {
                  account.name = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return LocaleKeys.accountNameWarning.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                  ),
                  labelText: 'Account Balance',
                ),
                onChanged: (value) {
                  account.balance = NumberFormat().parse(value) as double;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: !_isLoading
                    ? () async {
                        if (_formKey.currentState!.validate()) {
                          account.createdAt = DateTime.now().toString();
                          account.updatedAt = DateTime.now().toString();
                          setState(() {
                            _isLoading = true;
                          });
                          await FirestoreMethods()
                              .addAccount(account: account, uid: FirebaseAuth.instance.currentUser!.uid);
                          setState(() {
                            _isLoading = false;
                          });
                          Navigator.pop(context);
                        }
                      }
                    : null,
                child: _isLoading
                    ? Transform.scale(
                        scale: 0.5,
                        child: const CircularProgressIndicator(
                          color: kSecondaryColor,
                        ))
                    : const Text('Add Account'),
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
              _accountTypeController.text = LocaleKeys.cash.tr();
              account.type = AccountType.cash;
            },
            child: Text(LocaleKeys.cash.tr()),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _accountTypeController.text = LocaleKeys.bankAccount.tr();
              account.type = AccountType.bank;
            },
            child: Text(LocaleKeys.bankAccount.tr()),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _accountTypeController.text = LocaleKeys.creditCard.tr();
              account.type = AccountType.creditCard;
            },
            child: Text(LocaleKeys.creditCard.tr()),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () {
            Navigator.pop(context);
            _accountTypeFocusNode.unfocus();
          },
          child: const Text('Cancel'),
        ),
      ),
    );
  }
}
