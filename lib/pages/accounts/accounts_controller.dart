import 'package:firebase_auth/firebase_auth.dart';
import 'package:monify/pages/base/base_model.dart';
import 'package:monify/pages/categories/categories_model.dart';

import '../../models/account.dart';
import '../../models/category.dart';
import '../../models/transaction.dart';
import '../../resources/firestore_methods.dart';
import 'accounts_model.dart';

class AccountsController {
  final BaseModel baseModel;
  final AccountsModel accountsModel;
  AccountsController({required this.accountsModel, required this.baseModel});

  void init() async {
    accountsModel.setLoading(true);
    accountsModel.setUser(baseModel.user);
    accountsModel.loadAccounts(baseModel.user.accounts);
    accountsModel.setLoading(false);
  }

  Future<List<Account>> getAccounts(String userId) async {
    List<Account> accounts = [];
    var docs = await FirestoreMethods().getAccounts(userId);
    accounts = docs
        .map((e) {
          return Account.fromJson(e.data() as Map<String, dynamic>);
        })
        .toList()
        .cast<Account>();
    return accounts;
  }

  void addAccount(Account account) async {
    accountsModel.setLoading(true);
    account.createdAt = DateTime.now().toString();
    account.updatedAt = DateTime.now().toString();
    await FirestoreMethods().addAccount(account: account, uid: baseModel.user.uid);
    accountsModel.setLoading(false);
  }

  void deleteAccount(String accountId) async {
    accountsModel.setLoading(true);
    await FirestoreMethods().deleteAccount(accountId, baseModel.user.uid).then((value) => refreshAccounts());
    accountsModel.setLoading(false);
  }

  void refreshAccounts() async {
    accountsModel.setLoading(true);
    await getAccounts(baseModel.user.uid).then((value) => accountsModel.loadAccounts(value));
    accountsModel.setLoading(false);
  }
}
