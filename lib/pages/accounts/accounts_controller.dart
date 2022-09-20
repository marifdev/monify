import 'package:firebase_auth/firebase_auth.dart';
import 'package:monify/pages/categories/categories_model.dart';

import '../../models/account.dart';
import '../../models/category.dart';
import '../../models/transaction.dart';
import '../../resources/firestore_methods.dart';
import 'accounts_model.dart';

class AccountsController {
  final AccountsModel _model;
  AccountsController(this._model);

  void init() async {
    _model.setLoading(true);
    _model.setUserId(FirebaseAuth.instance.currentUser!.uid);
    getCategories(_model.userId).then((value) => _model.loadCategories(value));
    getTransactions(_model.userId).then((value) => _model.loadTransactions(value));
    getAccounts(_model.userId).then((value) => _model.loadAccounts(value));
    _model.setLoading(false);
  }

  Future<List<Category>> getCategories(String userId) async {
    List<Category> categories;
    var docs = await FirestoreMethods().getCategories(userId);
    categories = docs
        .map((e) {
          return Category.fromJson(e.data() as Map<String, dynamic>);
        })
        .toList()
        .cast<Category>();
    return categories;
  }

  Future<List<TransactionModel>> getTransactions(String userId) async {
    List<TransactionModel> transactions = [];
    var docs = await FirestoreMethods().getTransactions(userId);
    transactions = docs
        .map((e) {
          return TransactionModel.fromJson(e.data() as Map<String, dynamic>);
        })
        .toList()
        .cast<TransactionModel>();
    return transactions;
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
    _model.setLoading(true);
    account.createdAt = DateTime.now().toString();
    account.updatedAt = DateTime.now().toString();
    await FirestoreMethods().addAccount(account: account, uid: _model.userId).then((value) => refreshAccounts());
    _model.setLoading(false);
  }

  void deleteAccount(String accountId) async {
    _model.setLoading(true);
    await FirestoreMethods().deleteAccount(accountId, _model.userId).then((value) => refreshAccounts());
    _model.setLoading(false);
  }

  void refreshAccounts() async {
    _model.setLoading(true);
    await getAccounts(_model.userId).then((value) => _model.loadAccounts(value));
    _model.setLoading(false);
  }
}
