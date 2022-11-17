import 'package:monify/utils/shared_methods.dart';

import '../../models/transaction.dart';
import '../../resources/firestore_methods.dart';
import '../base/base_model.dart';

class AddTransactionController {
  final BaseModel _model;
  AddTransactionController(this._model);

  Future<void> addTransaction(TransactionModel transaction) async {
    // await FirestoreMethods().addTransaction(transaction: transaction, uid: _model.user!.uid);
    await SharedMethods(_model).addTransaction(transaction);
  }
}
