import 'package:flutter/material.dart';
import 'package:monify/models/transaction.dart';

import '../../models/account.dart';
import '../../models/category.dart';

class AccountsModel extends ChangeNotifier {
  List<Category> categories = [];
  List<TransactionModel> transactions = [];
  List<Account> accounts = [];
  late String userId;
  bool isLoading = false;

  void loadCategories(List<Category> _categories) {
    isLoading = true;
    notifyListeners();

    categories = _categories;
    isLoading = false;
    notifyListeners();
  }

  void loadAccounts(List<Account> _accounts) {
    isLoading = true;
    notifyListeners();

    accounts = _accounts;
    isLoading = false;
    notifyListeners();
  }

  void setUserId(String _userId) {
    userId = _userId;
    notifyListeners();
  }

  void loadTransactions(List<TransactionModel> _transactions) {
    isLoading = true;
    notifyListeners();

    transactions = _transactions;
    isLoading = false;
    notifyListeners();
  }

  void setLoading(bool _isLoading) {
    isLoading = _isLoading;
    notifyListeners();
  }
}
