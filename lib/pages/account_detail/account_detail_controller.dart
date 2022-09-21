import 'package:firebase_auth/firebase_auth.dart';

import '../../models/account.dart';
import '../../models/transaction.dart';
import '../../resources/firestore_methods.dart';
import 'account_detail_model.dart';

class AccountDetailController {
  final AccountDetailModel _model;
  final Account account;
  AccountDetailController(this._model, this.account);

  void init() async {
    _model.setLoading(true);
    _model.loadAccount(account);
    _model.setUserId(FirebaseAuth.instance.currentUser!.uid);
    await getTransactionsByAccount(_model.userId, _model.account).then((value) {
      _model.loadTransactions(value);
      _model.sortTransactions('date');
    });
    _model.setLoading(false);
  }

  Future<List<TransactionModel>> getTransactionsByAccount(String userId, Account account) async {
    List<TransactionModel> transactions = [];
    var docs = await FirestoreMethods().getTransactionsByAccount(userId, account.id!);
    transactions = docs
        .map((e) {
          return TransactionModel.fromJson(e.data() as Map<String, dynamic>);
        })
        .toList()
        .cast<TransactionModel>();
    return transactions;
  }
}
