import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../generated/locale_keys.g.dart';
import '../../models/account.dart';
import '../../models/category.dart';
import '../account_detail/account_detail_view.dart';
import 'accounts_controller.dart';
import 'accounts_model.dart';
import 'add_account_view.dart';

class AccountsView extends StatefulWidget {
  const AccountsView({Key? key}) : super(key: key);
  @override
  State<AccountsView> createState() => _AccountsViewState();
}

class _AccountsViewState extends State<AccountsView> {
  Account _account = Account(
    name: '',
    balance: 0,
    createdAt: DateTime.now().toString(),
    updatedAt: DateTime.now().toString(),
    type: AccountType.cash,
  );

  late final AccountsController _controller;
  late final AccountsModel _model;

  //init state
  @override
  void initState() {
    super.initState();
    _model = AccountsModel();
    _controller = AccountsController(_model);
    _controller.init();
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: ((context) => _model),
      child: Scaffold(
        appBar: AppBar(
          title: Text(LocaleKeys.accounts.tr()),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                // showBottomSheet(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddAccountView(),
                  ),
                );
              },
            ),
          ],
        ),
        body: Consumer<AccountsModel>(
          builder: (context, model, child) {
            return model.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                    color: kPrimaryColor,
                  ))
                : ListView.builder(
                    itemCount: model.accounts.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AccountDetailView(account: model.accounts[index])));
                        },
                        child: Card(
                          child: Slidable(
                            endActionPane: ActionPane(
                              motion: const DrawerMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (context) {
                                    showBottomSheet(context, account: model.accounts[index]);
                                  },
                                  backgroundColor: kBlueColor,
                                  foregroundColor: Colors.white,
                                  icon: Icons.edit,
                                  label: LocaleKeys.edit.tr(),
                                ),
                                SlidableAction(
                                  onPressed: (context) {
                                    deleteAccount(model, index, context);
                                  },
                                  backgroundColor: kErrorColor,
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: LocaleKeys.delete.tr(),
                                ),
                              ],
                            ),
                            child: ListTile(
                              title: Text(model.accounts[index].name.tr()),
                              trailing: Text(model.accounts[index].balance.toString()),
                            ),
                          ),
                        ),
                      );
                    },
                  );
          },
        ),
      ),
    );
  }

  Future<dynamic> showBottomSheet(BuildContext context, {Account? account}) {
    return showModalBottomSheet(
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      context: context,
      builder: (context) => bottomSheet(context, account: account),
    );
  }

  void deleteAccount(AccountsModel model, int index, BuildContext context) {
    if (model.transactions != []) {
      var hasTransaction = model.transactions.any((element) => element.accountId == model.accounts[index].id);
      if (hasTransaction) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(LocaleKeys.deleteAccount.tr()),
              content: Text(LocaleKeys.deleteAccountError.tr()),
              actions: <Widget>[
                TextButton(
                  child: Text(LocaleKeys.ok.tr()),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        if (model.accounts.length == 1) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(LocaleKeys.deleteAccount.tr()),
                content: Text(LocaleKeys.oneAccountRequired.tr()),
                actions: <Widget>[
                  TextButton(
                    child: Text(LocaleKeys.ok.tr()),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(LocaleKeys.deleteAccount.tr()),
                content: Text(LocaleKeys.confirmDeleteAccount.tr()),
                actions: [
                  TextButton(
                    child: Text(LocaleKeys.cancel.tr()),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  TextButton(
                    child: Text(LocaleKeys.delete.tr()),
                    onPressed: () {
                      _controller.deleteAccount(model.accounts[index].id!);
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            },
          );
        }
      }
    }
  }

  Widget bottomSheet(BuildContext context, {Account? account}) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        width: MediaQuery.of(context).size.width - 10,
        decoration: const BoxDecoration(
          color: kBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Wrap(children: [
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  FractionallySizedBox(
                    widthFactor: 0.25,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 12.0,
                      ),
                      child: Container(
                        height: 5.0,
                        decoration: const BoxDecoration(
                          color: kTextLightColor,
                          borderRadius: BorderRadius.all(Radius.circular(2.5)),
                        ),
                      ),
                    ),
                  ),
                  account != null
                      ? TextFormField(
                          initialValue: account.name,
                          decoration: InputDecoration(
                            labelText: LocaleKeys.accountName.tr(),
                            labelStyle: TextStyle(
                              color: kTextLightColor,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return LocaleKeys.accountNameWarning.tr();
                            }
                            return null;
                          },
                          onChanged: (value) {
                            _account.name = value;
                          },
                        )
                      : TextFormField(
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                              labelText: LocaleKeys.accountName.tr(),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                              )),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return LocaleKeys.accountNameWarning.tr();
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              _account.name = value;
                            });
                          },
                        ),
                  const SizedBox(height: 20),
                  account == null
                      ? TextFormField(
                          initialValue: 0.00.toString(),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              labelText: LocaleKeys.initialBalance.tr(),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                              )),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return LocaleKeys.enterValidAmount.tr();
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              _account.balance = double.parse(value);
                            });
                          },
                        )
                      : Container(),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _controller.addAccount(_account);
                          Navigator.pop(context);
                        }
                      },
                      child: Text(LocaleKeys.save.tr()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
