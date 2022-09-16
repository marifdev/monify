import 'package:flutter/material.dart';
import 'package:monify/models/user.dart';

import '../../models/category.dart';
import '../../models/transaction.dart';

class HomeModel extends ChangeNotifier {
  List<Category> categories = [];
  List<TransactionModel> transactions = [];
  List<TransactionModel> sortedTransactions = [];
  List<TransactionModel> filteredTransactions = []; // TODO: implement filtered transactions
  late UserModel user;
  bool isLoading = false;

  void loadCategories(List<Category> _categories) {
    isLoading = true;
    notifyListeners();

    categories = _categories;
    isLoading = false;
    notifyListeners();
  }

  void setUser(UserModel _user) {
    user = _user;
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

  void sortTransactions(String value) {
    isLoading = true;
    notifyListeners();

    switch (value) {
      case 'date':
        sortedTransactions = transactions;
        sortedTransactions.sort((a, b) => b.date.compareTo(a.date));
        break;
      case 'amount':
        sortedTransactions = transactions;
        sortedTransactions.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      default:
        sortedTransactions = transactions;
    }
    isLoading = false;
    notifyListeners();
  }
}
