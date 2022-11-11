import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/account.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../models/user.dart';
import '../pages/base/base_model.dart';
import '../resources/firestore_methods.dart';

class SharedMethods {
  BaseModel _model;
  SharedMethods(this._model);
  void refreshCategories() async {
    _model.setLoading(true);
    await getCategories(_model.user!.uid).then((value) {
      _model.loadCategories(value);
      _model.setLoading(false);
    });
  }

  Future<void> refreshTransactions() async {
    _model.setLoading(true);
    await getTransactions(_model.user!.uid).then((value) {
      _model.loadTransactions(value);
      _model.setLoading(false);
    });
  }

  Future<void> refreshUser() async {
    _model.setLoading(true);
    await getUser(_model.user!.uid).then((value) {
      _model.setUser(value);
      _model.setLoading(false);
    });
  }

  //get user
  Future<UserModel> getUser(String uid) async {
    return FirestoreMethods().getUser(uid);
  }

  void refreshAccounts() async {
    _model.setLoading(true);
    await getAccounts(_model.user!.uid).then((value) {
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
    await FirestoreMethods().deleteTransaction(transaction.id, _model.user!.uid).then((value) {
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

  Future<void> addTransaction(TransactionModel transaction) async {
    _model.setLoading(true);
    await FirestoreMethods().addTransaction(transaction: transaction, uid: _model.user!.uid).then((value) {
      print('Transaction added');
    });
    await refreshTransactions();
    await updateAccount(accountId: transaction.accountId!, updatedFields: {
      'balance': calculateBalance(transaction.accountId!),
    });
    var updatedAccount = _model.user!.accounts!.firstWhere((element) => element.id == transaction.accountId);
    var index = _model.user!.accounts!.indexOf(updatedAccount);
    _model.user!.accounts![index] = updatedAccount;
    if (transaction.type == TransactionType.transfer) {
      await updateAccount(accountId: transaction.toAccountId!, updatedFields: {
        'balance': calculateBalance(transaction.toAccountId!),
      });
      var updatedToAccount = _model.user!.accounts!.firstWhere((element) => element.id == transaction.toAccountId);
      var index2 = _model.user!.accounts!.indexOf(updatedToAccount);
      _model.user!.accounts![index] = updatedToAccount;
    }

    _model.loadAccounts(_model.user!.accounts!);
    _model.setLoading(false);
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    _model.setLoading(true);
    await FirestoreMethods().updateTransaction(transaction: transaction, uid: _model.user!.uid).then((value) {
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
    await FirestoreMethods().updateAccount(updatedFields: updatedFields, accountId: accountId, uid: _model.user!.uid);
  }

  calculateBalance(String accountId) {
    double balance = 0;
    _model.user!.transactions!.forEach((element) {
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
