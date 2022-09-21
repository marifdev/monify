import 'package:firebase_auth/firebase_auth.dart';

import '../../models/category.dart';
import '../../models/transaction.dart';
import '../../resources/firestore_methods.dart';
import 'category_detail_model.dart';

class CategoryDetailController {
  final CategoryDetailModel _model;
  final Category category;
  CategoryDetailController(this._model, this.category);

  void init() async {
    _model.setLoading(true);
    _model.loadCategory(category);
    _model.setUserId(FirebaseAuth.instance.currentUser!.uid);
    getTransactionsByCategory(_model.userId, _model.category).then((value) {
      _model.loadTransactions(value);
      _model.sortTransactions('date');
    });
    _model.setLoading(false);
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
}
