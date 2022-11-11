import 'package:flutter/material.dart';
import 'package:monify/models/user.dart';

import '../../models/account.dart';
import '../../models/category.dart';
import '../../models/transaction.dart';

class BaseModel extends ChangeNotifier {
  UserModel? user;
  bool isLoading = false;

  BaseModel({
    this.user,
  });

  void setUser(UserModel _user) {
    user = _user;
    notifyListeners();
  }

  void setLoading(bool _isLoading) {
    isLoading = _isLoading;
    notifyListeners();
  }

  void loadCategories(List<Category> _categories) {
    user!.categories = _categories;
    notifyListeners();
  }

  void loadTransactions(List<TransactionModel> _transactions) {
    user!.transactions = _transactions;
    sortTransactions('date');
    notifyListeners();
  }

  void loadAccounts(List<Account> _accounts) {
    user!.accounts = _accounts;
    notifyListeners();
  }

  void sortTransactions(String _sortBy) {
    if (_sortBy == 'date') {
      user!.transactions!.sort((a, b) => b.date.compareTo(a.date));
    } else if (_sortBy == 'amount') {
      user!.transactions!.sort((a, b) => b.amount.compareTo(a.amount));
    }
  }
}
