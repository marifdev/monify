import 'package:flutter/material.dart';
import 'package:monify/models/transaction.dart';

import '../../models/category.dart';

class CategoryDetailModel extends ChangeNotifier {
  late Category category;
  List<TransactionModel> transactions = [];
  late String userId;
  bool isLoading = false;

  void loadCategory(Category _category) {
    isLoading = true;
    notifyListeners();

    category = _category;
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

  void sortTransactions(String value) {
    isLoading = true;
    notifyListeners();

    switch (value) {
      case 'date':
        transactions.sort((a, b) => b.date.compareTo(a.date));
        break;
      case 'amount':
        transactions.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      default:
        transactions;
    }
    isLoading = false;
    notifyListeners();
  }
}
