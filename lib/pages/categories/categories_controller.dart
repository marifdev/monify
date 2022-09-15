import 'package:firebase_auth/firebase_auth.dart';
import 'package:monify/pages/categories/categories_model.dart';

import '../../models/category.dart';
import '../../models/transaction.dart';
import '../../resources/firestore_methods.dart';

class CategoriesController {
  final CategoriesModel _model;
  CategoriesController(this._model);

  void init() async {
    _model.setLoading(true);
    _model.setUserId(FirebaseAuth.instance.currentUser!.uid);
    getCategories(_model.userId).then((value) => _model.loadCategories(value));
    getTransactions(_model.userId).then((value) => _model.loadTransactions(value));
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

  void addCategory(String userId, Category category) async {
    _model.setLoading(true);
    await FirestoreMethods().addCategory(uid: userId, category: category);
    _model.setLoading(false);
    init();
  }

  void deleteCategory(String userId, String categoryId) async {
    _model.setLoading(true);
    await FirestoreMethods().deleteCategory(uid: userId, categoryId: categoryId);
    _model.setLoading(false);
    init();
  }
}
