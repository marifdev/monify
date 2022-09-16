import 'package:firebase_auth/firebase_auth.dart';
import 'package:monify/constants.dart';

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
    });
    _model.setLoading(false);
  }

  Future<UserModel> getUser() async {
    return await FirestoreMethods().getUser(FirebaseAuth.instance.currentUser!.uid);
  }

  void refreshUser() async {
    _model.setLoading(true);
    await getUser().then((user) => _model.setUser(user));
    _model.setLoading(false);
  }

  void refreshCategories() async {
    _model.setLoading(true);
    await getCategories(_model.user.uid).then((value) => _model.loadCategories(value));
    _model.setLoading(false);
  }

  void refreshTransactions() async {
    _model.setLoading(true);
    await getTransactions(_model.user.uid).then((value) => _model.loadTransactions(value));
    sortTransactions('date');
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

  //delete transaction
  Future<void> deleteTransaction(String id) async {
    _model.setLoading(true);
    await FirestoreMethods().deleteTransaction(id, _model.user.uid);
    _model.setLoading(false);
  }

  void sortTransactions(String value) {
    _model.sortTransactions(value);
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    _model.setLoading(true);
    await FirestoreMethods().addTransaction(transaction: transaction, uid: _model.user.uid).then((value) {
      refreshTransactions();
    });
    _model.setLoading(false);
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    _model.setLoading(true);
    await FirestoreMethods().updateTransaction(transaction: transaction, uid: _model.user.uid).then((value) {
      refreshTransactions();
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
}
