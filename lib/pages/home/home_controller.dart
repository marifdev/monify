import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:monify/constants.dart';
import 'package:monify/generated/locale_keys.g.dart';

import '../../models/account.dart';
import '../../models/category.dart';
import '../../models/transaction.dart';
import '../../models/user.dart';
import '../../resources/firestore_methods.dart';
import 'home_model.dart';

class HomeController {
  final HomeModel _model;
  HomeController(this._model);
  void init() async {
    _model.setLoading(true);
    await getUser().then((user) {
      _model.setUser(user);

      getCategories(user.uid).then((value) {
        if (value.isNotEmpty) {
          _model.loadCategories(value);
        } else {
          for (var element in kCategoryList) {
            addCategory(element, user.uid);
          }
          _model.loadCategories(kCategoryList);
        }
      });
      getTransactions(user.uid).then((value) {
        _model.loadTransactions(value);
        _model.sortTransactions('date');
      });
      getAccounts(user.uid).then((value) {
        if (value.isNotEmpty) {
          _model.loadAccounts(value);
        } else {
          Account initialAccount = Account(
            name: LocaleKeys.cash.tr(),
            balance: 0,
            createdAt: DateTime.now().toString(),
            updatedAt: DateTime.now().toString(),
          );
          addAccount(initialAccount, user.uid);
          _model.loadAccounts([initialAccount]);
        }
      });
    });
    _model.setLoading(false);
  }

  Future<UserModel> getUser() async {
    return await FirestoreMethods().getUser(FirebaseAuth.instance.currentUser!.uid);
  }

  void refreshUser() async {
    _model.setLoading(true);
    await getUser().then((user) {
      _model.setUser(user);
      _model.setLoading(false);
    });
  }

  void refreshCategories() async {
    _model.setLoading(true);
    await getCategories(_model.user.uid).then((value) {
      _model.loadCategories(value);
      _model.setLoading(false);
    });
  }

  Future<void> refreshTransactions() async {
    _model.setLoading(true);
    await getTransactions(_model.user.uid).then((value) {
      _model.loadTransactions(value);
      _model.sortTransactions('date');
      _model.setLoading(false);
    });
  }

  void refreshAccounts() async {
    _model.setLoading(true);
    await getAccounts(_model.user.uid).then((value) {
      _model.loadAccounts(value);
      _model.setLoading(false);
    });
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

  //delete transaction
  Future<void> deleteTransaction(TransactionModel transaction) async {
    _model.setLoading(true);
    await FirestoreMethods().deleteTransaction(transaction.id, _model.user.uid).then((value) {
      refreshTransactions().then((value) {
        updateAccount(accountId: transaction.accountId!, updatedFields: {
          'balance': calculateBalance(transaction.accountId!),
        });
        updateAccount(accountId: transaction.toAccountId!, updatedFields: {
          'balance': calculateBalance(transaction.toAccountId!),
        });
      });
    });
    _model.setLoading(false);
  }

  void sortTransactions(String value) {
    _model.sortTransactions(value);
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    _model.setLoading(true);
    await FirestoreMethods().addTransaction(transaction: transaction, uid: _model.user.uid).then((value) {
      refreshTransactions().then((value) {
        updateAccount(accountId: transaction.accountId!, updatedFields: {
          'balance': calculateBalance(transaction.accountId!),
        });
        if (transaction.type == TransactionType.transfer) {
          updateAccount(accountId: transaction.toAccountId!, updatedFields: {
            'balance': calculateBalance(transaction.toAccountId!),
          });
        }
      });
    });
    _model.setLoading(false);
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    _model.setLoading(true);
    await FirestoreMethods().updateTransaction(transaction: transaction, uid: _model.user.uid).then((value) {
      refreshTransactions().then((value) {
        updateAccount(accountId: transaction.accountId!, updatedFields: {
          'balance': calculateBalance(transaction.accountId!),
        });
        if (transaction.type == TransactionType.transfer) {
          updateAccount(accountId: transaction.toAccountId!, updatedFields: {
            'balance': calculateBalance(transaction.toAccountId!),
          });
        }
      });
    });
    _model.setLoading(false);
  }

  Future<void> addCategory(Category category, String userId) async {
    _model.setLoading(true);
    await FirestoreMethods().addCategory(category: category, uid: userId).then((value) {
      refreshCategories();
    });
    _model.setLoading(false);
  }

  // add account
  Future<void> addAccount(Account account, String userId) async {
    _model.setLoading(true);
    await FirestoreMethods().addAccount(account: account, uid: userId).then((value) {
      refreshAccounts();
    });
    _model.setLoading(false);
  }

  Future<void> updateAccount({required String accountId, required Map<String, dynamic> updatedFields}) async {
    await FirestoreMethods().updateAccount(updatedFields: updatedFields, accountId: accountId, uid: _model.user.uid);
  }

  calculateBalance(String accountId) {
    double balance = 0;
    _model.transactions.forEach((element) {
      if (element.accountId == accountId) {
        switch (element.type) {
          case TransactionType.income:
            balance += element.amount;
            break;
          case TransactionType.expense:
            balance -= element.amount;
            break;
          case TransactionType.transfer:
            balance -= element.amount;
            break;
          default:
        }
      } else if (element.toAccountId == accountId) {
        balance += element.amount;
      }
    });
    return balance;
  }
}
