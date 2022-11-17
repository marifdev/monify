import 'package:firebase_auth/firebase_auth.dart';
import 'package:monify/pages/base/base_model.dart';
import 'package:monify/pages/statistics/statistics_model.dart';

import '../../models/category.dart';
import '../../models/transaction.dart';
import '../../resources/firestore_methods.dart';

class StatisticsController {
  final StatisticsModel _model;
  final BaseModel _baseModel;
  StatisticsController(this._model, this._baseModel);

  void init() async {
    _model.setLoading(true);
    _model.setUserId(FirebaseAuth.instance.currentUser!.uid);
    // getCategories(_model.userId).then((value) => _model.loadCategories(value));
    // getTransactions(_model.userId).then((value) => _model.loadTransactions(value));
    _model.loadCategories(_baseModel.user.categories);
    _model.loadTransactions(_baseModel.user.transactions);
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

  Future<List<TransactionModel>> getTransactionsByCategory(String userId, Category category) async {
    var docs = await FirestoreMethods().getTransactionsByCategory(userId, category.id!);
    var transactions = docs
        .map((e) {
          return TransactionModel.fromJson(e.data() as Map<String, dynamic>);
        })
        .toList()
        .cast<TransactionModel>();
    return transactions;
  }

  //total transaction amount by category
  double getTotalIncomeAmountByCategory(List<TransactionModel> transactions) {
    double total = 0;
    transactions.forEach((element) {
      if (element.type == TransactionType.income) {
        total += element.amount;
      }
    });
    return total;
  }

  //total transaction amount by category
  double getTotalExpenseAmountByCategory(List<TransactionModel> transactions) {
    double total = 0;
    transactions.forEach((element) {
      if (element.type == TransactionType.expense) {
        total += element.amount;
      }
    });
    return total;
  }

  Future<double> calculateCategoryIncomeTotal(Category category) async {
    double total = 0;
    var transactions = _model.transactions.where((element) => element.categoryId == category.id).toList();
    total = getTotalIncomeAmountByCategory(transactions);
    return total;
  }

  Future<double> calculateCategoryExpenseTotal(Category category) async {
    double total = 0;
    var transactions = _model.transactions.where((element) => element.categoryId == category.id).toList();
    total = getTotalExpenseAmountByCategory(transactions);
    return total;
  }

  //calculate chart data
  Future<List<Map<String, dynamic>>> calculateIncomeChartData() async {
    List<Map<String, dynamic>> chartData = [];
    var fullTotal = 0.0;
    for (var category in _model.categories) {
      var categoryTotal = await calculateCategoryIncomeTotal(category);
      fullTotal += categoryTotal;
    }
    for (var category in _model.categories) {
      var categoryTotal = await calculateCategoryIncomeTotal(category);
      if (categoryTotal > 0) {
        chartData.add(
            {'domain': category.name, 'measure': double.parse((categoryTotal * 100 / fullTotal).toStringAsFixed(2))});
      }
    }
    return chartData;
  }

  Future<List<Map<String, dynamic>>> calculateExpenseChartData() async {
    List<Map<String, dynamic>> chartData = [];
    var fullTotal = 0.0;
    for (var category in _model.categories) {
      var categoryTotal = await calculateCategoryExpenseTotal(category);
      fullTotal += categoryTotal;
    }
    for (var category in _model.categories) {
      var categoryTotal = await calculateCategoryExpenseTotal(category);
      if (categoryTotal > 0) {
        chartData.add(
            {'domain': category.name, 'measure': double.parse((categoryTotal * 100 / fullTotal).toStringAsFixed(2))});
      }
    }
    return chartData;
  }
}
