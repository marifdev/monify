import 'package:flutter/material.dart';
import 'package:monify/models/transaction.dart';

import '../../models/account.dart';

class AccountDetailModel extends ChangeNotifier {
  List<TransactionModel> transactions = [];
  late Account account;
  late String userId;
  bool isLoading = false;

  void loadAccount(Account _account) {
    isLoading = true;
    notifyListeners();

    account = _account;
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

  void sortTransactions(String value) {
    isLoading = true;
    notifyListeners();

    switch (value) {
      case 'date':
        transactions.sort((a, b) => b.date.compareTo(a.date));
        break;
      case 'amount':
        transactions.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      default:
        transactions.sort((a, b) => b.date.compareTo(a.date));
        break;
    }
    isLoading = false;
    notifyListeners();
  }

  void setLoading(bool _isLoading) {
    isLoading = _isLoading;
    notifyListeners();
  }
}
