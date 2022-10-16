import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:monify/models/category.dart';

import '../../models/transaction.dart';

class StatisticsModel extends ChangeNotifier {
  List<Category> categories = [];
  List<TransactionModel> transactions = [];

  late String userId;
  bool isLoading = false;

  void loadCategories(List<Category> _categories) {
    isLoading = true;
    notifyListeners();

    categories = _categories;
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
